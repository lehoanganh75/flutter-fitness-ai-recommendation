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

    if (row == null) return null;
    return _toWorkoutPlan(row);
  }

  @override
  Future<domain.WorkoutPlan?> planByScheduledDate(
    String userId,
    DateTime date,
  ) async {
    final query = database.select(database.workoutPlans)
      ..where((table) => table.userId.equals(userId))
      ..where((table) => table.scheduledDate.equals(date))
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
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
            scheduledDate: Value(plan.scheduledDate),
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
    if (row == null) return null;
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
  Future<void> deletePlan(String planId) async {
    await database.transaction(() async {
      final exercises = await (database.select(
        database.plannedExercises,
      )..where((table) => table.planId.equals(planId))).get();
      for (final exercise in exercises) {
        await (database.delete(
          database.loggedSets,
        )..where((table) => table.exerciseId.equals(exercise.id))).go();
      }
      await (database.delete(
        database.plannedExercises,
      )..where((table) => table.planId.equals(planId))).go();
      await (database.delete(
        database.workoutPlans,
      )..where((table) => table.id.equals(planId))).go();
    });
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {
    await database.transaction(() async {
      await (database.delete(
        database.loggedSets,
      )..where((table) => table.exerciseId.equals(exerciseId))).go();
      await (database.delete(
        database.plannedExercises,
      )..where((table) => table.id.equals(exerciseId))).go();
    });
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

    if (limit != null) query.limit(limit);

    final rows = await query.get();
    return rows.map(_toLoggedSet).toList();
  }

  @override
  Future<domain.LoggedSet?> latestSetForExerciseName(
    String userId,
    String exerciseName,
  ) async {
    final query =
        database.select(database.loggedSets).join([
            innerJoin(
              database.plannedExercises,
              database.plannedExercises.id.equalsExp(
                database.loggedSets.exerciseId,
              ),
            ),
            innerJoin(
              database.workoutPlans,
              database.workoutPlans.id.equalsExp(
                database.plannedExercises.planId,
              ),
            ),
          ])
          ..where(database.workoutPlans.userId.equals(userId))
          ..where(
            database.plannedExercises.exercise.lower().equals(
              exerciseName.trim().toLowerCase(),
            ),
          )
          ..orderBy([OrderingTerm.desc(database.loggedSets.loggedAt)])
          ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _toLoggedSet(row.readTable(database.loggedSets));
  }

  Future<void> updateProgressCache(String userId, String exerciseName) async {
    final query =
        database.select(database.loggedSets).join([
            innerJoin(
              database.plannedExercises,
              database.plannedExercises.id.equalsExp(
                database.loggedSets.exerciseId,
              ),
            ),
            innerJoin(
              database.workoutPlans,
              database.workoutPlans.id.equalsExp(
                database.plannedExercises.planId,
              ),
            ),
          ])
          ..where(database.workoutPlans.userId.equals(userId))
          ..where(database.plannedExercises.exercise.equals(exerciseName));

    final rows = await query.get();
    if (rows.isEmpty) return;

    double topWeight = 0;
    int topReps = 0;
    DateTime lastDate = DateTime(2000);
    for (final row in rows) {
      final set = row.readTable(database.loggedSets);
      if (set.weight > topWeight) {
        topWeight = set.weight;
        topReps = set.reps;
      }
      if (set.loggedAt.isAfter(lastDate)) {
        lastDate = set.loggedAt;
      }
    }

    await database
        .into(database.exerciseProgressCaches)
        .insertOnConflictUpdate(
          data.ExerciseProgressCachesCompanion.insert(
            userId: userId,
            exerciseName: exerciseName,
            lastTrainedDate: lastDate,
            topWeight: topWeight,
            topReps: topReps,
            totalSets: rows.length,
          ),
        );
  }

  Future<List<data.ExerciseProgressCache>> getAllProgressCache(
    String userId,
  ) async {
    final query = database.select(database.exerciseProgressCaches)
      ..where((t) => t.userId.equals(userId));
    return await query.get();
  }

  domain.WorkoutPlan _toWorkoutPlan(data.WorkoutPlan row) {
    return domain.WorkoutPlan(
      id: row.id,
      userId: row.userId,
      title: row.title,
      dayOfWeek: row.dayOfWeek,
      createdAt: row.createdAt,
      scheduledDate: row.scheduledDate,
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

  Future<void> saveAiSuggestionCache(String cacheKey, String jsonData) async {
    await database
        .into(database.aiSuggestionCaches)
        .insertOnConflictUpdate(
          data.AiSuggestionCachesCompanion.insert(
            cacheKey: cacheKey,
            jsonData: jsonData,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<String?> getAiSuggestionCache(String cacheKey) async {
    final query = database.select(database.aiSuggestionCaches)
      ..where((t) => t.cacheKey.equals(cacheKey));
    final row = await query.getSingleOrNull();
    return row?.jsonData;
  }
}
