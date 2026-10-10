import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart' as data;
import 'package:fitness_recommendation/src/data/drift_workout_repository.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart'
    as domain;

void main() {
  late data.AppDatabase database;
  late DriftWorkoutRepository repository;

  setUp(() {
    database = data.AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and retrieves plan for a day', () async {
    await repository.savePlan(
      domain.WorkoutPlan(
        id: 'plan-001',
        userId: 'user-001',
        title: 'Push Day',
        dayOfWeek: 1,
        createdAt: DateTime(2026, 10, 10),
      ),
    );

    final plans = await repository.plansForDay('user-001', 1);

    expect(plans, hasLength(1));
    expect(plans.single.id, 'plan-001');
    expect(plans.single.title, 'Push Day');
    expect(plans.single.syncStatus, domain.SyncStatus.pending);
  });

  test('saves and retrieves exercises in sort order', () async {
    await repository.saveExercise(
      domain.PlannedExercise(
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
      domain.PlannedExercise(
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

  test('saves and retrieves logged set history', () async {
    await repository.saveLoggedSet(
      domain.LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 8,
        loggedAt: DateTime(2026, 10, 10, 18),
      ),
    );

    await repository.saveLoggedSet(
      domain.LoggedSet(
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
