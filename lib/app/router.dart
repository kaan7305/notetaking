import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/courses/course_detail_screen.dart';
import '../features/courses/library_screen.dart';
import 'route_names.dart';

/// Provides a [GoRouter] instance that reacts to authentication state changes.
///
/// When [authProvider] emits a new state the router is recreated, triggering
/// the global [redirect] which gates every non-auth route behind login.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.signup;

      // Unauthenticated users can only visit login / signup.
      if (!isAuthenticated && !isAuthRoute) {
        return RoutePaths.login;
      }

      // Authenticated users should not stay on auth screens.
      if (isAuthenticated && isAuthRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: RoutePaths.courseDetail,
        name: RouteNames.courseDetail,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseDetailScreen(courseId: courseId);
        },
        routes: [
          GoRoute(
            path: 'notebook/:notebookId',
            name: RouteNames.notebook,
            builder: (context, state) {
              final notebookId = state.pathParameters['notebookId']!;
              return PlaceholderScreen(title: 'Notebook $notebookId');
            },
          ),
          GoRoute(
            path: 'documents',
            name: RouteNames.documents,
            builder: (context, state) {
              final courseId = state.pathParameters['courseId']!;
              return PlaceholderScreen(title: 'Documents for $courseId');
            },
          ),
          GoRoute(
            path: 'document/:documentId',
            name: RouteNames.documentViewer,
            builder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              final page = int.tryParse(
                      state.uri.queryParameters['page'] ?? '') ??
                  1;
              return PlaceholderScreen(title: 'Doc $documentId p.$page');
            },
          ),
        ],
      ),
    ],
  );
});

/// Temporary placeholder screen used until real feature screens are built.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
