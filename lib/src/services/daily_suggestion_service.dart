import 'package:flutter/foundation.dart';

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

  // Chỉ cache kết quả AI (theo user + ngày) để tiết kiệm quota.
  final Map<String, DailySuggestion> _aiCache = {};

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
    }

    final sessions = await _loadRecent(userId, historyDays);
    if (sessions.isEmpty) return _warmUpSuggestion();

    final known = await _loadKnown(userId);
    if (known.isEmpty) return _warmUpSuggestion();

    final proxy = _proxy;
    if (proxy != null) {
      try {
        final ai = await _fromAi(
          proxy,
          userId,
          now,
          sessions,
          known,
        ).timeout(aiTimeout);
        if (ai != null) {
          _aiCache[key] = ai;
          return ai;
        }
      } catch (e) {
        // AI lỗi, hết quota, chưa có token... -> dùng gợi ý local bên dưới.
        debugPrint('AI suggestion failed: $e');
      }
    }

    return _fromHistory(sessions, known);
  }

  DailySuggestion _warmUpSuggestion() => const DailySuggestion(
    source: SuggestionSource.warmUp,
    summary:
        'Chưa có buổi tập gần đây. Hãy bắt đầu bằng các bài khởi động nhẹ.',
    exercises: _warmUp,
  );

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

    // DEBUG: kiểm tra dữ liệu gửi cho AI
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

    // Chặn AI bịa bài: chỉ nhận tên có trong danh sách của user.
    final byName = {for (final e in known) e.name.trim().toLowerCase(): e};
    final out = <SuggestedExercise>[];
    for (final item in list) {
      if (item is! Map) continue;
      final name = item['name'];
      if (name is! String) continue;
      final match = byName[name.trim().toLowerCase()];
      if (match == null || out.any((e) => e.name == match.name)) continue;
      final reason = item['reason'];
      out.add(
        SuggestedExercise(
          name: match.name,
          reason: reason is String ? _clip(reason, 120) : '',
        ),
      );
      if (out.length == 5) break;
    }
    if (out.isEmpty) return null;

    final summary = json['summary'];
    return DailySuggestion(
      source: SuggestionSource.ai,
      summary: summary is String && summary.trim().isNotEmpty
          ? _clip(summary, 160)
          : 'Gợi ý cho buổi tập hôm nay',
      exercises: out,
    );
  }

  Future<String> _memoryText(
    String userId,
    List<RecentSession> sessions,
  ) async {
    final retrieval = _retrieval;

    if (retrieval == null) {
      return '(không có)';
    }

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

  /// Local: chọn nhóm cơ lâu chưa tập nhất (hoặc chưa tập lần nào).
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
        for (final e in groups[target]!.take(4))
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
