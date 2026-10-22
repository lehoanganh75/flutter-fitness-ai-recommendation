import 'package:fitness_recommendation/src/domain/models/workout.dart';

abstract interface class WorkoutRepository {
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek);

  Future<WorkoutPlan?> planById(String planId);

  Future<void> savePlan(WorkoutPlan plan);

  Future<void> deletePlan(String planId);

  Future<List<PlannedExercise>> exercisesForPlan(String planId);

  Future<PlannedExercise?> exerciseById(String exerciseId);

  Future<void> saveExercise(PlannedExercise exercise);

  Future<void> deleteExercise(String exerciseId);

  Future<void> saveLoggedSet(LoggedSet loggedSet);

  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId);

  Future<List<LoggedSet>> exerciseHistory(String exerciseId, {int? limit});

  Future<WorkoutPlan?> planByScheduledDate(String userId, DateTime date);

  Future<LoggedSet?> latestSetForExerciseName(
    String userId,
    String exerciseName,
  );
}
