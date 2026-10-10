import 'package:fitness_recommendation/src/domain/models/memory.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout_event.dart';
import 'package:fitness_recommendation/src/domain/repositories/memory_repository.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/services/memory_extractor.dart';

class LogSetService {
  const LogSetService({
    required this.workoutRepository,
    required this.memoryRepository,
  });

  final WorkoutRepository workoutRepository;
  final MemoryRepository memoryRepository;

  Future<Memory?> logSet({
    required String userId,
    required String exercise,
    required String? muscleGroup,
    required int targetReps,
    required LoggedSet loggedSet,
  }) async {
    await workoutRepository.saveLoggedSet(loggedSet);

    final feedbackText = loggedSet.feedbackText?.trim();

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

    final memory = MemoryExtractor.extract(event);

    if (memory == null) {
      return null;
    }

    await memoryRepository.save(memory);
    return memory;
  }
}
