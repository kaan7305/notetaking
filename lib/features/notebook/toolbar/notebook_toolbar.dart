import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/utils/constants.dart';

import '../canvas/canvas_notifier.dart';
import 'color_picker_row.dart';
import 'stroke_width_slider.dart';

/// Top toolbar for the notebook screen with drawing tools, undo/redo, etc.
class NotebookToolbar extends ConsumerStatefulWidget {
  final String pageId;
  final VoidCallback? onTogglePageSidebar;
  final VoidCallback? onToggleAiPanel;
  final bool isAiPanelOpen;

  const NotebookToolbar({
    super.key,
    required this.pageId,
    this.onTogglePageSidebar,
    this.onToggleAiPanel,
    this.isAiPanelOpen = false,
  });

  @override
  ConsumerState<NotebookToolbar> createState() => _NotebookToolbarState();
}

class _NotebookToolbarState extends ConsumerState<NotebookToolbar> {
  bool _showColorPicker = false;
  bool _showStrokeWidth = false;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider(widget.pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: AppDimensions.toolbarHeight,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.toolbarBackgroundDark
                : AppColors.toolbarBackgroundLight,
            border: Border(
              bottom: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Back to home.
              _ToolbarButton(
                icon: Icons.arrow_back,
                onPressed: () => context.go('/home'),
                tooltip: 'Back to Home',
              ),
              const VerticalDivider(width: 1),

              // Page sidebar toggle.
              if (widget.onTogglePageSidebar != null)
                _ToolbarButton(
                  icon: Icons.menu,
                  onPressed: widget.onTogglePageSidebar!,
                  tooltip: 'Pages',
                ),
              const VerticalDivider(width: 1),

              // Drawing tools.
              _ToolButton(
                icon: Icons.ads_click,
                tool: ToolType.pointer,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.pointer),
              ),
              _ToolButton(
                icon: Icons.edit,
                tool: ToolType.pen,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.pen),
              ),
              _ToolButton(
                icon: Icons.format_color_fill,
                tool: ToolType.highlighter,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.highlighter),
              ),
              _ToolButton(
                icon: Icons.cleaning_services,
                tool: ToolType.eraser,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.eraser),
              ),
              _ToolButton(
                icon: Icons.text_fields,
                tool: ToolType.text,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.text),
              ),

              const VerticalDivider(width: 1),

              // Color indicator button.
              _ToolbarButton(
                icon: Icons.circle,
                iconColor: canvasState.currentColor,
                onPressed: () => setState(() {
                  _showColorPicker = !_showColorPicker;
                  _showStrokeWidth = false;
                }),
                tooltip: 'Color',
              ),

              // Stroke width button.
              _ToolbarButton(
                icon: Icons.line_weight,
                onPressed: () => setState(() {
                  _showStrokeWidth = !_showStrokeWidth;
                  _showColorPicker = false;
                }),
                tooltip: 'Stroke Width',
              ),

              const Spacer(),

              // Delete selected stroke (pointer mode).
              if (canvasState.currentTool == ToolType.pointer &&
                  canvasState.selectedStrokeId != null)
                _ToolbarButton(
                  icon: Icons.delete,
                  iconColor: Colors.redAccent,
                  onPressed: () => ref
                      .read(canvasProvider(widget.pageId).notifier)
                      .deleteSelectedStroke(),
                  tooltip: 'Delete selected stroke',
                ),

              // Undo / Redo.
              _ToolbarButton(
                icon: Icons.undo,
                onPressed: canvasState.canUndo ? () => _undo() : null,
                tooltip: 'Undo',
              ),
              _ToolbarButton(
                icon: Icons.redo,
                onPressed: canvasState.canRedo ? () => _redo() : null,
                tooltip: 'Redo',
              ),

              const VerticalDivider(width: 1),

              // AI Assistant toggle.
              if (widget.onToggleAiPanel != null)
                _ToolbarButton(
                  icon: Icons.auto_awesome,
                  iconColor: widget.isAiPanelOpen ? AppColors.primary : null,
                  onPressed: widget.onToggleAiPanel!,
                  tooltip: 'AI Assistant',
                ),
            ],
          ),
        ),

        // Color picker row (hidden when text tool is active).
        if (_showColorPicker && canvasState.currentTool != ToolType.text)
          ColorPickerRow(
            selectedColor: canvasState.currentColor,
            onColorSelected: (color) {
              ref.read(canvasProvider(widget.pageId).notifier).selectColor(color);
            },
          ),

        // Stroke width / eraser radius slider (hidden when text tool is active).
        if (_showStrokeWidth && canvasState.currentTool != ToolType.text)
          StrokeWidthSlider(
            value: canvasState.currentTool == ToolType.highlighter
                ? canvasState.highlighterWidth
                : canvasState.currentTool == ToolType.eraser
                    ? canvasState.eraserRadius
                    : canvasState.strokeWidth,
            min: canvasState.currentTool == ToolType.eraser ? 5.0 : 1.0,
            max: canvasState.currentTool == ToolType.eraser ? 80.0 : 40.0,
            onChanged: (value) {
              final notifier = ref.read(canvasProvider(widget.pageId).notifier);
              if (canvasState.currentTool == ToolType.highlighter) {
                notifier.setHighlighterWidth(value);
              } else if (canvasState.currentTool == ToolType.eraser) {
                notifier.setEraserRadius(value);
              } else {
                notifier.setStrokeWidth(value);
              }
            },
          ),

        // Text formatting toolbar — shown whenever text tool is active.
        if (canvasState.currentTool == ToolType.text)
          _TextFormatToolbar(pageId: widget.pageId),
      ],
    );
  }

  void _selectTool(ToolType tool) {
    ref.read(canvasProvider(widget.pageId).notifier).selectTool(tool);
    setState(() {
      _showColorPicker = false;
      _showStrokeWidth = false;
    });
  }

  void _undo() => ref.read(canvasProvider(widget.pageId).notifier).undo();
  void _redo() => ref.read(canvasProvider(widget.pageId).notifier).redo();
}

/// A tool selection button that highlights when active.
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final ToolType tool;
  final ToolType currentTool;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.currentTool,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tool == currentTool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: isActive ? AppColors.primary : null,
        style: isActive
            ? IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              )
            : null,
        onPressed: onPressed,
        tooltip: tool.name,
      ),
    );
  }
}

/// Text formatting toolbar shown below the main toolbar when text tool is active.
class _TextFormatToolbar extends ConsumerWidget {
  final String pageId;

  const _TextFormatToolbar({required this.pageId});

  static const _fontSizes = [10.0, 12.0, 14.0, 16.0, 20.0, 24.0, 32.0, 48.0];
  static const _colorOptions = [
    ('#000000', Color(0xFF000000)),
    ('#FFFFFF', Color(0xFFFFFFFF)),
    ('#F44336', Color(0xFFF44336)),
    ('#2196F3', Color(0xFF2196F3)),
    ('#4CAF50', Color(0xFF4CAF50)),
    ('#FF9800', Color(0xFFFF9800)),
    ('#9C27B0', Color(0xFF9C27B0)),
    ('#795548', Color(0xFF795548)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider(pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the currently active text element.
    final activeId = canvasState.activeTextId;
    final candidates =
        canvasState.textElements.where((e) => e.id == activeId);
    final activeEl = candidates.isEmpty ? null : candidates.first;

    void updateEl(TextElement Function(TextElement) fn) {
      if (activeEl == null) return;
      ref.read(canvasProvider(pageId).notifier).updateTextElement(fn(activeEl));
    }

    final currentSize = activeEl?.fontSize ?? 16.0;
    final currentColor = activeEl?.color ?? '#000000';
    final sizeIdx = _fontSizes.indexWhere((s) => s >= currentSize);
    final lastSizeIdx = _fontSizes.lastIndexWhere((s) => s <= currentSize);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.toolbarBackgroundDark
            : AppColors.toolbarBackgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (activeEl == null)
            Text(
              'Click on the page to add a text box',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            )
          else ...[
            // Font size decrease.
            IconButton(
              icon: const Icon(Icons.text_decrease, size: 18),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: sizeIdx > 0
                  ? () => updateEl(
                      (el) => el.copyWith(fontSize: _fontSizes[sizeIdx - 1]))
                  : null,
              tooltip: 'Decrease font size',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${currentSize.toInt()}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            // Font size increase.
            IconButton(
              icon: const Icon(Icons.text_increase, size: 18),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: lastSizeIdx < _fontSizes.length - 1
                  ? () => updateEl((el) =>
                      el.copyWith(fontSize: _fontSizes[lastSizeIdx + 1]))
                  : null,
              tooltip: 'Increase font size',
            ),
            const SizedBox(width: 4),
            const VerticalDivider(width: 16, indent: 8, endIndent: 8),
            // Color swatches.
            for (final c in _colorOptions)
              GestureDetector(
                onTap: () => updateEl((el) => el.copyWith(color: c.$1)),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: c.$2,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColor == c.$1
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: currentColor == c.$1 ? 2.5 : 1,
                    ),
                  ),
                  child: currentColor == c.$1
                      ? Icon(Icons.check,
                          size: 10,
                          color: c.$1 == '#FFFFFF'
                              ? Colors.black54
                              : Colors.white)
                      : null,
                ),
              ),
            const Spacer(),
            // Delete active text element.
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => ref
                  .read(canvasProvider(pageId).notifier)
                  .deleteTextElement(activeEl.id),
              tooltip: 'Delete text box',
            ),
          ],
        ],
      ),
    );
  }
}

/// A generic toolbar icon button.
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ToolbarButton({
    required this.icon,
    this.iconColor,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22, color: iconColor),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
