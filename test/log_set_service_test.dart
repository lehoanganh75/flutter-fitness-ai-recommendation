import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/memory.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/memory_repository.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/services/log_set_service.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  final savedSets = <LoggedSet>[];

  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async {
    savedSets.add(loggedSet);
  }

  @override
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek) async {
    return [];
  }

  @override
  Future<WorkoutPlan?> planById(String planId) async {
    return null;
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {}

  @override
  Future<List<PlannedExercise>> exercisesForPlan(String planId) async {
    return [];
  }

  @override
  Future<PlannedExercise?> exerciseById(String exerciseId) async {
    return null;
  }

  @override
  Future<void> saveExercise(PlannedExercise exercise) async {}

  @override
  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId) async {
    return [];
  }

  @override
  Future<List<LoggedSet>> exerciseHistory(
    String exerciseId, {
    int? limit,
  }) async {
    return [];
  }
}

class FakeMemoryRepository implements MemoryRepository {
  final savedMemories = <Memory>[];

  @override
  Future<void> save(Memory memory) async {
    savedMemories.add(memory);
  }

  @override
  Future<List<Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  }) async {
    return [];
  }

  @override
  Future<bool> archive(String id) async {
    return false;
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

void main() {
  test('saves logged set and extracts fatigue memory', () async {
    final workoutRepository = FakeWorkoutRepository();
    final memoryRepository = FakeMemoryRepository();

    final service = LogSetService(
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
    expect(memory?.userId, 'user-001');
    expect(memory?.exercise, 'Bench Press');
    expect(memory?.muscleGroup, 'Chest');
    expect(memory?.type, MemoryType.USER_REPORTED_FATIGUE);

    expect(memoryRepository.savedMemories, hasLength(1));
    expect(memoryRepository.savedMemories.single.id, memory?.id);
  });
  test(
    'saves logged set without creating memory when feedback is empty',
    () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = LogSetService(
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
      expect(workoutRepository.savedSets.single.id, 'set-002');
      expect(memoryRepository.savedMemories, isEmpty);
    },
  );

  test(
    'saves logged set without creating memory for normal feedback',
    () async {
      final workoutRepository = FakeWorkoutRepository();
      final memoryRepository = FakeMemoryRepository();

      final service = LogSetService(
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
      expect(workoutRepository.savedSets.single.id, 'set-003');
      expect(memoryRepository.savedMemories, isEmpty);
    },
  );
  test('ignores whitespace-only feedback', () async {
    final workoutRepository = FakeWorkoutRepository();
    final memoryRepository = FakeMemoryRepository();

    final service = LogSetService(
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
    expect(workoutRepository.savedSets.single.id, 'set-004');
    expect(memoryRepository.savedMemories, isEmpty);
  });
  test('does not create memory when saving logged set fails', () async {
    final workoutRepository = FailingWorkoutRepository();
    final memoryRepository = FakeMemoryRepository();

    final service = LogSetService(
      workoutRepository: workoutRepository,
      memoryRepository: memoryRepository,
    );

    expect(
      () => service.logSet(
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
  test('propagates error when saving memory fails', () async {
    final workoutRepository = FakeWorkoutRepository();
    final memoryRepository = FailingMemoryRepository();

    final service = LogSetService(
      workoutRepository: workoutRepository,
      memoryRepository: memoryRepository,
    );

    final loggedSet = LoggedSet(
      id: 'set-006',
      exerciseId: 'exercise-001',
      setIndex: 1,
      weight: 50,
      reps: 8,
      feedbackText: 'Mệt, không nổi',
      loggedAt: DateTime(2026, 10, 10, 18, 25),
    );

    await expectLater(
      service.logSet(
        userId: 'user-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetReps: 10,
        loggedSet: loggedSet,
      ),
      throwsA(isA<StateError>()),
    );

    expect(workoutRepository.savedSets, hasLength(1));
    expect(workoutRepository.savedSets.single.id, 'set-006');
  });
}
