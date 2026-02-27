/// Centralized route name constants used with GoRouter's named routing.
class RouteNames {
  RouteNames._();

  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String courseDetail = 'courseDetail';
  static const String notebook = 'notebook';
  static const String documents = 'documents';
  static const String documentViewer = 'documentViewer';
  static const String lectureCapture = 'lectureCapture';
  static const String review = 'review';
  static const String settings = 'settings';
}

/// Centralized route path constants used in GoRoute definitions.
class RoutePaths {
  RoutePaths._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String courseDetail = '/course/:courseId';
  static const String notebook = '/course/:courseId/notebook/:notebookId';
  static const String documents = '/course/:courseId/documents';
  static const String documentViewer = '/course/:courseId/document/:documentId';
  static const String lectureCapture = '/course/:courseId/lecture';
  static const String review = '/course/:courseId/review';
  static const String settings = '/settings';
}
