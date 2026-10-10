import 'package:flutter/material.dart';

import '../../../auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    this.onRegistered,
    this.onLogin,
  });

  final AuthService authService;
  final VoidCallback? onRegistered;
  final VoidCallback? onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _isLoading = false;
  String? _feedback;
  bool _feedbackIsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Start training smarter',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text('Create an account to track your progress.'),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                      onChanged: (_) => _clearFeedback(),
                    ),
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: _passwordController,
                      label: 'Password',
                      obscure: _obscurePassword,
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm password',
                      obscure: _obscureConfirmation,
                      tooltip: _obscureConfirmation
                          ? 'Show password'
                          : 'Hide password',
                      onToggle: () => setState(
                        () => _obscureConfirmation = !_obscureConfirmation,
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_feedback != null) ...[
                      _FeedbackMessage(
                        message: _feedback!,
                        isError: _feedbackIsError,
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : widget.onLogin,
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required String tooltip,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          tooltip: tooltip,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newPassword],
      validator: validator,
      onChanged: (_) => _clearFeedback(),
    );
  }

  void _clearFeedback() {
    if (_feedback != null) {
      setState(() => _feedback = null);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _feedback = null;
    });
    try {
      await widget.authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _feedback = 'Account created successfully.';
        _feedbackIsError = false;
      });
      widget.onRegistered?.call();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _feedback = error.message;
        _feedbackIsError = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _feedback = 'Unable to create your account: $error';
        _feedbackIsError = true;
      });
    }
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? _validatePassword(String? value) {
  if ((value ?? '').length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Semantics(
      liveRegion: true,
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}
