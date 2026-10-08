import 'workout.dart';
import 'workout_progress.dart';

class TodayWorkout {
  const TodayWorkout({required this.plan, required this.exercises});

  final WorkoutPlan plan;
  final List<PlannedExercise> exercises;

  List<String> get muscleGroups {
    return exercises.map((exercise) => exercise.muscleGroup).toSet().toList();
  }

  PlannedExercise? activeExercise({
    required Map<String, List<LoggedSet>> loggedSetsByExercise,
  }) {
    final sortedExercises = [...exercises]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    for (final exercise in sortedExercises) {
      final loggedSets = loggedSetsByExercise[exercise.id] ?? const [];

      if (loggedSets.length < exercise.targetSets) {
        return exercise;
      }
    }

    return null;
  }

  WorkoutProgress? activeProgress({
    required Map<String, List<LoggedSet>> loggedSetsByExercise,
  }) {
    final exercise = activeExercise(loggedSetsByExercise: loggedSetsByExercise);

    if (exercise == null) {
      return null;
    }

    return WorkoutProgress.fromExercise(
      targetSets: exercise.targetSets,
      loggedSets: loggedSetsByExercise[exercise.id] ?? const [],
    );
  }

  double currentWeightFor({
    required PlannedExercise exercise,
    required Map<String, List<LoggedSet>> loggedSetsByExercise,
  }) {
    final loggedSets = loggedSetsByExercise[exercise.id] ?? const [];

    if (loggedSets.isEmpty) {
      return exercise.initialWeight;
    }

    final latestSet = loggedSets.reduce((current, next) {
      return next.loggedAt.isAfter(current.loggedAt) ? next : current;
    });

    return latestSet.weight;
  }
}
