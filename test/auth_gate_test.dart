import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/app/auth_gate.dart';
import 'package:fitness_recommendation/src/auth/auth_controller.dart';
import 'package:fitness_recommendation/src/auth/auth_service.dart';
import 'package:fitness_recommendation/src/presentation/screens/auth/login_screen.dart';
import 'package:fitness_recommendation/src/presentation/screens/auth/register_screen.dart';
import 'package:fitness_recommendation/src/presentation/screens/today_workout_screen.dart';

void main() {
  Widget buildApp(AuthController controller) =>
      MaterialApp(home: AuthGate(authController: controller));

  testWidgets('starts signed out on the login screen', (tester) async {
    final controller = AuthController(authService: FakeAuthService());
    await tester.pumpWidget(buildApp(controller));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TodayWorkoutScreen), findsNothing);
  });

  testWidgets('successful login transitions to today workout', (tester) async {
    final controller = AuthController(
      authService: FakeAuthService(users: {'athlete@example.com': 'password'}),
    );
    await tester.pumpWidget(buildApp(controller));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'athlete@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayWorkoutScreen), findsOneWidget);
  });

  testWidgets('successful registration transitions to today workout', (
    tester,
  ) async {
    final controller = AuthController(authService: FakeAuthService());
    await tester.pumpWidget(buildApp(controller));
    await tester.tap(find.widgetWithText(TextButton, 'Create an account'));
    await tester.pump();
    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.enterText(find.byType(TextFormField).at(2), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayWorkoutScreen), findsOneWidget);
  });

  testWidgets('invalid credentials remain on auth', (tester) async {
    final controller = AuthController(authService: FakeAuthService());
    await tester.pumpWidget(buildApp(controller));
    await tester.enterText(find.byType(TextFormField).at(0), 'bad@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TodayWorkoutScreen), findsNothing);
    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}
