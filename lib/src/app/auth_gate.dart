import 'package:flutter/material.dart';

import '../auth/auth_session.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/today_workout_screen.dart';
import '../services/log_set_service.dart';
import '../services/workout_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authController,
    this.workoutService,
    this.logSetService,
    this.userId = 'sample-user',
  });

  final AuthController authController;
  final WorkoutService? workoutService;
  final LogSetService? logSetService;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        if (authController.session.status == AuthStatus.signedIn) {
          return TodayWorkoutScreen(
            workoutService: workoutService,
            logSetService: logSetService,
            userId: userId,
          );
        }
        return _AuthNavigator(
          authController: authController,
        );
      },
    );
  }
}

class _AuthNavigator extends StatefulWidget {
  const _AuthNavigator({required this.authController});

  final AuthController authController;

  @override
  State<_AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<_AuthNavigator> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.authController.authService;
    if (_showRegister) {
      return RegisterScreen(
        authService: service,
        onRegistered: () => widget.authController.markSignedIn(),
        onLogin: () => setState(() => _showRegister = false),
      );
    }
    return LoginScreen(
      authService: service,
      onAuthenticated: () => widget.authController.markSignedIn(),
      onRegister: () => setState(() => _showRegister = true),
    );
  }
}
