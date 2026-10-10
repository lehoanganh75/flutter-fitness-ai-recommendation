class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthService {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
  });
}

/// A deterministic in-memory implementation for the presentation layer.
class FakeAuthService implements AuthService {
  FakeAuthService({
    Map<String, String>? users,
    this.delay = Duration.zero,
  }) : _users = {...?users};

  final Duration delay;
  final Map<String, String> _users;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (_users[email] != password) {
      throw const AuthException('Invalid email or password.');
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    if (_users.containsKey(email)) {
      throw const AuthException('An account with this email already exists.');
    }
    _users[email] = password;
  }
}
