import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/utils/constants.dart';

import 'canvas_notifier.dart';
import 'canvas_state.dart';
import 'page_background_painter.dart';
import 'stroke_painter.dart';

/// The main drawing surface that handles pointer input and renders strokes.
class DrawingCanvas extends ConsumerStatefulWidget {
  final String pageId;
  final String templateType;
  final Size pageSize;
  final Color backgroundColor;
  final double lineSpacing;

  /// Optional key attached to the inner [RepaintBoundary] so callers can
  /// capture the rendered canvas as an image (e.g. for AI Check/Solve mode).
  final GlobalKey? captureKey;

  const DrawingCanvas({
    super.key,
    required this.pageId,
    required this.templateType,
    required this.pageSize,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.lineSpacing = 32.0,
    this.captureKey,
  });

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  Offset? _hoverPosition;
  late final FocusNode _focusNode;

  // Selection drag-to-move state.
  bool _isDraggingSelection = false;
  Offset? _selectionDragAnchor;
  bool _selectionDragPushedUndo = false;

  // Multi-touch tracking: count how many pointers are currently pressed.
  // Drawing is suppressed when >1 finger is down so a two-finger pinch-to-zoom
  // gesture is not confused with a drawing stroke.
  int _activePointerCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider(widget.pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canvas = Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.delete ||
                event.logicalKey == LogicalKeyboardKey.backspace)) {
          if (canvasState.hasSelection) {
            ref
                .read(canvasProvider(widget.pageId).notifier)
                .deleteSelectedStrokes();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: ClipRect(
      child: RepaintBoundary(
        key: widget.captureKey,
        child: Listener(
          onPointerDown: (event) {
            _activePointerCount++;
            _focusNode.requestFocus();
            final notifier = ref.read(canvasProvider(widget.pageId).notifier);

            // When a second finger comes down (pinch gesture starting), cancel
            // any in-progress stroke/lasso and abort any selection drag so the
            // InteractiveViewer can handle the pinch-to-zoom cleanly.
            if (_activePointerCount > 1) {
              notifier.cancelActiveGesture();
              _isDraggingSelection = false;
              _selectionDragAnchor = null;
              return;
            }

            if (canvasState.currentTool == ToolType.text) {
              _handleTextTap(event.localPosition, notifier, canvasState);
              return;
            }

            // If there's a selection, check if the pointer is within the
            // selection bounds — if so, start a drag-to-move gesture.
            if (canvasState.hasSelection &&
                !canvasState.isSelecting &&
                (canvasState.currentTool == ToolType.pointer ||
                    canvasState.currentTool == ToolType.lasso)) {
              final bounds = _computeSelectionBounds(canvasState);
              if (!bounds.isEmpty &&
                  bounds.inflate(12).contains(event.localPosition)) {
                _isDraggingSelection = true;
                _selectionDragAnchor = event.localPosition;
                _selectionDragPushedUndo = false;
                return;
              }
            }

            // Lasso: tap outside selection to clear it and start new selection.
            if (canvasState.currentTool == ToolType.lasso &&
                canvasState.hasSelection &&
                !canvasState.isSelecting) {
              notifier.clearSelection();
              return;
            }
            notifier.onPointerDown(
              event.localPosition,
              event.pressure > 0 ? event.pressure : 0.5,
            );
          },
          onPointerMove: (event) {
            // Suppress all canvas drawing/interaction during multi-touch
            // (two-finger pinch-to-zoom is handled by InteractiveViewer).
            if (_activePointerCount > 1) return;
            if (canvasState.currentTool == ToolType.text) return;
            final notifier = ref.read(canvasProvider(widget.pageId).notifier);

            // Handle selection drag-to-move.
            if (_isDraggingSelection && _selectionDragAnchor != null) {
              if (!_selectionDragPushedUndo) {
                notifier.pushUndoForMoveSnapshot();
                _selectionDragPushedUndo = true;
              }
              final delta = event.localPosition - _selectionDragAnchor!;
              _selectionDragAnchor = event.localPosition;
              notifier.moveSelectedByDelta(delta);
              setState(() => _hoverPosition = event.localPosition);
              return;
            }

            notifier.onPointerMove(
              event.localPosition,
              event.pressure > 0 ? event.pressure : 0.5,
            );
            setState(() => _hoverPosition = event.localPosition);
          },
          onPointerUp: (_) {
            _activePointerCount = (_activePointerCount - 1).clamp(0, 10);

            // If we're still in a multi-touch gesture (other fingers still
            // down), don't commit a stroke.
            if (_activePointerCount > 0) return;

            if (_isDraggingSelection) {
              _isDraggingSelection = false;
              _selectionDragAnchor = null;
              ref
                  .read(canvasProvider(widget.pageId).notifier)
                  .finalizeSelectionMove();
              return;
            }
            if (canvasState.currentTool == ToolType.text) return;
            ref.read(canvasProvider(widget.pageId).notifier).onPointerUp();
          },
          onPointerCancel: (_) {
            // OS cancelled the pointer (e.g., InteractiveViewer took over).
            _activePointerCount = (_activePointerCount - 1).clamp(0, 10);
            if (_activePointerCount == 0) {
              _isDraggingSelection = false;
              _selectionDragAnchor = null;
            }
          },
          onPointerHover: (event) {
            setState(() => _hoverPosition = event.localPosition);
          },
          child: MouseRegion(
            onExit: (_) => setState(() => _hoverPosition = null),
            cursor: _cursorForTool(canvasState.currentTool),
            child: Stack(
              children: [
                // Page background (template pattern).
                CustomPaint(
                  size: widget.pageSize,
                  painter: PageBackgroundPainter(
                    templateType: widget.templateType,
                    lineSpacing: widget.lineSpacing,
                    lineColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : null,
                  ),
                ),
                // Strokes layer.
                CustomPaint(
                  size: widget.pageSize,
                  painter: StrokePainter(
                    strokes: canvasState.strokes,
                    activeStroke: canvasState.activeStroke,
                    selectedStrokeIds: canvasState.selectedStrokeIds,
                    selectionLassoPoints: canvasState.selectionLassoPoints,
                    selectionRect: canvasState.selectionRect,
                    isSelecting: canvasState.isSelecting,
                  ),
                ),
                // Text elements.
                for (final el in canvasState.textElements)
                  _TextBox(
                    key: ValueKey(el.id),
                    element: el,
                    isActive: el.id == canvasState.activeTextId,
                    isSelected: canvasState.selectedTextIds.contains(el.id),
                    onChanged: (updated) {
                      ref
                          .read(canvasProvider(widget.pageId).notifier)
                          .updateTextElement(updated);
                    },
                    onTap: () {
                      ref
                          .read(canvasProvider(widget.pageId).notifier)
                          .setActiveText(el.id);
                    },
                    onDeactivate: () {
                      ref
                          .read(canvasProvider(widget.pageId).notifier)
                          .setActiveText(null);
                    },
                    onDelete: () {
                      ref
                          .read(canvasProvider(widget.pageId).notifier)
                          .deleteTextElement(el.id);
                    },
                    // Allow dragging text elements when the text tool is active
                    // and the element is not currently being edited.
                    onPositionChanged: canvasState.currentTool == ToolType.text
                        ? (x, y) => ref
                            .read(canvasProvider(widget.pageId).notifier)
                            .updateTextElement(el.copyWith(x: x, y: y))
                        : null,
                  ),
                // Floating selection action menu — always in tree so it can
                // animate in/out smoothly via FadeTransition + ScaleTransition.
                _SelectionActionMenu(
                  isVisible: canvasState.hasSelection && !canvasState.isSelecting,
                  selectedCount: canvasState.selectedStrokeIds.length +
                      canvasState.selectedTextIds.length,
                  selectionBounds: _computeSelectionBounds(canvasState),
                  onDelete: () {
                    ref
                        .read(canvasProvider(widget.pageId).notifier)
                        .deleteSelectedStrokes();
                  },
                ),
                // Cursor preview overlay.
                if (_hoverPosition != null &&
                    canvasState.currentTool != ToolType.text)
                  CustomPaint(
                    size: widget.pageSize,
                    painter: _CursorPreviewPainter(
                      position: _hoverPosition!,
                      tool: canvasState.currentTool,
                      strokeWidth: canvasState.strokeWidth,
                      highlighterWidth: canvasState.highlighterWidth,
                      eraserRadius: canvasState.eraserRadius,
                      color: canvasState.currentColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

    // Overlay a dismissible error banner when the initial DB load failed.
    if (canvasState.loadError != null) {
      return Stack(
        children: [
          canvas,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _LoadErrorBanner(
              message: canvasState.loadError!,
              isDark: isDark,
              onDismiss: () => ref
                  .read(canvasProvider(widget.pageId).notifier)
                  .dismissLoadError(),
            ),
          ),
        ],
      );
    }

    return canvas;
  }

  void _handleTextTap(
      Offset position, CanvasNotifier notifier, CanvasState state) {
    // Check if the tap hit an existing text box.
    for (final el in state.textElements) {
      final textRect = Rect.fromLTWH(el.x, el.y, el.width + 28, 40);
      if (textRect.contains(position)) {
        // Already active — don't re-set state so child widgets (delete btn)
        // keep their gesture tracking and can handle the tap.
        if (el.id == state.activeTextId) return;
        // Tapped on an inactive text box — activate it.
        notifier.setActiveText(el.id);
        return;
      }
    }

    // If there's an active text, deactivate it first instead of creating new.
    if (state.activeTextId != null) {
      notifier.setActiveText(null);
      return;
    }

    // Create a new text box at the tapped position.
    final element = TextElement(
      id: const Uuid().v4(),
      pageId: widget.pageId,
      content: '',
      x: position.dx,
      y: position.dy,
      width: 200,
      fontSize: 16.0,
      fontFamily: 'system',
      color: '#${state.currentColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
      createdAt: DateTime.now(),
    );
    notifier.addTextElement(element);
  }

  MouseCursor _cursorForTool(ToolType tool) {
    switch (tool) {
      case ToolType.eraser:
        return SystemMouseCursors.precise;
      case ToolType.text:
        return SystemMouseCursors.text;
      case ToolType.pointer:
        return SystemMouseCursors.basic;
      case ToolType.lasso:
        return SystemMouseCursors.precise;
      default:
        return SystemMouseCursors.none;
    }
  }

  Rect _computeSelectionBounds(CanvasState canvasState) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final stroke in canvasState.strokes) {
      if (!canvasState.selectedStrokeIds.contains(stroke.id)) continue;
      for (final point in stroke.points) {
        if (point.x < minX) minX = point.x;
        if (point.y < minY) minY = point.y;
        if (point.x > maxX) maxX = point.x;
        if (point.y > maxY) maxY = point.y;
      }
    }

    for (final el in canvasState.textElements) {
      if (!canvasState.selectedTextIds.contains(el.id)) continue;
      if (el.x < minX) minX = el.x;
      if (el.y < minY) minY = el.y;
      if (el.x + el.width > maxX) maxX = el.x + el.width;
      if (el.y + 30 > maxY) maxY = el.y + 30;
    }

    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// A slim banner shown at the top of the canvas when the initial DB load fails.
///
/// The user can dismiss it; drawing still works for newly added content.
class _LoadErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onDismiss;

  const _LoadErrorBanner({
    required this.message,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.92),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${AppStrings.loadError} ($message)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating action menu shown above selected strokes.
///
/// Always present in the [Stack] so it can animate in and out smoothly via
/// [FadeTransition] + [ScaleTransition]. The last valid bounds are cached so
/// the menu fades out at its original position even after the selection clears.
class _SelectionActionMenu extends StatefulWidget {
  final bool isVisible;
  final int selectedCount;
  final Rect selectionBounds;
  final VoidCallback onDelete;

  const _SelectionActionMenu({
    required this.isVisible,
    required this.selectedCount,
    required this.selectionBounds,
    required this.onDelete,
  });

  @override
  State<_SelectionActionMenu> createState() => _SelectionActionMenuState();
}

class _SelectionActionMenuState extends State<_SelectionActionMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeCurve;
  late final Animation<double> _scaleCurve;

  /// The most recent non-empty bounds — used for position while fading out.
  Rect _lastKnownBounds = Rect.zero;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.isVisible ? 1.0 : 0.0,
    );
    final curved = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _fadeCurve = curved;
    _scaleCurve = Tween<double>(begin: 0.88, end: 1.0).animate(curved);

    if (!widget.selectionBounds.isEmpty) {
      _lastKnownBounds = widget.selectionBounds;
    }
  }

  @override
  void didUpdateWidget(_SelectionActionMenu old) {
    super.didUpdateWidget(old);
    // Cache bounds before selection clears so we fade out at the right spot.
    if (!widget.selectionBounds.isEmpty) {
      _lastKnownBounds = widget.selectionBounds;
    }
    if (widget.isVisible && !old.isVisible) {
      _ctrl.forward();
    } else if (!widget.isVisible && old.isVisible) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing to show yet (menu has never been visible).
    if (_lastKnownBounds.isEmpty) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuY = (_lastKnownBounds.top - 54).clamp(0.0, double.infinity);
    final menuX =
        (_lastKnownBounds.center.dx - 70).clamp(0.0, double.infinity);

    return Positioned(
      left: menuX,
      top: menuY,
      child: FadeTransition(
        opacity: _fadeCurve,
        child: ScaleTransition(
          scale: _scaleCurve,
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            // Block taps when invisible so the ghost menu doesn't eat gestures.
            ignoring: !widget.isVisible,
            child: _buildContent(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${widget.selectedCount}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color:
                  isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An editable text box positioned on the canvas.
class _TextBox extends StatefulWidget {
  final TextElement element;
  final bool isActive;
  final bool isSelected;
  final ValueChanged<TextElement> onChanged;
  final VoidCallback onTap;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;
  /// Called during drag with the new (x, y) position. Only provided when
  /// dragging is supported (text tool active, element not being edited).
  final void Function(double x, double y)? onPositionChanged;

  const _TextBox({
    super.key,
    required this.element,
    required this.isActive,
    this.isSelected = false,
    required this.onChanged,
    required this.onTap,
    required this.onDeactivate,
    required this.onDelete,
    this.onPositionChanged,
  });

  @override
  State<_TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<_TextBox> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.element.content);
    _focus = FocusNode();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _focus.requestFocus());
    }
    _focus.addListener(() {
      if (!_focus.hasFocus && widget.isActive) widget.onDeactivate();
    });
  }

  @override
  void didUpdateWidget(_TextBox old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _focus.requestFocus();
    }
    if (widget.element.content != _ctrl.text) {
      final sel = _ctrl.selection;
      _ctrl.text = widget.element.content;
      try {
        _ctrl.selection = sel;
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Color get _textColor {
    try {
      var hex = widget.element.color.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.black;
    }
  }

  BoxDecoration? get _boxDecoration {
    if (widget.isActive) {
      return BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.primary.withValues(alpha: 0.03),
      );
    }
    if (widget.isSelected) {
      return BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.7),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.primary.withValues(alpha: 0.06),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canDrag = !widget.isActive && widget.onPositionChanged != null;

    final textField = TextField(
      controller: _ctrl,
      focusNode: _focus,
      maxLines: null,
      style: TextStyle(
        fontSize: widget.element.fontSize,
        color: _textColor,
        fontFamily: widget.element.fontFamily == 'system'
            ? null
            : widget.element.fontFamily,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.all(4),
        hintText: 'Type here...',
      ),
      onChanged: (text) {
        widget.onChanged(widget.element.copyWith(content: text));
      },
    );

    // Use an explicit SizedBox width so the right-edge resize handle can be
    // positioned accurately via a Stack overlay (Expanded can't be used here
    // because we need to know the exact text-area width for the handle).
    final textContainer = Container(
      width: widget.element.width,
      decoration: _boxDecoration,
      child: textField,
    );

    // When active: overlay a right-edge drag handle for resizing width.
    // Stack(clipBehavior: Clip.none) lets the handle protrude slightly outside.
    final textArea = widget.isActive
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(onTap: widget.onTap, child: textContainer),
              Positioned(
                right: -7,
                top: 0,
                bottom: 0,
                child: _TextResizeHandle(
                  onPanUpdate: (dx) {
                    final newWidth =
                        (widget.element.width + dx).clamp(80.0, 1200.0);
                    widget.onChanged(widget.element.copyWith(width: newWidth));
                  },
                ),
              ),
            ],
          )
        : GestureDetector(
            onTap: canDrag ? null : widget.onTap,
            child: textContainer,
          );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        textArea,
        // Delete button — separate gesture zone, only visible when active.
        if (widget.isActive)
          GestureDetector(
            onTap: widget.onDelete,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
      ],
    );

    return Positioned(
      left: widget.element.x,
      top: widget.element.y,
      // No explicit width — Row + SizedBox content determines the width naturally.
      child: canDrag
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              onPanUpdate: (details) {
                widget.onPositionChanged!(
                  widget.element.x + details.delta.dx,
                  widget.element.y + details.delta.dy,
                );
              },
              child: row,
            )
          : row,
    );
  }
}

/// A thin vertical drag strip shown on the right edge of an active text box.
/// Dragging it horizontally resizes the box width.
class _TextResizeHandle extends StatefulWidget {
  /// Called with the horizontal delta (dx) on each pan update.
  final void Function(double dx) onPanUpdate;

  const _TextResizeHandle({required this.onPanUpdate});

  @override
  State<_TextResizeHandle> createState() => _TextResizeHandleState();
}

class _TextResizeHandleState extends State<_TextResizeHandle> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => widget.onPanUpdate(d.delta.dx),
        child: SizedBox(
          width: 14,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: _hovering ? 4 : 3,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: _hovering ? 0.85 : 0.45),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a tool-appropriate cursor preview at the current hover position.
class _CursorPreviewPainter extends CustomPainter {
  final Offset position;
  final ToolType tool;
  final double strokeWidth;
  final double highlighterWidth;
  final double eraserRadius;
  final Color color;

  const _CursorPreviewPainter({
    required this.position,
    required this.tool,
    required this.strokeWidth,
    required this.highlighterWidth,
    required this.eraserRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (tool) {
      case ToolType.pen:
        _drawPenPreview(canvas);
      case ToolType.highlighter:
        _drawHighlighterPreview(canvas);
      case ToolType.eraser:
        _drawEraserPreview(canvas);
      default:
        break;
    }
  }

  void _drawPenPreview(Canvas canvas) {
    final radius = (strokeWidth / 2).clamp(2.0, 16.0);
    canvas.drawCircle(position, radius, Paint()..color = color);
  }

  void _drawHighlighterPreview(Canvas canvas) {
    final halfH = highlighterWidth / 2;
    final rect =
        Rect.fromLTWH(position.dx - 2, position.dy - halfH, 4, highlighterWidth);
    canvas.drawRect(
        rect, Paint()..color = color.withValues(alpha: 0.35));
    canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  void _drawEraserPreview(Canvas canvas) {
    canvas.drawCircle(
        position,
        eraserRadius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3));
    canvas.drawCircle(
        position,
        eraserRadius,
        Paint()
          ..color = Colors.grey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_CursorPreviewPainter old) =>
      old.position != position ||
      old.tool != tool ||
      old.strokeWidth != strokeWidth ||
      old.highlighterWidth != highlighterWidth ||
      old.eraserRadius != eraserRadius ||
      old.color != color;
}
