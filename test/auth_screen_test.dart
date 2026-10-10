import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_recommendation/src/auth/auth_service.dart';
import 'package:fitness_recommendation/src/presentation/screens/auth/login_screen.dart';
import 'package:fitness_recommendation/src/presentation/screens/auth/register_screen.dart';

void main() {
  testWidgets('login validates email and password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: FakeAuthService())),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
  });

  testWidgets('login shows loading and success feedback', (tester) async {
    var authenticated = false;
    final service = FakeAuthService(
      users: {'athlete@example.com': 'password'},
      delay: const Duration(milliseconds: 100),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: service,
          onAuthenticated: () => authenticated = true,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'athlete@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('You are now logged in.'), findsOneWidget);
    expect(authenticated, isTrue);
  });

  testWidgets(
    'register validates confirmation and toggles password visibility',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(authService: FakeAuthService())),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.enterText(find.byType(TextFormField).at(2), 'different');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(find.byTooltip('Show password'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Show password').first);
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
    },
  );

  testWidgets('register reports success and clears feedback when edited', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RegisterScreen(authService: FakeAuthService())),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.enterText(find.byType(TextFormField).at(2), 'password');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Account created successfully.'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'other@example.com',
    );
    await tester.pump();
    expect(find.text('Account created successfully.'), findsNothing);
  });
}
