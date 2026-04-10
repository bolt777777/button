import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'user@bodyguard.dev');
  final _password = TextEditingController(text: 'user123');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .login(_email.text.trim(), _password.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Неверные учётные данные');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kCoralLight, kCoral],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: kCoral.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Телохранитель',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 15, color: kTextSecondary),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: kTextSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: kTextSecondary, size: 20),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: kCoralBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kCoral, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: kCoralDark, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Войти', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
