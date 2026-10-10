import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout_progress.dart';
import 'package:fitness_recommendation/src/domain/models/today_workout.dart';

void main() {
  test('creates today workout plan with pending sync status', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 1,
      createdAt: DateTime(2026, 10, 8),
    );

    expect(plan.id, 'plan-001');
    expect(plan.title, 'Push Day');
    expect(plan.dayOfWeek, 1);
    expect(plan.syncStatus, SyncStatus.pending);
  });

  test('copies workout plan with a new title', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 1,
      createdAt: DateTime(2026, 10, 8),
    );

    final updatedPlan = plan.copyWith(title: 'Pull Day');

    expect(plan.title, 'Push Day');
    expect(updatedPlan.title, 'Pull Day');
    expect(updatedPlan.id, plan.id);
    expect(updatedPlan.userId, plan.userId);
  });
  test('creates planned exercise inside workout plan', () {
    final exercise = PlannedExercise(
      id: 'exercise-001',
      planId: 'plan-001',
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      sortOrder: 1,
      targetSets: 3,
      targetReps: 10,
      initialWeight: 50,
    );

    expect(exercise.id, 'exercise-001');
    expect(exercise.planId, 'plan-001');
    expect(exercise.exercise, 'Bench Press');
    expect(exercise.muscleGroup, 'Chest');
    expect(exercise.targetSets, 3);
    expect(exercise.targetReps, 10);
    expect(exercise.initialWeight, 50);
    expect(exercise.syncStatus, SyncStatus.pending);
  });
  test('creates logged set with feedback', () {
    final loggedSet = LoggedSet(
      id: 'set-001',
      exerciseId: 'exercise-001',
      setIndex: 1,
      weight: 50,
      reps: 8,
      feedbackText: 'Mệt, không nổi',
      loggedAt: DateTime(2026, 10, 8, 13, 30),
    );

    expect(loggedSet.id, 'set-001');
    expect(loggedSet.exerciseId, 'exercise-001');
    expect(loggedSet.setIndex, 1);
    expect(loggedSet.weight, 50);
    expect(loggedSet.reps, 8);
    expect(loggedSet.feedbackText, 'Mệt, không nổi');
    expect(loggedSet.syncStatus, SyncStatus.pending);
  });
  test('calculates current set progress', () {
    final loggedSets = [
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 8,
        feedbackText: 'Mệt, không nổi',
        loggedAt: DateTime(2026, 10, 8, 13, 30),
      ),
    ];

    final progress = WorkoutProgress.fromExercise(
      targetSets: 3,
      loggedSets: loggedSets,
    );

    expect(progress.completedSets, 1);
    expect(progress.totalSets, 3);
    expect(progress.currentSet, 2);
    expect(progress.isCompleted, false);
  });

  test('marks exercise as completed after all sets are logged', () {
    final loggedSets = [
      LoggedSet(
        id: 'set-001',
        exerciseId: 'exercise-001',
        setIndex: 1,
        weight: 50,
        reps: 8,
        loggedAt: DateTime(2026, 10, 8, 13, 30),
      ),
      LoggedSet(
        id: 'set-002',
        exerciseId: 'exercise-001',
        setIndex: 2,
        weight: 50,
        reps: 8,
        loggedAt: DateTime(2026, 10, 8, 13, 35),
      ),
      LoggedSet(
        id: 'set-003',
        exerciseId: 'exercise-001',
        setIndex: 3,
        weight: 50,
        reps: 10,
        loggedAt: DateTime(2026, 10, 8, 13, 40),
      ),
    ];

    final progress = WorkoutProgress.fromExercise(
      targetSets: 3,
      loggedSets: loggedSets,
    );

    expect(progress.completedSets, 3);
    expect(progress.totalSets, 3);
    expect(progress.currentSet, isNull);
    expect(progress.isCompleted, true);
  });
  test('groups todays workout by muscle groups', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [
        PlannedExercise(
          id: 'exercise-001',
          planId: 'plan-001',
          exercise: 'Bench Press',
          muscleGroup: 'Chest',
          sortOrder: 1,
          targetSets: 3,
          targetReps: 10,
          initialWeight: 50,
        ),
        PlannedExercise(
          id: 'exercise-002',
          planId: 'plan-001',
          exercise: 'Incline Dumbbell Press',
          muscleGroup: 'Chest',
          sortOrder: 2,
          targetSets: 3,
          targetReps: 10,
          initialWeight: 20,
        ),
        PlannedExercise(
          id: 'exercise-003',
          planId: 'plan-001',
          exercise: 'Shoulder Press',
          muscleGroup: 'Shoulder',
          sortOrder: 3,
          targetSets: 3,
          targetReps: 8,
          initialWeight: 25,
        ),
      ],
      loggedSetsByExercise: {},
    );

    expect(workout.plan.title, 'Push Day');
    expect(workout.exercises.length, 3);
    expect(workout.muscleGroups, ['Chest', 'Shoulder']);
  });
  test('selects the first incomplete exercise as active', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [
        PlannedExercise(
          id: 'exercise-002',
          planId: 'plan-001',
          exercise: 'Incline Dumbbell Press',
          muscleGroup: 'Chest',
          sortOrder: 2,
          targetSets: 3,
          targetReps: 10,
          initialWeight: 20,
        ),
        PlannedExercise(
          id: 'exercise-001',
          planId: 'plan-001',
          exercise: 'Bench Press',
          muscleGroup: 'Chest',
          sortOrder: 1,
          targetSets: 3,
          targetReps: 10,
          initialWeight: 50,
        ),
      ],
      loggedSetsByExercise: {},
    );

    final activeExercise = workout.activeExercise(
      loggedSetsByExercise: {
        'exercise-001': [
          LoggedSet(
            id: 'set-001',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 10,
            loggedAt: DateTime(2026, 10, 8, 13, 30),
          ),
          LoggedSet(
            id: 'set-002',
            exerciseId: 'exercise-001',
            setIndex: 2,
            weight: 50,
            reps: 10,
            loggedAt: DateTime(2026, 10, 8, 13, 35),
          ),
          LoggedSet(
            id: 'set-003',
            exerciseId: 'exercise-001',
            setIndex: 3,
            weight: 50,
            reps: 10,
            loggedAt: DateTime(2026, 10, 8, 13, 40),
          ),
        ],
      },
    );

    expect(activeExercise?.id, 'exercise-002');
    expect(activeExercise?.exercise, 'Incline Dumbbell Press');
  });
  test('returns null when all exercises are completed', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [
        PlannedExercise(
          id: 'exercise-001',
          planId: 'plan-001',
          exercise: 'Bench Press',
          muscleGroup: 'Chest',
          sortOrder: 1,
          targetSets: 1,
          targetReps: 10,
          initialWeight: 50,
        ),
      ],
      loggedSetsByExercise: {},
    );

    final activeExercise = workout.activeExercise(
      loggedSetsByExercise: {
        'exercise-001': [
          LoggedSet(
            id: 'set-001',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 10,
            loggedAt: DateTime(2026, 10, 8, 13, 30),
          ),
        ],
      },
    );

    expect(activeExercise, isNull);
  });

  test('calculates progress for the active exercise', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [
        PlannedExercise(
          id: 'exercise-001',
          planId: 'plan-001',
          exercise: 'Bench Press',
          muscleGroup: 'Chest',
          sortOrder: 1,
          targetSets: 3,
          targetReps: 10,
          initialWeight: 50,
        ),
      ],
      loggedSetsByExercise: {},
    );

    final progress = workout.activeProgress(
      loggedSetsByExercise: {
        'exercise-001': [
          LoggedSet(
            id: 'set-001',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 8,
            feedbackText: 'Mệt, không nổi',
            loggedAt: DateTime(2026, 10, 8, 13, 30),
          ),
        ],
      },
    );

    expect(progress, isNotNull);
    expect(progress?.completedSets, 1);
    expect(progress?.totalSets, 3);
    expect(progress?.currentSet, 2);
    expect(progress?.isCompleted, false);
  });
  test('uses the latest logged weight from exercise history', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final exercise = PlannedExercise(
      id: 'exercise-001',
      planId: 'plan-001',
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      sortOrder: 1,
      targetSets: 3,
      targetReps: 10,
      initialWeight: 50,
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [exercise],
      loggedSetsByExercise: {},
    );

    final currentWeight = workout.currentWeightFor(
      exercise: exercise,
      loggedSetsByExercise: {
        'exercise-001': [
          LoggedSet(
            id: 'set-002',
            exerciseId: 'exercise-001',
            setIndex: 2,
            weight: 40,
            reps: 8,
            loggedAt: DateTime(2026, 10, 8, 13, 40),
          ),
          LoggedSet(
            id: 'set-001',
            exerciseId: 'exercise-001',
            setIndex: 1,
            weight: 50,
            reps: 10,
            loggedAt: DateTime(2026, 10, 8, 13, 30),
          ),
        ],
      },
    );

    expect(currentWeight, 40);
  });
  test('uses initial weight when exercise has no history', () {
    final plan = WorkoutPlan(
      id: 'plan-001',
      userId: 'user-001',
      title: 'Push Day',
      dayOfWeek: 4,
      createdAt: DateTime(2026, 10, 8),
    );

    final exercise = PlannedExercise(
      id: 'exercise-001',
      planId: 'plan-001',
      exercise: 'Bench Press',
      muscleGroup: 'Chest',
      sortOrder: 1,
      targetSets: 3,
      targetReps: 10,
      initialWeight: 50,
    );

    final workout = TodayWorkout(
      plan: plan,
      exercises: [exercise],
      loggedSetsByExercise: {},
    );

    final currentWeight = workout.currentWeightFor(
      exercise: exercise,
      loggedSetsByExercise: {},
    );

    expect(currentWeight, 50);
  });
}
