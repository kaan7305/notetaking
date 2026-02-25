import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Represents the current authentication state of the app.
///
/// Uses a sealed class hierarchy instead of freezed to avoid a
/// build_runner dependency for this core piece of infrastructure.
sealed class AuthState {
  const AuthState();
}

/// The initial state before any auth check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An auth operation (sign-in, sign-up, etc.) is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is signed in.
class AuthAuthenticated extends AuthState {
  final supabase.User user;
  const AuthAuthenticated(this.user);
}

/// No user session exists.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during an auth operation.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
