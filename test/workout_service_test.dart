import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/services/workout_service.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  final plans = <WorkoutPlan>[];
  final exercises = <PlannedExercise>[];
  final loggedSets = <LoggedSet>[];

  @override
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek) async {
    return plans
        .where((plan) => plan.userId == userId && plan.dayOfWeek == dayOfWeek)
        .toList();
  }

  @override
  Future<WorkoutPlan?> planById(String planId) async {
    for (final plan in plans) {
      if (plan.id == planId) {
        return plan;
      }
    }

    return null;
  }

  @override
  Future<void> savePlan(WorkoutPlan plan) async {
    plans.add(plan);
  }

  @override
  Future<List<PlannedExercise>> exercisesForPlan(String planId) async {
    return exercises.where((exercise) => exercise.planId == planId).toList();
  }

  @override
  Future<PlannedExercise?> exerciseById(String exerciseId) async {
    for (final exercise in exercises) {
      if (exercise.id == exerciseId) {
        return exercise;
      }
    }

    return null;
  }

  @override
  Future<void> saveExercise(PlannedExercise exercise) async {
    exercises.add(exercise);
  }

  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async {
    loggedSets.add(loggedSet);
  }

  @override
  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId) async {
    return loggedSets
        .where((loggedSet) => loggedSet.exerciseId == exerciseId)
        .toList();
  }

  @override
  Future<List<LoggedSet>> exerciseHistory(
    String exerciseId, {
    int? limit,
  }) async {
    return loggedSets
        .where((loggedSet) => loggedSet.exerciseId == exerciseId)
        .toList();
  }
}

void main() {
  test('loads today workout with exercises and logged sets', () async {
    final repository = FakeWorkoutRepository();

    repository.plans.add(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    repository.exercises.add(
      PlannedExercise(
        id: 'exercise-001',
        planId: 'plan-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        sortOrder: 1,
        targetSets: 3,
        targetReps: 10,
        initialWeight: 50,
      ),
    );

    repository.loggedSets.add(
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 8,
        feedbackText: 'Mệt, không nổi',
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
    );

    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNotNull);
    expect(result?.plan.title, 'Push Day');
    expect(result?.exercises, hasLength(1));
    expect(result?.exercises.single.exercise, 'Bench Press');
    expect(result?.muscleGroups, ['Chest']);
    expect(result?.loggedSetsByExercise['exercise-001'], hasLength(1));
    expect(result?.loggedSetsByExercise['exercise-001']?.single.id, 'set-001');
    expect(result?.loggedSetsByExercise['exercise-001']?.single.reps, 8);
    expect(result?.muscleGroups, ['Chest']);
    expect(result?.loggedSetsByExercise['exercise-001'], hasLength(1));
    expect(result?.loggedSetsByExercise['exercise-001']?.single.id, 'set-001');
    expect(result?.loggedSetsByExercise['exercise-001']?.single.reps, 8);

    final workout = result!;

    final activeExercise = workout.activeExercise(
      loggedSetsByExercise: workout.loggedSetsByExercise,
    );

    expect(activeExercise?.id, 'exercise-001');

    final progress = workout.activeProgress(
      loggedSetsByExercise: workout.loggedSetsByExercise,
    );

    expect(progress, isNotNull);
    expect(progress?.completedSets, 1);
    expect(progress?.totalSets, 3);
    expect(progress?.currentSet, 2);
    expect(progress?.isCompleted, false);

    final currentWeight = workout.currentWeightFor(
      exercise: workout.exercises.single,
      loggedSetsByExercise: workout.loggedSetsByExercise,
    );

    expect(currentWeight, 50);
  });

  test('returns null when there is no workout for the day', () async {
    final repository = FakeWorkoutRepository();
    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNull);
  });
  test('selects the next exercise after the first one is completed', () async {
    final repository = FakeWorkoutRepository();

    repository.plans.add(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    repository.exercises.addAll([
      PlannedExercise(
        id: 'exercise-001',
        planId: 'plan-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        sortOrder: 1,
        targetSets: 2,
        targetReps: 10,
        initialWeight: 50,
      ),
      PlannedExercise(
        id: 'exercise-002',
        planId: 'plan-001',
        exercise: 'Shoulder Press',
        muscleGroup: 'Shoulder',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 8,
        initialWeight: 20,
      ),
    ]);

    repository.loggedSets.addAll([
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
      LoggedSet(
        id: 'set-002',
        exerciseId: 'exercise-001',
        setIndex: 2,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18, 5),
      ),
    ]);

    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNotNull);
    expect(result!.exercises, hasLength(2));

    final activeExercise = result.activeExercise(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(activeExercise, isNotNull);
    expect(activeExercise!.id, 'exercise-002');
    expect(activeExercise.exercise, 'Shoulder Press');

    final progress = result.activeProgress(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(progress, isNotNull);
    expect(progress!.completedSets, 0);
    expect(progress.totalSets, 3);
    expect(progress.currentSet, 1);
    expect(progress.isCompleted, false);
  });
  test('selects the next exercise after the first one is completed', () async {
    final repository = FakeWorkoutRepository();

    repository.plans.add(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    repository.exercises.addAll([
      PlannedExercise(
        id: 'exercise-001',
        planId: 'plan-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        sortOrder: 1,
        targetSets: 2,
        targetReps: 10,
        initialWeight: 50,
      ),
      PlannedExercise(
        id: 'exercise-002',
        planId: 'plan-001',
        exercise: 'Shoulder Press',
        muscleGroup: 'Shoulder',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 8,
        initialWeight: 20,
      ),
    ]);

    repository.loggedSets.addAll([
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
      LoggedSet(
        id: 'set-002',
        exerciseId: 'exercise-001',
        setIndex: 2,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18, 5),
      ),
    ]);

    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNotNull);
    expect(result!.exercises, hasLength(2));

    final activeExercise = result.activeExercise(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(activeExercise, isNotNull);
    expect(activeExercise!.id, 'exercise-002');
    expect(activeExercise.exercise, 'Shoulder Press');

    final progress = result.activeProgress(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(progress, isNotNull);
    expect(progress!.completedSets, 0);
    expect(progress.totalSets, 3);
    expect(progress.currentSet, 1);
    expect(progress.isCompleted, false);
  });
  test('returns no active exercise when all exercises are completed', () async {
    final repository = FakeWorkoutRepository();

    repository.plans.add(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    repository.exercises.add(
      PlannedExercise(
        id: 'exercise-001',
        planId: 'plan-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        sortOrder: 1,
        targetSets: 2,
        targetReps: 10,
        initialWeight: 50,
      ),
    );

    repository.loggedSets.addAll([
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
      LoggedSet(
        id: 'set-002',
        exerciseId: 'exercise-001',
        setIndex: 2,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 18, 5),
      ),
    ]);

    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNotNull);

    final activeExercise = result!.activeExercise(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(activeExercise, isNull);

    final progress = result.activeProgress(
      loggedSetsByExercise: result.loggedSetsByExercise,
    );

    expect(progress, isNull);
  });
  test('sorts exercises by sort order', () async {
    final repository = FakeWorkoutRepository();

    repository.plans.add(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    repository.exercises.addAll([
      PlannedExercise(
        id: 'exercise-002',
        planId: 'plan-001',
        exercise: 'Shoulder Press',
        muscleGroup: 'Shoulder',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 8,
        initialWeight: 20,
      ),
      PlannedExercise(
        id: 'exercise-001',
        planId: 'plan-001',
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        sortOrder: 1,
        targetSets: 3,
        targetReps: 10,
        initialWeight: 50,
      ),
    ]);

    final service = WorkoutService(repository);

    final result = await service.loadTodayWorkout(
      userId: 'user-001',
      dayOfWeek: 1,
    );

    expect(result, isNotNull);
    expect(result!.exercises, hasLength(2));
    expect(result.exercises[0].id, 'exercise-001');
    expect(result.exercises[0].sortOrder, 1);
    expect(result.exercises[1].id, 'exercise-002');
    expect(result.exercises[1].sortOrder, 2);
  });
}
