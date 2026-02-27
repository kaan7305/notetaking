import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_notebook/core/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'auth_state.dart';

/// Manages authentication state by wrapping Supabase Auth.
///
/// On creation the notifier checks for an existing session and then
/// subscribes to [supabase.GoTrueClient.onAuthStateChange] so the UI
/// always reflects the latest auth status.
class AuthNotifier extends StateNotifier<AuthState> {
  final supabase.SupabaseClient _client;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthNotifier(this._client) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Check current session
    final session = _client.auth.currentSession;
    if (session != null) {
      state = AuthAuthenticated(_client.auth.currentUser!);
    } else {
      state = const AuthUnauthenticated();
    }

    // Listen for auth changes
    _authSubscription =
        _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == supabase.AuthChangeEvent.signedIn) {
        state = AuthAuthenticated(_client.auth.currentUser!);
      } else if (event == supabase.AuthChangeEvent.signedOut) {
        state = const AuthUnauthenticated();
      } else if (event == supabase.AuthChangeEvent.tokenRefreshed) {
        if (_client.auth.currentUser != null) {
          state = AuthAuthenticated(_client.auth.currentUser!);
        }
      }
    });
  }

  /// Signs in with email and password.
  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      await _client.auth
          .signInWithPassword(email: email, password: password);
      // State updates via the onAuthStateChange listener.
    } on supabase.AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('An unexpected error occurred');
    }
  }

  /// Creates a new account with email and password.
  Future<void> signUp(String email, String password) async {
    state = const AuthLoading();
    try {
      await _client.auth.signUp(email: email, password: password);
      // State updates via the onAuthStateChange listener.
    } on supabase.AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('An unexpected error occurred');
    }
  }

  /// Signs in as a demo user without hitting Supabase.
  void signInDemo() {
    state = const AuthDemo();
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    if (state is AuthDemo) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      await _client.auth.signOut();
    } catch (e) {
      state = const AuthError('Failed to sign out');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provides the current [AuthState] and exposes [AuthNotifier] for
/// triggering sign-in / sign-up / sign-out.
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(client);
});
