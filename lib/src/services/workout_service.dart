import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';

class WorkoutPlanDetails {
  const WorkoutPlanDetails({
    required this.plan,
    required this.exercises,
  });

  final WorkoutPlan plan;
  final List<PlannedExercise> exercises;
}

class WorkoutService {
  const WorkoutService(this.repository);

  final WorkoutRepository repository;

  Future<List<WorkoutPlanDetails>> loadPlansForDay({
    required String userId,
    required int dayOfWeek,
  }) async {
    final plans = await repository.plansForDay(userId, dayOfWeek);
    final details = <WorkoutPlanDetails>[];
    for (final plan in plans) {
      final exercises = [...await repository.exercisesForPlan(plan.id)]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      details.add(WorkoutPlanDetails(plan: plan, exercises: exercises));
    }
    return details;
  }

  Future<TodayWorkout?> loadTodayWorkout({
    required String userId,
    required int dayOfWeek,
  }) async {
    final plans = await loadPlansForDay(
      userId: userId,
      dayOfWeek: dayOfWeek,
    );

    if (plans.isEmpty) {
      return null;
    }

    // Gộp tất cả exercises từ TẤT CẢ các kế hoạch của ngày này
    // (không chỉ lấy plan đầu tiên như trước)
    final allExercises = <PlannedExercise>[];
    final loggedSetsByExercise = <String, List<LoggedSet>>{};

    for (final details in plans) {
      final exercises = details.exercises;
      for (final exercise in exercises) {
        allExercises.add(exercise);
        loggedSetsByExercise[exercise.id] = await repository
            .loggedSetsForExercise(exercise.id);
      }
    }

    // Sắp xếp theo sortOrder để giữ thứ tự bài tập
    allExercises.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // Dùng plan đầu tiên làm plan chính (hiển thị title)
    final mainPlan = plans.first.plan;

    return TodayWorkout(
      plan: mainPlan,
      exercises: allExercises,
      loggedSetsByExercise: loggedSetsByExercise,
    );
  }
}
