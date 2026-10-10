import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';

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
    plans.removeWhere((item) => item.id == plan.id);
    plans.add(plan);
  }

  @override
  Future<List<PlannedExercise>> exercisesForPlan(String planId) async {
    return exercises.where((exercise) => exercise.planId == planId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
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
    exercises.removeWhere((item) => item.id == exercise.id);
    exercises.add(exercise);
  }

  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async {
    loggedSets.removeWhere((item) => item.id == loggedSet.id);
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
    final result =
        loggedSets
            .where((loggedSet) => loggedSet.exerciseId == exerciseId)
            .toList()
          ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    if (limit == null) {
      return result;
    }

    return result.take(limit).toList();
  }
}

void main() {
  test('saves and retrieves a workout plan for a day', () async {
    final repository = FakeWorkoutRepository();

    await repository.savePlan(
      WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    final plans = await repository.plansForDay('user-001', 1);

    expect(plans, hasLength(1));
    expect(plans.single.title, 'Push Day');
  });

  test('returns exercises in sort order', () async {
    final repository = FakeWorkoutRepository();

    await repository.saveExercise(
      PlannedExercise(
        id: 'exercise-002',
        planId: 'plan-001',
        exercise: 'Shoulder Press',
        muscleGroup: 'Shoulder',
        sortOrder: 2,
        targetSets: 3,
        targetReps: 10,
        initialWeight: 25,
      ),
    );

    await repository.saveExercise(
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

    final exercises = await repository.exercisesForPlan('plan-001');

    expect(exercises, hasLength(2));
    expect(exercises.first.exercise, 'Bench Press');
    expect(exercises.last.exercise, 'Shoulder Press');
  });

  test('returns exercise history newest first with limit', () async {
    final repository = FakeWorkoutRepository();

    await repository.saveLoggedSet(
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 8,
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
    );

    await repository.saveLoggedSet(
      LoggedSet(
        id: 'set-002',
        exerciseId: 'exercise-001',
        setIndex: 2,
        weight: 40,
        reps: 10,
        loggedAt: DateTime(2026, 10, 10, 19),
      ),
    );

    final history = await repository.exerciseHistory('exercise-001', limit: 1);

    expect(history, hasLength(1));
    expect(history.single.id, 'set-002');
    expect(history.single.weight, 40);
  });
}
