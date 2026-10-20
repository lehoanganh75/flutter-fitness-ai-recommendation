import 'package:flutter/foundation.dart';

import '../../domain/models/memory.dart';
import '../../domain/repositories/memory_repository.dart';

/// Memory Retrieval + Memory Context.
class MemoryRetrieval {
  MemoryRetrieval(this._repo, {this.limit = 8, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MemoryRepository _repo;
  final int limit;
  final DateTime Function() _clock;

  Future<List<Memory>> retrieve({
    required String userId,
    required String exercise,
  }) async {
    final now = _clock();

    debugPrint('========== MEMORY RETRIEVAL ==========');
    debugPrint('USER ID: $userId');
    debugPrint('EXERCISE: "$exercise"');
    debugPrint('NOW: $now');

    final all = await _repo.activeForExercise(
      userId: userId,
      exercise: exercise,
      now: now,
    );

    debugPrint('REPOSITORY RESULT COUNT: ${all.length}');

    for (final m in all) {
      debugPrint(
        'MEMORY: id=${m.id}, '
        'userId=${m.userId}, '
        'exercise="${m.exercise}", '
        'status=${m.status.name}, '
        'expiresAt=${m.expiresAt}, '
        'usable=${m.isUsable(now)}, '
        'content="${m.content}"',
      );
    }

    final usable = all.where((m) => m.isUsable(now)).toList()
      ..sort((a, b) => _score(b, now).compareTo(_score(a, now)));

    debugPrint('USABLE COUNT: ${usable.length}');
    debugPrint('======================================');

    return usable.take(limit).toList();
  }

  // Độ tin cậy giảm dần theo thời gian.
  double _score(Memory m, DateTime now) {
    final days = now.difference(m.updatedAt).inHours / 24;
    return m.confidence / (1 + days / 7);
  }

  /// Chuyển danh sách memory thành đoạn chữ đưa vào prompt.
  static String describe(List<Memory> memories) {
    if (memories.isEmpty) return '(không có)';
    return memories
        .map((m) {
          final content = m.content.length > 200
              ? m.content.substring(0, 200)
              : m.content;
          return '- [${m.type.name}] $content '
              '(confidence ${m.confidence.toStringAsFixed(2)}, '
              'weight ${m.value['weight']})';
        })
        .join('\n');
  }
}
