import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/presentation/screens/plan_screen.dart';
import 'package:fitness_recommendation/src/services/workout_service.dart';

Future<List<WorkoutPlanDetails>> _emptyLoader(String u, int d) async => [];

Future<List<WorkoutPlanDetails>> _failLoader(String u, int d) async => throw Exception('offline');

void main() {
  testWidgets('shows empty plan state', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PlanScreen(planLoader: _emptyLoader)));
    // Pump thêm để planLoader async hoàn tất và render trạng thái rỗng.
    await tester.pump();
    expect(find.text('Giáo án'), findsOneWidget);
    expect(find.text('Không có kế hoạch cho ngày này'), findsOneWidget);
    expect(
      find.text('Xây dựng và quản lý kế hoạch tập luyện hàng tuần.'),
      findsOneWidget,
    );
  });

  testWidgets('shows error when loading fails', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PlanScreen(planLoader: _failLoader)));
    await tester.pump();
    expect(find.text('Không thể tải kế hoạch'), findsOneWidget);
  });

  testWidgets('reloads when day changes', (tester) async {
    var lastDay = 0;
    Future<List<WorkoutPlanDetails>> loader(String u, int d) async {
      lastDay = d;
      return [];
    }
    await tester.pumpWidget(
      MaterialApp(home: PlanScreen(planLoader: loader, initialDayOfWeek: 1)),
    );
    await tester.tap(find.text('Thứ 4'));
    await tester.pump();
    // 'Thứ 4' là thứ tư trong tuần → DateTime.wednesday == 3.
    expect(lastDay, 3);
  });
}