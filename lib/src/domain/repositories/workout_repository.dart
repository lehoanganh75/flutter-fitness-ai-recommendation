import 'package:fitness_recommendation/domain/workout.dart';

abstract interface class WorkoutRepository {
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek);

  Future<WorkoutPlan?> planById(String planId);

  Future<void> savePlan(WorkoutPlan plan);

  Future<List<PlannedExercise>> exercisesForPlan(String planId);

  Future<PlannedExercise?> exerciseById(String exerciseId);

  Future<void> saveExercise(PlannedExercise exercise);

  Future<void> saveLoggedSet(LoggedSet loggedSet);

  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId);

  Future<List<LoggedSet>> exerciseHistory(String exerciseId, {int? limit});
}
