import '../domain/models/workout.dart';
import '../domain/repositories/workout_repository.dart';

/// Service để seed sample data vào database lần đầu
class SampleDataSeeder {
  final WorkoutRepository repository;

  SampleDataSeeder(this.repository);

  /// Kiểm tra và seed data nếu người dùng chưa có plan nào (ở bất kỳ ngày nào).
  Future<void> seedIfEmpty(String userId) async {
    for (var day = 1; day <= 7; day++) {
      final plans = await repository.plansForDay(userId, day);
      if (plans.isNotEmpty) {
        // Đã có plan rồi (mẫu hoặc tự tạo), không cần seed
        return;
      }
    }

    // Seed sample workout plans
    await _seedPushDay(userId);
    await _seedPullDay(userId);
    await _seedLegDay(userId);
  }

  Future<void> _seedPushDay(String userId) async {
    final now = DateTime.now();

    // Create Push Day Plan (Monday)
    final pushPlan = WorkoutPlan(
      id: 'plan_push_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'Push Day',
      dayOfWeek: 1, // Monday
      createdAt: now,
    );
    await repository.savePlan(pushPlan);

    // Add exercises
    final exercises = [
      PlannedExercise(
        id: '${pushPlan.id}_ex_1',
        planId: pushPlan.id,
        exercise: 'Bench Press',
        muscleGroup: 'Chest',
        targetSets: 4,
        targetReps: 8,
        initialWeight: 80.0,
        sortOrder: 1,
      ),
      PlannedExercise(
        id: '${pushPlan.id}_ex_2',
        planId: pushPlan.id,
        exercise: 'Incline Dumbbell Press',
        muscleGroup: 'Chest',
        targetSets: 3,
        targetReps: 10,
        initialWeight: 30.0,
        sortOrder: 2,
      ),
      PlannedExercise(
        id: '${pushPlan.id}_ex_3',
        planId: pushPlan.id,
        exercise: 'Overhead Press',
        muscleGroup: 'Shoulders',
        targetSets: 4,
        targetReps: 8,
        initialWeight: 50.0,
        sortOrder: 3,
      ),
      PlannedExercise(
        id: '${pushPlan.id}_ex_4',
        planId: pushPlan.id,
        exercise: 'Lateral Raises',
        muscleGroup: 'Shoulders',
        targetSets: 3,
        targetReps: 12,
        initialWeight: 10.0,
        sortOrder: 4,
      ),
      PlannedExercise(
        id: '${pushPlan.id}_ex_5',
        planId: pushPlan.id,
        exercise: 'Tricep Dips',
        muscleGroup: 'Triceps',
        targetSets: 3,
        targetReps: 10,
        initialWeight: 0.0, // Bodyweight
        sortOrder: 5,
      ),
    ];

    for (final exercise in exercises) {
      await repository.saveExercise(exercise);
    }
  }

  Future<void> _seedPullDay(String userId) async {
    final now = DateTime.now();

    // Create Pull Day Plan (Wednesday)
    final pullPlan = WorkoutPlan(
      id: 'plan_pull_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'Pull Day',
      dayOfWeek: 3, // Wednesday
      createdAt: now,
    );
    await repository.savePlan(pullPlan);

    // Add exercises
    final exercises = [
      PlannedExercise(
        id: '${pullPlan.id}_ex_1',
        planId: pullPlan.id,
        exercise: 'Deadlift',
        muscleGroup: 'Back',
        targetSets: 4,
        targetReps: 6,
        initialWeight: 120.0,
        sortOrder: 1,
      ),
      PlannedExercise(
        id: '${pullPlan.id}_ex_2',
        planId: pullPlan.id,
        exercise: 'Pull-ups',
        muscleGroup: 'Back',
        targetSets: 3,
        targetReps: 8,
        initialWeight: 0.0, // Bodyweight
        sortOrder: 2,
      ),
      PlannedExercise(
        id: '${pullPlan.id}_ex_3',
        planId: pullPlan.id,
        exercise: 'Barbell Row',
        muscleGroup: 'Back',
        targetSets: 4,
        targetReps: 8,
        initialWeight: 70.0,
        sortOrder: 3,
      ),
      PlannedExercise(
        id: '${pullPlan.id}_ex_4',
        planId: pullPlan.id,
        exercise: 'Face Pulls',
        muscleGroup: 'Rear Delts',
        targetSets: 3,
        targetReps: 15,
        initialWeight: 15.0,
        sortOrder: 4,
      ),
      PlannedExercise(
        id: '${pullPlan.id}_ex_5',
        planId: pullPlan.id,
        exercise: 'Bicep Curls',
        muscleGroup: 'Biceps',
        targetSets: 3,
        targetReps: 12,
        initialWeight: 15.0,
        sortOrder: 5,
      ),
    ];

    for (final exercise in exercises) {
      await repository.saveExercise(exercise);
    }
  }

  Future<void> _seedLegDay(String userId) async {
    final now = DateTime.now();

    // Create Leg Day Plan (Friday)
    final legPlan = WorkoutPlan(
      id: 'plan_leg_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'Leg Day',
      dayOfWeek: 5, // Friday
      createdAt: now,
    );
    await repository.savePlan(legPlan);

    // Add exercises
    final exercises = [
      PlannedExercise(
        id: '${legPlan.id}_ex_1',
        planId: legPlan.id,
        exercise: 'Squat',
        muscleGroup: 'Quads',
        targetSets: 4,
        targetReps: 8,
        initialWeight: 100.0,
        sortOrder: 1,
      ),
      PlannedExercise(
        id: '${legPlan.id}_ex_2',
        planId: legPlan.id,
        exercise: 'Romanian Deadlift',
        muscleGroup: 'Hamstrings',
        targetSets: 3,
        targetReps: 10,
        initialWeight: 80.0,
        sortOrder: 2,
      ),
      PlannedExercise(
        id: '${legPlan.id}_ex_3',
        planId: legPlan.id,
        exercise: 'Leg Press',
        muscleGroup: 'Quads',
        targetSets: 3,
        targetReps: 12,
        initialWeight: 150.0,
        sortOrder: 3,
      ),
      PlannedExercise(
        id: '${legPlan.id}_ex_4',
        planId: legPlan.id,
        exercise: 'Leg Curls',
        muscleGroup: 'Hamstrings',
        targetSets: 3,
        targetReps: 12,
        initialWeight: 40.0,
        sortOrder: 4,
      ),
      PlannedExercise(
        id: '${legPlan.id}_ex_5',
        planId: legPlan.id,
        exercise: 'Calf Raises',
        muscleGroup: 'Calves',
        targetSets: 4,
        targetReps: 15,
        initialWeight: 60.0,
        sortOrder: 5,
      ),
    ];

    for (final exercise in exercises) {
      await repository.saveExercise(exercise);
    }
  }
}
