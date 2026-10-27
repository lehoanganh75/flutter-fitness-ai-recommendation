import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/drift_workout_repository.dart';
import '../domain/models/daily_suggestion.dart';
import 'ai/ai_proxy_client.dart';
import 'memory/memory_retrieval.dart';

typedef LoadRecentSessions = Future<List<RecentSession>> Function(
  String userId,
  int days,
);
typedef LoadKnownExercises = Future<List<KnownExercise>> Function(
  String userId,
);

class DailySuggestionService {
  DailySuggestionService({
    required LoadRecentSessions loadRecentSessions,
    required LoadKnownExercises loadKnownExercises,
    required this.workoutRepository,
    this._proxy,
    this._retrieval,
    this.historyDays = 3,
    this.aiTimeout = const Duration(seconds: 75),
  }) : _loadRecent = loadRecentSessions,
       _loadKnown = loadKnownExercises;

  final LoadRecentSessions _loadRecent;
  final LoadKnownExercises _loadKnown;
  final AiProxyClient? _proxy;
  final MemoryRetrieval? _retrieval;
  final int historyDays;
  final Duration aiTimeout;
  final DriftWorkoutRepository workoutRepository;

  final Map<String, DailySuggestion> _aiCache = {};
  DateTime? _lastAiRequest;
  static const _cooldownDuration = Duration(minutes: 2);

  static const _warmUp = [
    SuggestedExercise(
      name: 'Đi bộ nhanh hoặc đạp xe nhẹ',
      reason: '5 phút để tăng nhịp tim và làm nóng cơ thể',
    ),
    SuggestedExercise(
      name: 'Xoay khớp vai, hông, cổ tay',
      reason: 'Làm linh hoạt các khớp trước khi tập nặng',
    ),
    SuggestedExercise(
      name: 'Squat không tạ',
      reason: '2 hiệp 10-15 lần để kích hoạt chân và mông',
    ),
    SuggestedExercise(
      name: 'Chống đẩy gối',
      reason: '2 hiệp 8-10 lần để kích hoạt ngực, vai, tay sau',
    ),
    SuggestedExercise(
      name: 'Plank',
      reason: '2 hiệp 30 giây để kích hoạt cơ core',
    ),
  ];

  Future<DailySuggestion> suggest({
    required String userId,
    required DateTime now,
    bool forceRefresh = false,
  }) async {
    final key = '$userId|${now.year}-${now.month}-${now.day}';

    if (!forceRefresh) {
      final cached = _aiCache[key];
      if (cached != null) return cached;

      final dbCache = await workoutRepository.getAiSuggestionCache(key);
      if (dbCache != null) {
        try {
          final decoded = jsonDecode(dbCache) as Map<String, dynamic>;
          final suggestion = _decodeSuggestion(decoded);
          _aiCache[key] = suggestion;
          return suggestion;
        } catch (e) {
          debugPrint('[Cache] Lỗi đọc SQLite: $e');
        }
      }
    }

    final sessions = await _loadRecent(userId, historyDays);
    final known = await _loadKnown(userId);

    if (sessions.isEmpty || known.isEmpty) {
      return _warmUpSuggestion();
    }

    final proxy = _proxy;
    if (proxy != null) {
      if (forceRefresh && _lastAiRequest != null) {
        final diff = DateTime.now().difference(_lastAiRequest!);
        if (diff < _cooldownDuration) {
          debugPrint('[AI] Cooldown, dùng history');
          return _safeHistoryFallback(sessions, known);
        }
      }

      try {
        _lastAiRequest = DateTime.now();
        final ai = await _fromAi(
          proxy,
          userId,
          now,
          sessions,
          known,
        ).timeout(aiTimeout);
        if (ai != null && ai.exercises.isNotEmpty) {
          _aiCache[key] = ai;
          return ai;
        }
      } catch (e) {
        debugPrint('[AI] Lỗi: $e → fallback history');
      }
    }

    return _safeHistoryFallback(sessions, known);
  }

  DailySuggestion _decodeSuggestion(Map<String, dynamic> decoded) {
    return DailySuggestion(
      source: SuggestionSource.ai,
      summary: decoded['summary'] as String? ?? '',
      exercises: (decoded['exercises'] as List).map((e) {
        final map = e as Map<String, dynamic>;
        return SuggestedExercise(
          name: map['name'] as String,
          reason: map['reason'] as String? ?? '',
          sets: (map['sets'] as num?)?.toInt() ?? 3,
          reps: (map['reps'] as num?)?.toInt() ?? 10,
          weight: (map['weight'] as num?)?.toDouble() ?? 20.0,
        );
      }).toList(),
    );
  }

  DailySuggestion _warmUpSuggestion() => const DailySuggestion(
    source: SuggestionSource.warmUp,
    summary:
        'Chưa có buổi tập gần đây. Hãy bắt đầu bằng các bài khởi động nhẹ.',
    exercises: _warmUp,
  );

  DailySuggestion _safeHistoryFallback(
    List<RecentSession> sessions,
    List<KnownExercise> known,
  ) {
    try {
      final history = _fromHistory(sessions, known);
      if (history.exercises.isNotEmpty) return history;
    } catch (e) {
      debugPrint('[History] Lỗi: $e');
    }
    return _warmUpSuggestion();
  }

  Future<DailySuggestion?> _fromAi(
    AiProxyClient proxy,
    String userId,
    DateTime now,
    List<RecentSession> sessions,
    List<KnownExercise> known,
  ) async {
    final input = <String, dynamic>{
      'today': _isoDate(now),
      'weekday': now.weekday,
      'instruction':
          'Gợi ý 4-6 bài tập. Đa dạng nhóm cơ. '
          'Mỗi bài: name, reason, sets (3-4), reps (8-12), weight (kg).',
      'recent_sessions': [
        for (final s in sessions.take(30))
          {
            'date': _isoDate(s.date),
            'exercise': s.exercise,
            'muscle_group': s.muscleGroup,
            'top_weight': s.topWeight,
            'reps': s.reps,
          },
      ],
      'known_exercises': [
        for (final e in known.take(40))
          {'name': e.name, 'muscle_group': e.muscleGroup},
      ],
      'memory_context': await _memoryText(userId, sessions),
    };

    debugPrint('========== AI INPUT DEBUG ==========');
    debugPrint('MEMORY CONTEXT: ${input['memory_context']}');
    debugPrint(
      'RECENT SESSIONS COUNT: '
      '${(input['recent_sessions'] as List).length}',
    );
    debugPrint(
      'KNOWN EXERCISES COUNT: '
      '${(input['known_exercises'] as List).length}',
    );
    debugPrint('====================================');

    final json = await proxy.analyze(task: 'daily_suggestion', input: input);
    final list = json['exercises'];
    if (list is! List) return null;

    final byName = {for (final e in known) e.name.trim().toLowerCase(): e};
    final out = <SuggestedExercise>[];

    for (final item in list) {
      if (item is! Map) continue;
      final name = item['name'];
      if (name is! String) continue;

      final match = byName[name.trim().toLowerCase()];
      if (match == null) {
        debugPrint('⚠️ AI bịa bài "$name" - không có trong known_exercises');
        continue;
      }
      if (out.any((e) => e.name == match.name)) continue;

      int finalSets = 3;
      int finalReps = 10;
      double finalWeight = 20.0;

      if (item['sets'] is num) {
        final s = (item['sets'] as num).toInt();
        if (s >= 1 && s <= 6) finalSets = s;
      }
      if (item['reps'] is num) {
        final r = (item['reps'] as num).toInt();
        if (r >= 1 && r <= 30) finalReps = r;
      }
      if (item['weight'] is num) {
        final w = (item['weight'] as num).toDouble();
        if (w >= 0 && w <= 500) finalWeight = w;
      }

      if (item['sets'] == null ||
          item['reps'] == null ||
          item['weight'] == null) {
        final history = sessions
            .where((s) => s.exercise.toLowerCase() == match.name.toLowerCase())
            .toList();
        if (history.isNotEmpty) {
          finalReps = history.first.reps ?? finalReps;
          finalWeight = history.first.topWeight ?? finalWeight;
        } else {
          finalWeight = _getDefaultWeight(match.muscleGroup);
        }
      }

      final reason = item['reason'];

      out.add(
        SuggestedExercise(
          name: match.name,
          reason: reason is String ? _clip(reason, 120) : '',
          sets: finalSets,
          reps: finalReps,
          weight: finalWeight,
        ),
      );
      if (out.length >= 6) break;
    }

    if (out.length < 3) {
      debugPrint('⚠️ AI chỉ trả ${out.length} bài hợp lệ, fallback');
      return null;
    }

    final summary = json['summary'];
    final summaryText = summary is String && summary.trim().isNotEmpty
        ? _clip(summary, 160)
        : 'Gợi ý cho buổi tập hôm nay';

    final suggestion = DailySuggestion(
      source: SuggestionSource.ai,
      summary: summaryText,
      exercises: out,
    );

    final cacheKey = '$userId|${now.year}-${now.month}-${now.day}';
    final jsonData = jsonEncode({
      'summary': summaryText,
      'exercises': out
          .map(
            (e) => {
              'name': e.name,
              'reason': e.reason,
              'sets': e.sets,
              'reps': e.reps,
              'weight': e.weight,
            },
          )
          .toList(),
    });
    await workoutRepository.saveAiSuggestionCache(cacheKey, jsonData);

    return suggestion;
  }

  Future<String> _memoryText(
    String userId,
    List<RecentSession> sessions,
  ) async {
    final retrieval = _retrieval;
    if (retrieval == null) return '(không có)';

    try {
      final lines = <String>{};
      final exerciseNames = sessions
          .map((s) => s.exercise.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .take(6);

      for (final name in exerciseNames) {
        final memories = await retrieval.retrieve(
          userId: userId,
          exercise: name,
        );
        for (final memory in memories) {
          final content = memory.content.trim();
          if (content.isEmpty) continue;
          lines.add('- ${memory.exercise}: ${_clip(content, 120)}');
        }
      }

      return lines.isEmpty ? '(không có)' : lines.join('\n');
    } catch (e, stackTrace) {
      debugPrint('MEMORY RETRIEVAL ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      return '(không có)';
    }
  }

  DailySuggestion _fromHistory(
    List<RecentSession> sessions,
    List<KnownExercise> known,
  ) {
    final lastTrained = <String, DateTime>{};
    for (final s in sessions) {
      final cur = lastTrained[s.muscleGroup];
      if (cur == null || s.date.isAfter(cur)) {
        lastTrained[s.muscleGroup] = s.date;
      }
    }

    final groups = <String, List<KnownExercise>>{};
    for (final e in known) {
      groups.putIfAbsent(e.muscleGroup, () => []).add(e);
    }

    final ordered = groups.keys.toList()
      ..sort((a, b) {
        final da = lastTrained[a];
        final db = lastTrained[b];
        if (da == null && db == null) return a.compareTo(b);
        if (da == null) return -1;
        if (db == null) return 1;
        return da.compareTo(db);
      });

    final target = ordered.first;
    final neverTrained = lastTrained[target] == null;
    return DailySuggestion(
      source: SuggestionSource.history,
      summary: neverTrained
          ? 'Nhóm $target chưa được tập trong $historyDays ngày qua.'
          : 'Nhóm $target đã nghỉ lâu nhất trong $historyDays ngày qua.',
      exercises: [
        for (final e in groups[target]!.take(5))
          SuggestedExercise(name: e.name, reason: 'Nhóm cơ: $target'),
      ],
    );
  }

  static String _isoDate(DateTime d) => d.toIso8601String().split('T').first;

  static String _clip(String s, int max) {
    final t = s.trim();
    return t.length <= max ? t : t.substring(0, max);
  }
}

double _getDefaultWeight(String muscleGroup) {
  final mg = muscleGroup.toLowerCase();
  if (mg.contains('leg') ||
      mg.contains('chân') ||
      mg.contains('squat') ||
      mg.contains('đùi')) {
    return 40.0;
  } else if (mg.contains('back') ||
      mg.contains('lưng') ||
      mg.contains('xô') ||
      mg.contains('row') ||
      mg.contains('deadlift')) {
    return 30.0;
  } else if (mg.contains('bicep') ||
      mg.contains('tay') ||
      mg.contains('forearm') ||
      mg.contains('curl')) {
    return 10.0;
  }
  return 20.0;
}
