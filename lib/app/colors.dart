import 'package:flutter/material.dart';

/// Centralized color definitions for the StudyNotebook app.
///
/// All colors are defined as static constants so they can be referenced
/// throughout the widget tree without instantiating this class.
class AppColors {
  AppColors._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // General / Brand
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF5856D6);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Sidebar
  // ---------------------------------------------------------------------------
  static const Color sidebarBackground = Color(0xFF1C1C2E);
  static const Color sidebarItemActive = Color(0xFF2D2D44);
  static const Color sidebarText = Color(0xFFE0E0E0);

  // ---------------------------------------------------------------------------
  // Canvas
  // ---------------------------------------------------------------------------
  static const Color canvasBackground = Color(0xFFFFFFFF);
  static const Color canvasBackgroundDark = Color(0xFF2C2C2C);
  static const Color pageShadow = Color(0x20000000);

  // ---------------------------------------------------------------------------
  // Toolbar
  // ---------------------------------------------------------------------------
  static const Color toolbarBackgroundLight = Color(0xFFF5F5F5);
  static const Color toolbarBackgroundDark = Color(0xFF2A2A2A);
  static const Color toolbarDivider = Color(0xFFE0E0E0);

  // ---------------------------------------------------------------------------
  // Pen colors (Notability‑style color row, 10 swatches)
  // ---------------------------------------------------------------------------
  static const Color penWhite = Color(0xFFFFFFFF);
  static const Color penRed = Color(0xFFFF3B30);
  static const Color penPurple = Color(0xFFAF52DE);
  static const Color penOrange = Color(0xFFFF9500);
  static const Color penCyan = Color(0xFF5AC8FA);
  static const Color penMagenta = Color(0xFFFF2D55);
  static const Color penGreen = Color(0xFF34C759);
  static const Color penYellow = Color(0xFFFFCC00);
  static const Color penBlack = Color(0xFF000000);
  static const Color penBlue = Color(0xFF007AFF);

  /// Ordered list that matches the visual color‑row in the toolbar.
  static const List<Color> penColors = [
    penWhite,
    penRed,
    penPurple,
    penOrange,
    penCyan,
    penMagenta,
    penGreen,
    penYellow,
    penBlack,
    penBlue,
  ];

  // ---------------------------------------------------------------------------
  // AI Panel modes
  // ---------------------------------------------------------------------------
  static const Color aiHintMode = Color(0xFF34C759);
  static const Color aiCheckMode = Color(0xFFFF9500);
  static const Color aiSolveMode = Color(0xFF007AFF);

  // ---------------------------------------------------------------------------
  // Status / Semantic
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5AC8FA);
}
