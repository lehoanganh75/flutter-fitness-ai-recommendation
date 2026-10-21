import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/presentation/screens/app_shell.dart';
import 'package:fitness_recommendation/src/presentation/screens/exercises_screen.dart';
import 'package:fitness_recommendation/src/presentation/screens/today_workout_screen.dart';

void main() {
  testWidgets('shows bottom navigation labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Giáo án'), findsOneWidget);
    expect(find.text('Tiến độ'), findsOneWidget);
    expect(find.text('Bài tập'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });

  testWidgets('home tab shows rest day', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    expect(find.text('Hôm nay là ngày nghỉ'), findsOneWidget);
    expect(
      find.text('Không có buổi tập nào được lên kế hoạch cho hôm nay.'),
      findsOneWidget,
    );
  });

  testWidgets('plan tab shows empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.tap(find.text('Giáo án'));
    await tester.pump();
    expect(find.text('Không có kế hoạch cho ngày này'), findsOneWidget);
  });

  testWidgets('stats tab shows empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.tap(find.text('Tiến độ'));
    await tester.pump();
    expect(find.text('Chưa có dữ liệu tập luyện'), findsOneWidget);
  });

  testWidgets('exercises tab opens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    await tester.tap(find.text('Bài tập'));
    await tester.pump();
    expect(find.byType(ExercisesScreen), findsOneWidget);
  });

  testWidgets('shows today workout when opened initially', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AppShell(showTodayWorkoutInitially: true),
    ));
    expect(find.byType(TodayWorkoutScreen), findsOneWidget);
    expect(find.text('Tập luyện hôm nay'), findsOneWidget);
  });
}