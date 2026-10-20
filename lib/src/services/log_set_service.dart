import 'package:flutter/foundation.dart';

import '../domain/models/memory.dart';
import '../domain/models/workout.dart';
import '../domain/models/workout_event.dart';
import '../domain/repositories/workout_repository.dart';
import 'memory/memory_pipeline.dart';

class LogSetService {
  const LogSetService({
    required this.workoutRepository,
    required this.memoryPipeline,
  });

  final WorkoutRepository workoutRepository;
  final MemoryPipeline memoryPipeline;

  Future<Memory?> logSet({
    required String userId,
    required String exercise,
    required String? muscleGroup,
    required int targetReps,
    required LoggedSet loggedSet,
  }) async {
    // Luôn lưu set tập trước.
    await workoutRepository.saveLoggedSet(loggedSet);

    final feedbackText = loggedSet.feedbackText?.trim();

    debugPrint(
      '[LogSetService] userId=$userId, '
      'exercise=$exercise, '
      'feedbackText="$feedbackText"',
    );

    if (feedbackText == null || feedbackText.isEmpty) {
      return null;
    }

    final event = SetFeedbackEvent(
      userId: userId,
      exercise: exercise,
      muscleGroup: muscleGroup,
      setIndex: loggedSet.setIndex,
      weight: loggedSet.weight,
      reps: loggedSet.reps,
      targetReps: targetReps,
      feedbackText: feedbackText,
      timestamp: loggedSet.loggedAt,
    );

    try {
      // Chạy toàn bộ MemoryPipeline thay vì trích xuất trực tiếp.
      final memory = await memoryPipeline.ingest(event);

      debugPrint(
        '[LogSetService] Pipeline result: '
        '${memory == null ? "NO MEMORY" : memory.type.name}',
      );

      if (memory != null) {
        debugPrint(
          '[LogSetService] MEMORY PROCESSED: '
          'id=${memory.id}, '
          'exercise=${memory.exercise}, '
          'type=${memory.type.name}, '
          'status=${memory.status.name}',
        );
      }

      return memory;
    } catch (error, stackTrace) {
      // Lỗi Memory không làm mất set đã lưu.
      debugPrint('[LogSetService] Memory pipeline failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}
