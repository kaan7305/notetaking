import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'auth_state.dart';
import 'login_screen.dart';

/// Watches [authProvider] and renders the appropriate screen.
///
/// - [AuthInitial] / [AuthLoading] -> centered progress indicator
/// - [AuthAuthenticated]           -> placeholder (will be replaced with router)
/// - [AuthUnauthenticated] / [AuthError] -> [LoginScreen]
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState) {
      AuthInitial() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthAuthenticated() => const Scaffold(
          body: Center(
            child: Text('Authenticated! (Router placeholder)'),
          ),
        ),
      AuthUnauthenticated() => const LoginScreen(),
      AuthError() => const LoginScreen(),
    };
  }
}
