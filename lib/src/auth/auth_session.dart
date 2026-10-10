import 'package:flutter/foundation.dart';

import 'auth_service.dart';

enum AuthStatus { signedOut, signedIn }

class AuthSession {
  const AuthSession.signedOut()
      : status = AuthStatus.signedOut,
        email = null;

  const AuthSession.signedIn({this.email}) : status = AuthStatus.signedIn;

  final AuthStatus status;
  final String? email;

  bool get isSignedIn => status == AuthStatus.signedIn;
}

/// Coordinates authentication state independently from the widgets that render it.
class AuthController extends ChangeNotifier {
  AuthController({
    required this.authService,
    AuthSession initialSession = const AuthSession.signedOut(),
  }) : _session = initialSession;

  final AuthService authService;
  AuthSession _session;

  AuthSession get session => _session;
  bool get isSignedIn => _session.isSignedIn;

  void markSignedIn({String? email}) {
    _session = AuthSession.signedIn(email: email);
    notifyListeners();
  }

  void signOut() {
    _session = const AuthSession.signedOut();
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await authService.signIn(email: email, password: password);
    markSignedIn(email: email);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    await authService.register(email: email, password: password);
    markSignedIn(email: email);
  }
}
