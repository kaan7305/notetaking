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
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFF6B8AFF);
  static const Color secondary = Color(0xFF7C5CFC);
  static const Color accent = Color(0xFF00D4AA);

  static const Color surfaceLight = Color(0xFFF8F9FC);
  static const Color surfaceDark = Color(0xFF13141A);

  static const Color onSurfaceLight = Color(0xFF1A1D26);
  static const Color onSurfaceDark = Color(0xFFF0F1F5);

  // ---------------------------------------------------------------------------
  // Sidebar
  // ---------------------------------------------------------------------------
  static const Color sidebarBackground = Color(0xFF1A1D2E);
  static const Color sidebarBackgroundLight = Color(0xFFF2F3F8);
  static const Color sidebarItemActive = Color(0xFF2A2D44);
  static const Color sidebarItemActiveLight = Color(0xFFE8EAFF);
  static const Color sidebarText = Color(0xFFBFC3D4);

  // ---------------------------------------------------------------------------
  // Canvas
  // ---------------------------------------------------------------------------
  static const Color canvasBackground = Color(0xFFFFFFFF);
  static const Color canvasBackgroundDark = Color(0xFF1E1F26);
  static const Color canvasAreaLight = Color(0xFFEBEDF4);
  static const Color canvasAreaDark = Color(0xFF0E0F14);
  static const Color pageShadow = Color(0x18000000);

  // ---------------------------------------------------------------------------
  // Toolbar — frosted glass style
  // ---------------------------------------------------------------------------
  static const Color toolbarBackgroundLight = Color(0xFFFAFBFE);
  static const Color toolbarBackgroundDark = Color(0xFF1E2030);
  static const Color toolbarDivider = Color(0xFFE4E7F0);
  static const Color toolbarDividerDark = Color(0xFF2A2D3E);
  static const Color toolbarActiveLight = Color(0xFFECEFFF);
  static const Color toolbarActiveDark = Color(0xFF2A3060);

  // ---------------------------------------------------------------------------
  // Cards & containers
  // ---------------------------------------------------------------------------
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E2030);
  static const Color cardBorderLight = Color(0xFFE8EAF0);
  static const Color cardBorderDark = Color(0xFF2E3148);
  static const Color cardHoverLight = Color(0xFFF4F5FA);
  static const Color cardHoverDark = Color(0xFF262840);

  // ---------------------------------------------------------------------------
  // Pen colors (modern vibrant palette, 10 swatches)
  // ---------------------------------------------------------------------------
  static const Color penWhite = Color(0xFFFFFFFF);
  static const Color penRed = Color(0xFFEF4444);
  static const Color penPurple = Color(0xFFA855F7);
  static const Color penOrange = Color(0xFFF97316);
  static const Color penCyan = Color(0xFF06B6D4);
  static const Color penMagenta = Color(0xFFEC4899);
  static const Color penGreen = Color(0xFF22C55E);
  static const Color penYellow = Color(0xFFEAB308);
  static const Color penBlack = Color(0xFF1A1D26);
  static const Color penBlue = Color(0xFF3B82F6);

  /// Ordered list that matches the visual color-row in the toolbar.
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
  static const Color aiHintMode = Color(0xFF22C55E);
  static const Color aiCheckMode = Color(0xFFF97316);
  static const Color aiSolveMode = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Status / Semantic
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // ---------------------------------------------------------------------------
  // Glassmorphism helpers
  // ---------------------------------------------------------------------------
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xAA1E2030);
  static const Color glassBorderLight = Color(0x40FFFFFF);
  static const Color glassBorderDark = Color(0x30FFFFFF);
}
