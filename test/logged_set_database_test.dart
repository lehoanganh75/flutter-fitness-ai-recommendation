import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/data/database.dart';

void main() {
  test('stores logged set with feedback', () async {
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

    await database
        .into(database.loggedSets)
        .insert(
          LoggedSetsCompanion.insert(
            id: 'set-001',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 8,
            feedbackText: const Value('Mệt, không nổi'),
            loggedAt: DateTime(2026, 10, 10, 18),
            syncStatus: 'pending',
          ),
        );

    final rows = await database.select(database.loggedSets).get();

    expect(rows, hasLength(1));
    expect(rows.single.id, 'set-001');
    expect(rows.single.exerciseId, 'exercise-001');
    expect(rows.single.setIndex, 1);
    expect(rows.single.weight, 50.0);
    expect(rows.single.reps, 8);
    expect(rows.single.feedbackText, 'Mệt, không nổi');
    expect(rows.single.syncStatus, 'pending');

    await database.close();
  });
}
