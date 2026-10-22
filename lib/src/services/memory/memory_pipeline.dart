import 'package:fitness_recommendation/src/services/memory/memory_extractor.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/memory.dart';
import '../../domain/models/workout_event.dart';
import '../../domain/repositories/memory_repository.dart';
import '../ai/ai_proxy_client.dart';

/// Luồng ghi memory:
/// Extraction -> Validation -> Conflict Resolution
/// -> Merge -> Consolidation -> Storage.
class MemoryPipeline {
  MemoryPipeline({
    required this._repo,
    this._proxy,
    this.maxActivePerType = 5,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final MemoryRepository _repo;
  final AiProxyClient? _proxy;
  final int maxActivePerType;
  final DateTime Function() _clock;

  /// Tiếp nhận feedback và chạy toàn bộ pipeline.
  Future<Memory?> ingest(SetFeedbackEvent event) async {
    final candidate = await _extract(event);

    if (candidate == null || !_isValid(candidate)) {
      debugPrint('[MemoryPipeline] No valid memory extracted.');
      return null;
    }

    final existing = await _repo.activeForExercise(
      userId: candidate.userId,
      exercise: candidate.exercise,
      now: _clock(),
    );

    if (existing.any((memory) => memory.id == candidate.id)) {
      debugPrint('[MemoryPipeline] Duplicate memory: ${candidate.id}');
      return null;
    }

    final changes = _resolveAndMerge(candidate, existing);
    final compact = _consolidate(changes, existing);

    for (final memory in compact) {
      await _repo.save(memory);
    }

    debugPrint(
      '[MemoryPipeline] Saved ${compact.length} memory change(s) '
      'for ${candidate.exercise}.',
    );

    for (final change in changes) {
      for (final saved in compact) {
        if (saved.id == change.id) {
          return saved;
        }
      }
    }

    return candidate;
  }

  /// Ưu tiên AI hiểu ngữ cảnh.
  Future<Memory?> _extract(SetFeedbackEvent event) async {
    final feedback = event.feedbackText.trim();

    if (feedback.isEmpty) return null;

    final proxy = _proxy;

    if (proxy == null) {
      debugPrint('[MemoryPipeline] AI unavailable; using rule extraction.');
      return MemoryExtractor.extract(event);
    }

    try {
      final json = await proxy.analyze(
        task: 'memory_extraction',
        input: {
          'exercise': event.exercise,
          'muscle_group': event.muscleGroup,
          'feedback_text': feedback,
          'weight': event.weight,
          'reps': event.reps,
          'target_reps': event.targetReps,
          'set_index': event.setIndex,
          'language': 'Vietnamese',
          'instruction':
              'Phân tích đúng ý người dùng. '
              'Không suy diễn điều người dùng không nói. '
              'Phân biệt rõ phản hồi tích cực và tiêu cực. '
              'Không coi việc không mệt là mệt. '
              'Nếu phản hồi mơ hồ hoặc không chứa thông tin đáng nhớ, '
              'trả về memory null.',
        },
      );

      final memory = _fromJson(json, event);

      if (memory != null) {
        return memory;
      }

      final fallbackMemory = MemoryExtractor.extract(event);

      if (fallbackMemory != null) {
        debugPrint(
          '[MemoryPipeline] AI returned no valid memory; '
          'using rule extraction for ${event.exercise}.',
        );
        return fallbackMemory;
      }

      debugPrint(
        '[MemoryPipeline] AI returned no valid memory '
        'and rule extraction found no fatigue signal.',
      );
      return null;
    } catch (error, stackTrace) {
      debugPrint('[MemoryPipeline] AI extraction failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return MemoryExtractor.extract(event);
    }
  }

  /// Chuyển JSON từ AI thành Memory của ứng dụng.
  Memory? _fromJson(Map<String, dynamic> json, SetFeedbackEvent event) {
    final rawMemory = json['memory'];

    if (rawMemory is! Map<String, dynamic>) {
      return null;
    }

    final type = switch (rawMemory['type']) {
      'user_reported_fatigue' => MemoryType.USER_REPORTED_FATIGUE,
      'weight_preference' => MemoryType.WEIGHT_PREFERENCE,
      'performance_trend' => MemoryType.PERFORMANCE_TREND,
      _ => null,
    };

    final content = rawMemory['content'];
    final confidence = rawMemory['confidence'];

    if (type == null || content is! String || confidence is! num) {
      return null;
    }

    final normalizedContent = content.trim();
    final score = confidence.toDouble();

    if (normalizedContent.isEmpty ||
        !score.isFinite ||
        score < 0.0 ||
        score > 1.0) {
      return null;
    }

    return Memory(
      id: [
        event.userId,
        event.exercise,
        event.timestamp.microsecondsSinceEpoch,
        event.setIndex,
      ].join('_'),
      userId: event.userId,
      type: type,
      exercise: event.exercise,
      muscleGroup: event.muscleGroup,
      content: normalizedContent,
      value: {
        'weight': event.weight,
        'reps': event.reps,
        'target_reps': event.targetReps,
        'set_index': event.setIndex,
      },
      confidence: score,
      source: MemorySource.SET_FEEDBACK,
      status: MemoryStatus.ACTIVE,
      expiresAt: event.timestamp.add(const Duration(days: 30)),
      createdAt: event.timestamp,
      updatedAt: event.timestamp,
    );
  }

  /// Kiểm tra memory có đủ dữ liệu và còn sử dụng được không.
  bool _isValid(Memory memory) {
    return memory.userId.trim().isNotEmpty &&
        memory.exercise.trim().isNotEmpty &&
        memory.content.trim().isNotEmpty &&
        memory.confidence.isFinite &&
        memory.confidence >= 0.0 &&
        memory.confidence <= 1.0 &&
        memory.isUsable(_clock());
  }

  /// Conflict Resolution và Merge.
  List<Memory> _resolveAndMerge(Memory incoming, List<Memory> existing) {
    final sameType = existing
        .where((memory) => memory.type == incoming.type)
        .toList();

    // 1. Với Fatigue: Gộp nếu nội dung tương tự (trùng từ khóa chính)
    if (incoming.type == MemoryType.USER_REPORTED_FATIGUE) {
      final target = sameType.firstWhere((memory) {
        final oldContent = memory.content.toLowerCase();
        final newContent = incoming.content.toLowerCase();

        final isSimilar =
            (oldContent.contains('mệt') && newContent.contains('mệt')) ||
            (oldContent.contains('nặng') && newContent.contains('nặng')) ||
            (oldContent.contains('mỏi') && newContent.contains('mỏi'));
        return isSimilar;
      }, orElse: () => incoming);

      if (target.id != incoming.id) {
        final previousCount =
            (target.value['occurrences'] as num?)?.toInt() ?? 1;

        return [
          target.copyWith(
            value: {...target.value, 'occurrences': previousCount + 1},
            confidence: (target.confidence + 0.05).clamp(0.0, 1.0).toDouble(),
            expiresAt: _later(target.expiresAt, incoming.expiresAt),
            updatedAt: incoming.updatedAt,
          ),
        ];
      }

      return [incoming];
    }

    // 2. Preference / performance trend:
    // memory mới thay thế memory cũ cùng loại.
    return [
      incoming,
      for (final old in sameType)
        old.copyWith(
          status: MemoryStatus.SUPERSEDED,
          updatedAt: incoming.updatedAt,
        ),
    ];
  }

  DateTime? _later(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;

    return a.isAfter(b) ? a : b;
  }

  /// Giới hạn số memory ACTIVE cho mỗi loại.
  /// Memory vượt giới hạn được chuyển sang ARCHIVED.
  List<Memory> _consolidate(List<Memory> changes, List<Memory> existing) {
    final byId = <String, Memory>{
      for (final memory in existing) memory.id: memory,
    };

    for (final memory in changes) {
      byId[memory.id] = memory;
    }

    final touched = <String>{for (final memory in changes) memory.id};

    final groups = <MemoryType, List<Memory>>{};

    for (final memory in byId.values.where(
      (memory) => memory.status == MemoryStatus.ACTIVE,
    )) {
      groups.putIfAbsent(memory.type, () => []).add(memory);
    }

    for (final memories in groups.values) {
      memories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      for (final extra in memories.skip(maxActivePerType)) {
        byId[extra.id] = extra.copyWith(status: MemoryStatus.ARCHIVED);
        touched.add(extra.id);
      }
    }

    return [for (final id in touched) byId[id]!];
  }
}
