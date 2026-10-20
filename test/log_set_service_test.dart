import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/memory.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/memory_repository.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/services/log_set_service.dart';
import 'package:fitness_recommendation/src/services/memory/memory_pipeline.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  final savedSets = <LoggedSet>[];

  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async {
    savedSets.add(loggedSet);
  }

  @override
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek) async =>
      [];

  @override
  Future<WorkoutPlan?> planById(String planId) async => null;

  @override
  Future<void> savePlan(WorkoutPlan plan) async {}

  @override
  Future<void> deletePlan(String planId) async {}

  @override
  Future<List<PlannedExercise>> exercisesForPlan(String planId) async => [];

  @override
  Future<PlannedExercise?> exerciseById(String exerciseId) async => null;

  @override
  Future<void> saveExercise(PlannedExercise exercise) async {}

  @override
  Future<void> deleteExercise(String exerciseId) async {}

  @override
  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId) async => [];

  @override
  Future<List<LoggedSet>> exerciseHistory(
    String exerciseId, {
    int? limit,
  }) async => [];
}

class FakeMemoryRepository implements MemoryRepository {
  final savedMemories = <Memory>[];

  @override
  Future<void> save(Memory memory) async {
    final index = savedMemories.indexWhere((item) => item.id == memory.id);

    if (index == -1) {
      savedMemories.add(memory);
    } else {
      savedMemories[index] = memory;
    }
  }

  @override
  Future<List<Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  }) async {
    return savedMemories
        .where(
          (memory) =>
              memory.userId == userId &&
              memory.exercise == exercise &&
              memory.status == MemoryStatus.ACTIVE &&
              memory.isUsable(now),
        )
        .toList();
  }

  @override
  Future<bool> archive(String id) async {
    final index = savedMemories.indexWhere((memory) => memory.id == id);

    if (index == -1) return false;

    savedMemories[index] = savedMemories[index].copyWith(
      status: MemoryStatus.ARCHIVED,
    );

    return true;
  }
}

class FailingWorkoutRepository extends FakeWorkoutRepository {
  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async {
    throw StateError('Could not save logged set');
  }
}

class FailingMemoryRepository extends FakeMemoryRepository {
  @override
  Future<void> save(Memory memory) async {
    throw StateError('Could not save memory');
  }
}

LogSetService createService({
  required FakeWorkoutRepository workoutRepository,
  required MemoryRepository memoryRepository,
}) {
  return LogSetService(
    workoutRepository: workoutRepository,
    memoryPipeline: MemoryPipeline(repo: memoryRepository),
  );
}

void main() {
  group('LogSetService', () {
    test('saves logged set and extracts fatigue memory', () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      final loggedAt = DateTime(2026, 10, 10, 18);

      final memory = await service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: LoggedSet(
          id: 'set-001',
          exerciseId: 'exercise-001',
          setIndex: 1,
          weight: 50,
          reps: 8,
          feedbackText: 'Mệt, không nổi',
          loggedAt: loggedAt,
        ),
      );

      expect(workoutRepository.savedSets, hasLength(1));
      expect(workoutRepository.savedSets.single.id, 'set-001');

      expect(memory, isNotNull);
      expect(memory!.userId, 'user-001');
      expect(memory.exercise, 'Bench Press');
      expect(memory.muscleGroup, 'Chest');
      expect(memory.type, MemoryType.USER_REPORTED_FATIGUE);

      expect(memoryRepository.savedMemories, hasLength(1));
      expect(memoryRepository.savedMemories.single.id, memory.id);
    });

    test('saves logged set without memory when feedback is null', () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      final result = await service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: LoggedSet(
          id: 'set-002',
          exerciseId: 'exercise-001',
          setIndex: 2,
          weight: 50,
          reps: 10,
          feedbackText: null,
          loggedAt: DateTime(2026, 10, 10, 18, 5),
        ),
      );

      expect(result, isNull);
      expect(workoutRepository.savedSets, hasLength(1));
      expect(memoryRepository.savedMemories, isEmpty);
    });

    test('does not create memory for normal feedback', () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      final result = await service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: LoggedSet(
          id: 'set-003',
          exerciseId: 'exercise-001',
          setIndex: 3,
          weight: 50,
          reps: 10,
          feedbackText: 'Cảm thấy tốt',
          loggedAt: DateTime(2026, 10, 10, 18, 10),
        ),
      );

      expect(result, isNull);
      expect(workoutRepository.savedSets, hasLength(1));
      expect(memoryRepository.savedMemories, isEmpty);
    });

    test('ignores whitespace-only feedback', () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      final result = await service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: LoggedSet(
          id: 'set-004',
          exerciseId: 'exercise-001',
          setIndex: 4,
          weight: 50,
          reps: 10,
          feedbackText: '   ',
          loggedAt: DateTime(2026, 10, 10, 18, 15),
        ),
      );

      expect(result, isNull);
      expect(workoutRepository.savedSets, hasLength(1));
      expect(memoryRepository.savedMemories, isEmpty);
    });

    test('does not create memory when saving logged set fails', () async {
      final workoutRepository = FailingWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      await expectLater(
        service.logSet(
          userId: 'user-001',
          exercise: 'Bench Press',
          muscleGroup: 'Chest',
          targetReps: 10,
          loggedSet: LoggedSet(
            id: 'set-005',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 8,
            feedbackText: 'Mệt, không nổi',
            loggedAt: DateTime(2026, 10, 10, 18, 20),
          ),
        ),
        throwsA(isA<StateError>()),
      );

      expect(memoryRepository.savedMemories, isEmpty);
    });

    test('returns null when memory storage fails', () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FailingMemoryRepository();

      final service = createService(
        workoutRepository: workoutRepository,
        memoryRepository: memoryRepository,
      );

      final result = await service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: LoggedSet(
          id: 'set-006',
          exerciseId: 'exercise-001',
          setIndex: 1,
          weight: 50,
          reps: 8,
          feedbackText: 'Mệt, không nổi',
          loggedAt: DateTime(2026, 10, 10, 18, 25),
        ),
      );

      expect(result, isNull);
      expect(workoutRepository.savedSets, hasLength(1));
      expect(workoutRepository.savedSets.single.id, 'set-006');
    });
  });
}
