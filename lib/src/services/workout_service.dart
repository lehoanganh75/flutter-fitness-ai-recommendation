import 'package:fitness_recommendation/src/domain/models/daily_suggestion.dart';
import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';

class WorkoutPlanDetails {
  const WorkoutPlanDetails({required this.plan, required this.exercises});

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
    DateTime? today,
  }) async {
    final target = today ?? DateTime.now();
    final dateOnly = DateTime(target.year, target.month, target.day);

    final byDate = await repository.planByScheduledDate(userId, dateOnly);
    final plans = byDate != null
        ? [byDate]
        : (await loadPlansForDay(
            userId: userId,
            dayOfWeek: dayOfWeek,
          )).map((d) => d.plan).toList();

    if (plans.isEmpty) {
      return null;
    }

    final allExercises = <PlannedExercise>[];
    final loggedSetsByExercise = <String, List<LoggedSet>>{};

    for (final plan in plans) {
      final exercises = [...await repository.exercisesForPlan(plan.id)]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      for (final exercise in exercises) {
        allExercises.add(exercise);
        loggedSetsByExercise[exercise.id] = await repository
            .loggedSetsForExercise(exercise.id);
      }
    }

    allExercises.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return TodayWorkout(
      plan: plans.first,
      exercises: allExercises,
      loggedSetsByExercise: loggedSetsByExercise,
    );
  }

  Future<void> applySuggestionToToday({
    required String userId,
    required List<SuggestedExercise> exercises,
    required DateTime today,
  }) async {
    final dateOnly = DateTime(today.year, today.month, today.day);

    var plan = await repository.planByScheduledDate(userId, dateOnly);
    if (plan == null) {
      final byDay = await repository.plansForDay(userId, today.weekday);
      if (byDay.isNotEmpty) {
        plan = byDay.first;
      }
    }

    if (plan == null) {
      plan = WorkoutPlan(
        id: 'ai-plan-${today.millisecondsSinceEpoch}',
        userId: userId,
        title: 'AI gợi ý ${today.day}/${today.month}',
        dayOfWeek: today.weekday,
        createdAt: today,
        scheduledDate: dateOnly,
      );
      await repository.savePlan(plan);
    }

    final existing = await repository.exercisesForPlan(plan.id);
    final existingNames = existing.map((e) => e.exercise.toLowerCase()).toSet();
    var nextOrder = existing.isEmpty
        ? 1
        : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    for (final s in exercises) {
      if (existingNames.contains(s.name.toLowerCase())) continue;

      final defaults = await _resolveDefaults(userId, s.name, existing);

      final finalSets = (s.sets > 0) ? s.sets : defaults.sets;
      final finalReps = (s.reps > 0) ? s.reps : defaults.reps;
      final finalWeight = (s.weight > 0) ? s.weight : defaults.weight;

      final exercise = PlannedExercise(
        id: '${plan.id}-ai-$nextOrder',
        planId: plan.id,
        exercise: s.name,
        muscleGroup: defaults.muscleGroup,
        sortOrder: nextOrder,
        targetSets: finalSets,
        targetReps: finalReps,
        initialWeight: finalWeight,
      );
      await repository.saveExercise(exercise);
      nextOrder++;
    }
  }

  Future<({int sets, int reps, double weight, String muscleGroup})>
  _resolveDefaults(
    String userId,
    String name,
    List<PlannedExercise> existing,
  ) async {
    String muscleGroup = 'Chest'; // Mặc định nếu không tìm thấy

    for (final e in existing) {
      if (e.exercise.toLowerCase() == name.toLowerCase()) {
        muscleGroup = e.muscleGroup;
        break;
      }
    }

    final lastSet = await repository.latestSetForExerciseName(userId, name);
    if (lastSet != null) {
      return (
        sets: lastSet.setIndex,
        reps: lastSet.reps,
        weight: lastSet.weight,
        muscleGroup: muscleGroup,
      );
    }

    // IN RA MÀN HÌNH ĐỂ DEBUG XEM NHÓM CƠ ĐANG LƯU LÀ GÌ
    print('DEBUG AI: Bài $name thuộc nhóm cơ: "$muscleGroup"');

    double defaultWeight = 20.0;
    final mg = muscleGroup.toLowerCase();

    if (mg.contains('leg') ||
        mg.contains('chân') ||
        mg.contains('squat') ||
        mg.contains('đùi')) {
      defaultWeight = 40.0;
    } else if (mg.contains('back') ||
        mg.contains('lưng') ||
        mg.contains('xô') ||
        mg.contains('row') ||
        mg.contains('deadlift')) {
      defaultWeight = 30.0;
    } else if (mg.contains('bicep') ||
        mg.contains('tay') ||
        mg.contains('forearm') ||
        mg.contains('curl')) {
      defaultWeight = 10.0;
    }

    return (sets: 3, reps: 10, weight: defaultWeight, muscleGroup: muscleGroup);
  }
}
