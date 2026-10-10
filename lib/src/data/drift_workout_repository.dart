import 'package:drift/drift.dart';

import 'package:fitness_recommendation/src/domain/models/workout.dart'
    as domain;
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';

import 'database.dart' as data;

class DriftWorkoutRepository implements WorkoutRepository {
  const DriftWorkoutRepository(this.database);

  final data.AppDatabase database;

  @override
  Future<List<domain.WorkoutPlan>> plansForDay(
    String userId,
    int dayOfWeek,
  ) async {
    final rows =
        await (database.select(database.workoutPlans)
              ..where(
                (table) =>
                    table.userId.equals(userId) &
                    table.dayOfWeek.equals(dayOfWeek),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();

    return rows.map(_toWorkoutPlan).toList();
  }

  @override
  Future<domain.WorkoutPlan?> planById(String planId) async {
    final query = database.select(database.workoutPlans)
      ..where((table) => table.id.equals(planId));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toWorkoutPlan(row);
  }

  @override
  Future<void> savePlan(domain.WorkoutPlan plan) async {
    await database
        .into(database.workoutPlans)
        .insertOnConflictUpdate(
          data.WorkoutPlansCompanion.insert(
            id: plan.id,
            userId: plan.userId,
            title: plan.title,
            dayOfWeek: plan.dayOfWeek,
            createdAt: plan.createdAt,
            syncStatus: plan.syncStatus.name,
          ),
        );
  }

  @override
  Future<List<domain.PlannedExercise>> exercisesForPlan(String planId) async {
    final rows =
        await (database.select(database.plannedExercises)
              ..where((table) => table.planId.equals(planId))
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();

    return rows.map(_toPlannedExercise).toList();
  }

  @override
  Future<domain.PlannedExercise?> exerciseById(String exerciseId) async {
    final query = database.select(database.plannedExercises)
      ..where((table) => table.id.equals(exerciseId));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toPlannedExercise(row);
  }

  @override
  Future<void> saveExercise(domain.PlannedExercise exercise) async {
    await database
        .into(database.plannedExercises)
        .insertOnConflictUpdate(
          data.PlannedExercisesCompanion.insert(
            id: exercise.id,
            planId: exercise.planId,
            exercise: exercise.exercise,
            muscleGroup: exercise.muscleGroup,
            sortOrder: exercise.sortOrder,
            targetSets: exercise.targetSets,
            targetReps: exercise.targetReps,
            initialWeight: exercise.initialWeight,
            syncStatus: exercise.syncStatus.name,
          ),
        );
  }

  @override
  Future<void> saveLoggedSet(domain.LoggedSet loggedSet) async {
    await database
        .into(database.loggedSets)
        .insertOnConflictUpdate(
          data.LoggedSetsCompanion.insert(
            id: loggedSet.id,
            exerciseId: loggedSet.exerciseId,
            setIndex: loggedSet.setIndex,
            weight: loggedSet.weight,
            reps: loggedSet.reps,
            feedbackText: Value(loggedSet.feedbackText),
            loggedAt: loggedSet.loggedAt,
            syncStatus: loggedSet.syncStatus.name,
          ),
        );
  }

  @override
  Future<List<domain.LoggedSet>> loggedSetsForExercise(
    String exerciseId,
  ) async {
    final rows =
        await (database.select(database.loggedSets)
              ..where((table) => table.exerciseId.equals(exerciseId))
              ..orderBy([(table) => OrderingTerm.asc(table.setIndex)]))
            .get();

    return rows.map(_toLoggedSet).toList();
  }

  @override
  Future<List<domain.LoggedSet>> exerciseHistory(
    String exerciseId, {
    int? limit,
  }) async {
    final query = database.select(database.loggedSets)
      ..where((table) => table.exerciseId.equals(exerciseId))
      ..orderBy([(table) => OrderingTerm.desc(table.loggedAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    final rows = await query.get();

    return rows.map(_toLoggedSet).toList();
  }

  domain.WorkoutPlan _toWorkoutPlan(data.WorkoutPlan row) {
    return domain.WorkoutPlan(
      id: row.id,
      userId: row.userId,
      title: row.title,
      dayOfWeek: row.dayOfWeek,
      createdAt: row.createdAt,
      syncStatus: domain.SyncStatus.values.byName(row.syncStatus),
    );
  }

  domain.PlannedExercise _toPlannedExercise(data.PlannedExercise row) {
    return domain.PlannedExercise(
      id: row.id,
      planId: row.planId,
      exercise: row.exercise,
      muscleGroup: row.muscleGroup,
      sortOrder: row.sortOrder,
      targetSets: row.targetSets,
      targetReps: row.targetReps,
      initialWeight: row.initialWeight,
      syncStatus: domain.SyncStatus.values.byName(row.syncStatus),
    );
  }

  domain.LoggedSet _toLoggedSet(data.LoggedSet row) {
    return domain.LoggedSet(
      id: row.id,
      exerciseId: row.exerciseId,
      setIndex: row.setIndex,
      weight: row.weight,
      reps: row.reps,
      feedbackText: row.feedbackText,
      loggedAt: row.loggedAt,
      syncStatus: domain.SyncStatus.values.byName(row.syncStatus),
    );
  }
}
