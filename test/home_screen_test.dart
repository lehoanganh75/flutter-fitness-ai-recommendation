import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/presentation/screens/home_screen.dart';

void main() {
  final now = DateTime(2026, 10, 10, 9);

  testWidgets('shows configuration message when services are missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(userId: 'alex', now: now),
      ),
    );

    // Khi không có workoutService và dailySuggestionService,
    // HomeScreen hiển thị thông báo cấu hình.
    expect(find.text('Chưa cấu hình dịch vụ'), findsOneWidget);
  });
}
