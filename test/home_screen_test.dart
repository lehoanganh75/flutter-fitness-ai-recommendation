import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/presentation/screens/home_screen.dart';

void main() {
  final now = DateTime(2026, 10, 10, 9);

  testWidgets('shows rest day greeting and empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(userId: 'alex', now: now)),
    );

    expect(find.text('Hôm nay là ngày nghỉ'), findsOneWidget);
    expect(
      find.text('Không có buổi tập nào được lên kế hoạch cho hôm nay.'),
      findsOneWidget,
    );
  });

  testWidgets('shows workout card and start action', (tester) async {
    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          now: now,
          workout: _workout(),
          onStartWorkout: () => started = true,
        ),
      ),
    );

    expect(find.text('Tăng cường thân trên'), findsOneWidget);
    expect(find.text('1 bài · Ngực'), findsOneWidget);
    expect(find.text('Bắt đầu tập'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu tập'));
    expect(started, isTrue);
  });
}

TodayWorkout _workout() {
  final plan = WorkoutPlan(
    id: 'plan',
    userId: 'alex',
    title: 'Tăng cường thân trên',
    dayOfWeek: DateTime.saturday,
    createdAt: DateTime(2026),
  );
  final exercise = PlannedExercise(
    id: 'exercise',
    planId: plan.id,
    exercise: 'Bench press',
    muscleGroup: 'Ngực',
    sortOrder: 1,
    targetSets: 3,
    targetReps: 8,
    initialWeight: 40,
  );
  return TodayWorkout(
    plan: plan,
    exercises: [exercise],
    loggedSetsByExercise: {
      exercise.id: [
        LoggedSet(
          id: 'set',
          exerciseId: exercise.id,
          setIndex: 1,
          weight: 40,
          reps: 8,
          loggedAt: DateTime(2026, 10, 10),
        ),
      ],
    },
  );
}