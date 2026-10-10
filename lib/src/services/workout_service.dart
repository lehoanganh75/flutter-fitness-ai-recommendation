import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';

class WorkoutService {
  const WorkoutService(this.repository);

  final WorkoutRepository repository;

  Future<TodayWorkout?> loadTodayWorkout({
    required String userId,
    required int dayOfWeek,
  }) async {
    final plans = await repository.plansForDay(userId, dayOfWeek);

    if (plans.isEmpty) {
      return null;
    }

    final plan = plans.first;
    final exercises = [...await repository.exercisesForPlan(plan.id)]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final loggedSetsByExercise = <String, List<LoggedSet>>{};

    for (final exercise in exercises) {
      loggedSetsByExercise[exercise.id] = await repository
          .loggedSetsForExercise(exercise.id);
    }

    return TodayWorkout(
      plan: plan,
      exercises: exercises,
      loggedSetsByExercise: loggedSetsByExercise,
    );
  }
}
