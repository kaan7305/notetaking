import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/models/models.dart';

/// Content held in the in-memory canvas clipboard.
///
/// Strokes and text elements are stored with their original coordinates
/// so that relative positions are preserved when pasting to a different page.
class ClipboardContent {
  final List<Stroke> strokes;
  final List<TextElement> textElements;

  const ClipboardContent({
    required this.strokes,
    required this.textElements,
  });

  bool get isEmpty => strokes.isEmpty && textElements.isEmpty;
}

class ClipboardNotifier extends StateNotifier<ClipboardContent?> {
  ClipboardNotifier() : super(null);

  /// Stores copies of [strokes] and [textElements] in the clipboard.
  void copy(List<Stroke> strokes, List<TextElement> textElements) {
    if (strokes.isEmpty && textElements.isEmpty) return;
    state = ClipboardContent(
      strokes: List.unmodifiable(strokes),
      textElements: List.unmodifiable(textElements),
    );
  }

  void clear() => state = null;
}

/// Global clipboard provider shared across all pages.
final clipboardProvider =
    StateNotifierProvider<ClipboardNotifier, ClipboardContent?>(
  (ref) => ClipboardNotifier(),
);
