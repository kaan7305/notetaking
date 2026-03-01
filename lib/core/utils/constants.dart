import 'package:flutter/painting.dart';

import '../models/text_element.dart';

// ---------------------------------------------------------------------------
// Text-box height helper
// ---------------------------------------------------------------------------

/// Returns the estimated rendered height of [el] using [TextPainter].
///
/// Properly accounts for multi-line content and word wrapping within the
/// element's declared [TextElement.width], making hit-testing and selection
/// bounds accurate for both single- and multi-line text boxes.
double estimateTextBoxHeight(TextElement el) {
  final span = TextSpan(
    // Use a non-empty string so TextPainter returns at least one line height.
    text: el.content.isEmpty ? ' ' : el.content,
    style: TextStyle(
      fontSize: el.fontSize,
      fontFamily: el.fontFamily == 'system' ? null : el.fontFamily,
      fontWeight: el.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: el.isItalic ? FontStyle.italic : FontStyle.normal,
    ),
  );
  final painter = TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
  );
  painter.layout(maxWidth: el.width);
  return (painter.height + AppDimensions.textBoxVerticalPadding)
      .clamp(AppDimensions.textBoxMinHeight, double.infinity);
}

// ---------------------------------------------------------------------------

/// Layout dimensions, page sizes, and timing constants used throughout the app.
class AppDimensions {
  AppDimensions._();

  // Sidebar & navigation
  static const double sidebarWidth = 280.0;
  static const double pageSidebarWidth = 200.0;

  // Toolbar & bars
  static const double toolbarHeight = 48.0;
  static const double colorRowHeight = 44.0;
  static const double bottomBarHeight = 48.0;

  // Thumbnails
  static const double thumbnailWidth = 120.0;
  static const double thumbnailHeight = 160.0;

  // Page sizes (in points)
  static const double letterWidth = 612.0;
  static const double letterHeight = 792.0;
  static const double a4Width = 595.0;
  static const double a4Height = 842.0;

  // Canvas zoom
  static const double canvasMinZoom = 0.5;
  static const double canvasMaxZoom = 3.0;

  // Undo / redo
  static const int maxUndoSteps = 50;

  // Input validation
  static const int maxNameLength = 100;

  // Timing (milliseconds)
  static const int autoSaveDelayMs = 2000;
  static const int syncIntervalMs = 60000;

  // Text box
  /// Width of the delete button shown beside an active text box.
  static const double textBoxDeleteButtonWidth = 28.0;
  /// Total vertical padding (top + bottom) added around the text content
  /// when estimating a text box's rendered height.
  static const double textBoxVerticalPadding = 12.0;
  /// Minimum hit-test height for any text box (a single-line empty box).
  static const double textBoxMinHeight = 28.0;
  /// Default width assigned to a newly created text box.
  static const double textBoxDefaultWidth = 200.0;

  // Selection / hit testing
  /// Inflate radius applied to selection bounds for the drag-to-move hit zone.
  static const double selectionInflateHitTest = 12.0;
  /// Distance (in canvas points) within which a pointer is considered to have
  /// hit a stroke point during pointer-tool selection.
  static const double strokeHitTestThreshold = 20.0;

  // Copy / paste
  /// Offset (in canvas points) applied to pasted content so it doesn't land
  /// exactly on top of the original.
  static const double pasteOffset = 24.0;
}

/// User‑facing strings.
///
/// Gathered here so they can easily be swapped for a localisation system
/// (e.g. `intl` / ARB files) later.
class AppStrings {
  AppStrings._();

  // ---------------------------------------------------------------------------
  // General
  // ---------------------------------------------------------------------------
  static const String appTitle = 'StudyNotebook';

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  static const String login = 'Log In';
  static const String signup = 'Sign Up';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';

  // ---------------------------------------------------------------------------
  // Course CRUD
  // ---------------------------------------------------------------------------
  static const String courses = 'Courses';
  static const String newCourse = 'New Course';
  static const String editCourse = 'Edit Course';
  static const String deleteCourse = 'Delete Course';
  static const String courseName = 'Course Name';

  // ---------------------------------------------------------------------------
  // Notebook CRUD
  // ---------------------------------------------------------------------------
  static const String notebooks = 'Notebooks';
  static const String newNotebook = 'New Notebook';
  static const String editNotebook = 'Edit Notebook';
  static const String deleteNotebook = 'Delete Notebook';
  static const String notebookTitle = 'Notebook Title';

  // ---------------------------------------------------------------------------
  // Tools
  // ---------------------------------------------------------------------------
  static const String pen = 'Pen';
  static const String highlighter = 'Highlighter';
  static const String eraser = 'Eraser';
  static const String text = 'Text';
  static const String lasso = 'Lasso';

  // ---------------------------------------------------------------------------
  // Pen Styles
  // ---------------------------------------------------------------------------
  static const String penStyleStandard = 'Standard';
  static const String penStyleCalligraphy = 'Calligraphy';
  static const String penStyleFountain = 'Fountain';
  static const String penStyleMarker = 'Marker';
  static const String penStyleFineLiner = 'Fine Liner';
  static const String penStylePencil = 'Pencil';
  static const String selectPenStyle = 'Pen Style';

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------
  static const String selectionLasso = 'Lasso Select';
  static const String selectionBox = 'Box Select';
  static const String deleteSelected = 'Delete Selected';
  static const String clearSelection = 'Clear Selection';
  static const String copySelected = 'Copy';
  static const String pasteContent = 'Paste';

  // ---------------------------------------------------------------------------
  // AI Modes
  // ---------------------------------------------------------------------------
  static const String aiHint = 'Hint';
  static const String aiCheck = 'Check';
  static const String aiSolve = 'Solve';
  static const String aiHintDescription =
      'Get a helpful hint without revealing the full answer.';
  static const String aiCheckDescription =
      'Check your work and see where you went wrong.';
  static const String aiSolveDescription =
      'See the complete step‑by‑step solution.';

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------
  static const String noCourses = 'No courses yet. Tap + to create one.';
  static const String noNotebooks =
      'No notebooks yet. Tap + to create one.';
  static const String noPages = 'This notebook has no pages.';
  static const String noSearchResults = 'No results found.';

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------
  static const String exportPage = 'Export Page';
  static const String exportPageSubject = 'Notebook Page';
  static const String exportError = 'Could not export the page.';

  // ---------------------------------------------------------------------------
  // Errors
  // ---------------------------------------------------------------------------
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Unable to connect. Check your internet connection.';
  static const String authError = 'Authentication failed. Please log in again.';
  static const String saveError = 'Could not save your changes.';
  static const String loadError = 'Could not load the requested data.';
  static const String nameTooLong =
      'Name must be ${AppDimensions.maxNameLength} characters or fewer.';
}
