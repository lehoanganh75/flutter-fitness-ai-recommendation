import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/domain/models/today_workout.dart';
import 'package:fitness_recommendation/src/domain/models/workout.dart';
import 'package:fitness_recommendation/src/presentation/screens/today_workout_screen.dart';

TodayWorkout _workout() {
  final plan = WorkoutPlan(
    id: 'p', userId: 'u', title: 'Tăng cường thân trên',
    dayOfWeek: DateTime.monday, createdAt: DateTime(2026),
  );
  final bench = PlannedExercise(
    id: 'b', planId: 'p', exercise: 'Bench press', muscleGroup: 'Ngực',
    sortOrder: 1, targetSets: 4, targetReps: 8, initialWeight: 40,
  );
  final row = PlannedExercise(
    id: 'r', planId: 'p', exercise: 'Seated cable row', muscleGroup: 'Lưng',
    sortOrder: 2, targetSets: 3, targetReps: 10, initialWeight: 35,
  );
  return TodayWorkout(
    plan: plan,
    exercises: [bench, row],
    loggedSetsByExercise: {bench.id: [], row.id: []},
  );
}

/// Buổi tập mà bài Bench press đã log 3/4 set — chỉ cần 1 set nữa là xong.
TodayWorkout _almostDoneWorkout() {
  final plan = WorkoutPlan(
    id: 'p', userId: 'u', title: 'Gần hoàn thành',
    dayOfWeek: DateTime.monday, createdAt: DateTime(2026),
  );
  final bench = PlannedExercise(
    id: 'b', planId: 'p', exercise: 'Bench press', muscleGroup: 'Ngực',
    sortOrder: 1, targetSets: 4, targetReps: 8, initialWeight: 40,
  );
  final row = PlannedExercise(
    id: 'r', planId: 'p', exercise: 'Seated cable row', muscleGroup: 'Lưng',
    sortOrder: 2, targetSets: 3, targetReps: 10, initialWeight: 35,
  );
  return TodayWorkout(
    plan: plan,
    exercises: [bench, row],
    loggedSetsByExercise: {
      bench.id: [
        LoggedSet(
          id: 's1', exerciseId: 'b', setIndex: 1,
          weight: 40, reps: 8, loggedAt: DateTime(2026),
        ),
        LoggedSet(
          id: 's2', exerciseId: 'b', setIndex: 2,
          weight: 40, reps: 8, loggedAt: DateTime(2026),
        ),
        LoggedSet(
          id: 's3', exerciseId: 'b', setIndex: 3,
          weight: 42.5, reps: 8, loggedAt: DateTime(2026),
        ),
      ],
      row.id: [],
    },
  );
}

void main() {
  testWidgets('shows empty state when no workout', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TodayWorkoutScreen()));
    expect(find.text('Tập luyện hôm nay'), findsOneWidget);
    expect(find.text('Không có kế hoạch tập luyện'), findsOneWidget);
    expect(
      find.text('Tập luyện tiếp theo của bạn sẽ xuất hiện ở đây khi sẵn sàng.'),
      findsOneWidget,
    );
  });

  testWidgets('shows workout and progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );
    expect(find.text('Tăng cường thân trên'), findsOneWidget);
    expect(find.text('Tiến độ buổi tập'), findsOneWidget);
    expect(find.text('0 của 4 tập'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Ngực · 4 tập × 8 lần'), findsOneWidget);
    expect(find.text('Lưu tập'), findsOneWidget);
  });

  testWidgets('saves a set and updates progress', (tester) async {
    // Mở rộng viewport để nút "Lưu tập" không bị trôi khỏi khung test.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );
    await tester.enterText(find.byType(TextField).at(0), '40');
    await tester.enterText(find.byType(TextField).at(1), '8');
    await tester.scrollUntilVisible(
      find.text('Lưu tập'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lưu tập'));
    await tester.pump();
    expect(find.text('Đã lưu tập 1'), findsOneWidget);
    expect(find.text('1 của 4 tập'), findsOneWidget);
  });

  testWidgets('next and previous buttons navigate between exercises',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _workout())),
    );
    expect(find.text('Bài 1 / 2'), findsOneWidget);

    // Ở bài đầu → nút "Bài trước" bị vô hiệu hóa.
    final prevButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Bài trước'),
    );
    expect(prevButton.onPressed, isNull);

    // Nhấn sang bài kế tiếp.
    await tester.tap(find.widgetWithText(FilledButton, 'Bài kế tiếp'));
    await tester.pump();
    expect(find.text('Seated cable row'), findsOneWidget);
    expect(find.text('Bài 2 / 2'), findsOneWidget);
    expect(find.text('0 của 3 tập'), findsOneWidget);
    expect(
      find.text('Đã chuyển sang: Seated cable row'),
      findsOneWidget,
    );

    // Ở bài cuối → nút "Bài kế tiếp" bị vô hiệu hóa.
    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Bài kế tiếp'),
    );
    expect(nextButton.onPressed, isNull);

    // Quay lại bài đầu.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Bài trước'));
    await tester.pump();
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Bài 1 / 2'), findsOneWidget);
  });

  testWidgets('auto-advances to next exercise after finishing last set',
      (tester) async {
    // Mở rộng viewport để nút "Lưu tập" không bị trôi khỏi khung test.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(home: TodayWorkoutScreen(workout: _almostDoneWorkout())),
    );
    expect(find.text('3 của 4 tập'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '42.5');
    await tester.enterText(find.byType(TextField).at(1), '8');
    await tester.scrollUntilVisible(
      find.text('Lưu tập'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Lưu tập'));
    await tester.pump();

    // Set cuối đã lưu → tự chuyển sang bài Seated cable row.
    expect(
      find.text('Hoàn thành Bench press — chuyển sang Seated cable row'),
      findsOneWidget,
    );
    expect(find.text('Seated cable row'), findsOneWidget);
    expect(find.text('Bài 2 / 2'), findsOneWidget);
    expect(find.text('0 của 3 tập'), findsOneWidget);
  });
}