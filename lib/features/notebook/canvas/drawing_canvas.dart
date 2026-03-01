import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';

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

  const DrawingCanvas({
    super.key,
    required this.pageId,
    required this.templateType,
    required this.pageSize,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.lineSpacing = 32.0,
  });

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  Offset? _hoverPosition;
  late final FocusNode _focusNode;

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

    return Focus(
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
        child: Listener(
          onPointerDown: (event) {
            _focusNode.requestFocus();
            final notifier = ref.read(canvasProvider(widget.pageId).notifier);
            if (canvasState.currentTool == ToolType.text) {
              _createTextAt(event.localPosition, notifier, canvasState);
              return;
            }
            // Lasso: tap outside to clear existing selection.
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
            if (canvasState.currentTool == ToolType.text) return;
            final notifier = ref.read(canvasProvider(widget.pageId).notifier);
            notifier.onPointerMove(
              event.localPosition,
              event.pressure > 0 ? event.pressure : 0.5,
            );
            setState(() => _hoverPosition = event.localPosition);
          },
          onPointerUp: (_) {
            if (canvasState.currentTool == ToolType.text) return;
            ref.read(canvasProvider(widget.pageId).notifier).onPointerUp();
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
                  ),
                // Floating selection action menu.
                if (canvasState.hasSelection && !canvasState.isSelecting)
                  _SelectionActionMenu(
                    selectedCount: canvasState.selectedStrokeIds.length,
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
  }

  void _createTextAt(
      Offset position, CanvasNotifier notifier, CanvasState state) {
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

    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Floating action menu shown above selected strokes.
class _SelectionActionMenu extends StatelessWidget {
  final int selectedCount;
  final Rect selectionBounds;
  final VoidCallback onDelete;

  const _SelectionActionMenu({
    required this.selectedCount,
    required this.selectionBounds,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final menuY = (selectionBounds.top - 50).clamp(0.0, double.infinity);
    final menuX = (selectionBounds.center.dx - 60).clamp(0.0, double.infinity);

    return Positioned(
      left: menuX,
      top: menuY,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selectedCount selected',
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete selected',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An editable text box positioned on the canvas.
class _TextBox extends StatefulWidget {
  final TextElement element;
  final bool isActive;
  final ValueChanged<TextElement> onChanged;
  final VoidCallback onTap;
  final VoidCallback onDeactivate;

  const _TextBox({
    super.key,
    required this.element,
    required this.isActive,
    required this.onChanged,
    required this.onTap,
    required this.onDeactivate,
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
      if (!_focus.hasFocus) widget.onDeactivate();
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.element.x,
      top: widget.element.y,
      width: widget.element.width,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: widget.isActive
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                )
              : null,
          child: TextField(
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
