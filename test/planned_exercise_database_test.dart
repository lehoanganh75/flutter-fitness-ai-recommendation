import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart';

void main() {
  test('stores planned exercise inside workout plan', () async {
    final database = AppDatabase(NativeDatabase.memory());

    await database
        .into(database.workoutPlans)
        .insert(
          WorkoutPlansCompanion.insert(
            id: 'plan-001',
            userId: 'user-001',
            title: 'Push Day',
            dayOfWeek: 1,
            createdAt: DateTime(2026, 10, 10),
            syncStatus: 'pending',
          ),
        );

    await database
        .into(database.plannedExercises)
        .insert(
          PlannedExercisesCompanion.insert(
            id: 'exercise-001',
            planId: 'plan-001',
            exercise: 'Bench Press',
            muscleGroup: 'Chest',
            sortOrder: 1,
            targetSets: 3,
            targetReps: 10,
            initialWeight: 50,
            syncStatus: 'pending',
          ),
        );

    final rows = await database.select(database.plannedExercises).get();

    expect(rows, hasLength(1));
    expect(rows.single.id, 'exercise-001');
    expect(rows.single.planId, 'plan-001');
    expect(rows.single.exercise, 'Bench Press');
    expect(rows.single.muscleGroup, 'Chest');
    expect(rows.single.sortOrder, 1);
    expect(rows.single.targetSets, 3);
    expect(rows.single.targetReps, 10);
    expect(rows.single.initialWeight, 50.0);
    expect(rows.single.syncStatus, 'pending');

    await database.close();
  });
}
