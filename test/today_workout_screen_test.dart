import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/domain/models/memory.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/domain/repositories/memory_repository.dart';
import 'package:fitness_recommendation/src/domain/repositories/workout_repository.dart';
import 'package:fitness_recommendation/src/presentation/screens/today_workout_screen.dart';
import 'package:fitness_recommendation/src/services/log_set_service.dart';
import 'package:fitness_recommendation/src/services/workout_service.dart';

void main() {
  Widget buildSubject() => const MaterialApp(home: TodayWorkoutScreen());

  testWidgets('shows workout title, active exercise, and progress', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text("Today's workout"), findsOneWidget);
    expect(find.text('Upper body strength'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('1 of 4 sets'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows weight, reps, feedback fields and saves a set', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Weight (kg)'), findsOneWidget);
    expect(find.text('Reps'), findsOneWidget);
    expect(find.text('How did it feel? (optional)'), findsOneWidget);

    final saveButton = find.byType(FilledButton);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Set 2 saved'), findsOneWidget);
    expect(find.text('2 of 4 sets'), findsOneWidget);
  });

  testWidgets('loads an injected workout and saves through the service', (
    tester,
  ) async {
    final repository = _FakeWorkoutRepository();
    final plan = WorkoutPlan(
      id: 'plan-1',
      userId: 'user-1',
      title: 'Injected plan',
      dayOfWeek: DateTime.saturday,
      createdAt: DateTime(2026),
    );
    final exercise = PlannedExercise(
      id: 'exercise-1',
      planId: plan.id,
      exercise: 'Deadlift',
      muscleGroup: 'Back',
      sortOrder: 1,
      targetSets: 2,
      targetReps: 5,
      initialWeight: 80,
    );
    repository.plan = plan;
    repository.exercises = [exercise];
    final service = LogSetService(
      workoutRepository: repository,
      memoryRepository: _FakeMemoryRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TodayWorkoutScreen(
          workoutService: WorkoutService(repository),
          logSetService: service,
          userId: 'user-1',
          dayOfWeek: DateTime.saturday,
          idGenerator: () => 'generated-id',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Injected plan'), findsOneWidget);
    expect(find.text('Deadlift'), findsOneWidget);
    expect(find.text('80.0'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.savedSet?.id, 'generated-id');
    expect(repository.savedSet?.exerciseId, exercise.id);
    expect(find.text('Set 1 saved'), findsOneWidget);
  });
}

class _FakeWorkoutRepository implements WorkoutRepository {
  WorkoutPlan? plan;
  List<PlannedExercise> exercises = [];
  LoggedSet? savedSet;

  @override
  Future<List<WorkoutPlan>> plansForDay(String userId, int dayOfWeek) async =>
      plan == null ? [] : [plan!];

  @override
  Future<List<PlannedExercise>> exercisesForPlan(String planId) async =>
      exercises;

  @override
  Future<List<LoggedSet>> loggedSetsForExercise(String exerciseId) async => [];

  @override
  Future<void> saveLoggedSet(LoggedSet loggedSet) async => savedSet = loggedSet;

  @override
  Future<List<LoggedSet>> exerciseHistory(
    String exerciseId, {
    int? limit,
  }) async => [];

  @override
  Future<WorkoutPlan?> planById(String planId) async => plan;

  @override
  Future<void> savePlan(WorkoutPlan plan) async {}

  @override
  Future<PlannedExercise?> exerciseById(String exerciseId) async =>
      exercises.where((exercise) => exercise.id == exerciseId).firstOrNull;

  @override
  Future<void> saveExercise(PlannedExercise exercise) async {}
}

class _FakeMemoryRepository implements MemoryRepository {
  @override
  Future<void> save(Memory memory) async {}

  @override
  Future<List<Memory>> activeForExercise({
    required String userId,
    required String exercise,
    required DateTime now,
  }) async => [];

  @override
  Future<bool> archive(String id) async => false;
}
