import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/presentation/screens/today_workout_screen.dart';

TodayWorkout _workout() {
  final plan = WorkoutPlan(
    id: 'p',
    userId: 'u',
    title: 'Tăng cường thân trên',
    dayOfWeek: DateTime.monday,
    createdAt: DateTime(2026),
  );

  final bench = PlannedExercise(
    id: 'b',
    planId: 'p',
    exercise: 'Bench press',
    muscleGroup: 'Ngực',
    sortOrder: 1,
    targetSets: 4,
    targetReps: 8,
    initialWeight: 40,
  );

  final row = PlannedExercise(
    id: 'r',
    planId: 'p',
    exercise: 'Seated cable row',
    muscleGroup: 'Lưng',
    sortOrder: 2,
    targetSets: 3,
    targetReps: 10,
    initialWeight: 35,
  );

  return TodayWorkout(
    plan: plan,
    exercises: [bench, row],
    loggedSetsByExercise: {bench.id: [], row.id: []},
  );
}

/// Buổi tập mà Bench press đã hoàn thành 3/4 set.
TodayWorkout _almostDoneWorkout() {
  final plan = WorkoutPlan(
    id: 'p',
    userId: 'u',
    title: 'Gần hoàn thành',
    dayOfWeek: DateTime.monday,
    createdAt: DateTime(2026),
  );

  final bench = PlannedExercise(
    id: 'b',
    planId: 'p',
    exercise: 'Bench press',
    muscleGroup: 'Ngực',
    sortOrder: 1,
    targetSets: 4,
    targetReps: 8,
    initialWeight: 40,
  );

  final row = PlannedExercise(
    id: 'r',
    planId: 'p',
    exercise: 'Seated cable row',
    muscleGroup: 'Lưng',
    sortOrder: 2,
    targetSets: 3,
    targetReps: 10,
    initialWeight: 35,
  );

  return TodayWorkout(
    plan: plan,
    exercises: [bench, row],
    loggedSetsByExercise: {
      bench.id: [
        LoggedSet(
          id: 's1',
          exerciseId: 'b',
          setIndex: 1,
          weight: 40,
          reps: 8,
          loggedAt: DateTime(2026),
        ),
        LoggedSet(
          id: 's2',
          exerciseId: 'b',
          setIndex: 2,
          weight: 40,
          reps: 8,
          loggedAt: DateTime(2026),
        ),
        LoggedSet(
          id: 's3',
          exerciseId: 'b',
          setIndex: 3,
          weight: 42.5,
          reps: 8,
          loggedAt: DateTime(2026),
        ),
      ],
      row.id: [],
    },
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
}

void main() {
  testWidgets('shows empty state when no workout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodayWorkoutScreen()));

    expect(find.text('Tập luyện hôm nay'), findsOneWidget);
    expect(find.text('Không có kế hoạch tập luyện'), findsOneWidget);
    expect(
      find.text(
        'Hôm nay chưa có giáo án. Hãy tạo giáo án ở tab Giáo án rồi quay lại.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows workout and progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );

    expect(find.text('Tăng cường thân trên'), findsOneWidget);
    expect(find.text('Tiến độ bài tập'), findsOneWidget);
    expect(find.text('0 / 4 set'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Ngực · 4 set × 8 lần'), findsOneWidget);
    expect(find.text('Lưu set'), findsOneWidget);
  });

  testWidgets('saves a set and updates progress', (tester) async {
    _setLargeViewport(tester);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );

    await tester.enterText(find.byType(TextField).at(0), '40');
    await tester.enterText(find.byType(TextField).at(1), '8');

    await tester.ensureVisible(find.text('Lưu set'));
    await tester.tap(find.text('Lưu set'));

    // Chờ xử lý async và cập nhật giao diện.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Đã lưu set 1'), findsOneWidget);
    expect(find.text('1 / 4 set'), findsOneWidget);
  });

  testWidgets('next and previous buttons navigate between exercises', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );

    expect(find.text('Bài 1 / 2'), findsOneWidget);

    final prevButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Bài trước'),
    );
    expect(prevButton.onPressed, isNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Bài kế tiếp'));
    await tester.pump();

    expect(find.text('Seated cable row'), findsOneWidget);
    expect(find.text('Bài 2 / 2'), findsOneWidget);
    expect(find.text('0 / 3 set'), findsOneWidget);
    expect(find.text('Đã chuyển sang: Seated cable row'), findsOneWidget);

    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Bài kế tiếp'),
    );
    expect(nextButton.onPressed, isNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Bài trước'));
    await tester.pump();

    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Bài 1 / 2'), findsOneWidget);
  });

  testWidgets('auto-advances to next exercise after finishing last set', (
    tester,
  ) async {
    _setLargeViewport(tester);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _almostDoneWorkout())),
    );

    expect(find.text('3 / 4 set'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '42.5');
    await tester.enterText(find.byType(TextField).at(1), '8');

    await tester.ensureVisible(find.text('Lưu set'));
    await tester.tap(find.text('Lưu set'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Hoàn thành Bench press — chuyển sang Seated cable row'),
      findsOneWidget,
    );
    expect(find.text('Seated cable row'), findsOneWidget);
    expect(find.text('Bài 2 / 2'), findsOneWidget);
    expect(find.text('0 / 3 set'), findsOneWidget);
  });
}
