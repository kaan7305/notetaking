import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const NotebookToolbar({
    super.key,
    required this.pageId,
    this.onTogglePageSidebar,
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
                icon: Icons.edit,
                tool: ToolType.pen,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.pen),
              ),
              _ToolButton(
                icon: Icons.highlight,
                tool: ToolType.highlighter,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.highlighter),
              ),
              _ToolButton(
                icon: Icons.auto_fix_high,
                tool: ToolType.eraser,
                currentTool: canvasState.currentTool,
                onPressed: () => _selectTool(ToolType.eraser),
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
            ],
          ),
        ),

        // Color picker row.
        if (_showColorPicker)
          ColorPickerRow(
            selectedColor: canvasState.currentColor,
            onColorSelected: (color) {
              ref.read(canvasProvider(widget.pageId).notifier).selectColor(color);
            },
          ),

        // Stroke width slider.
        if (_showStrokeWidth)
          StrokeWidthSlider(
            value: canvasState.currentTool == ToolType.highlighter
                ? canvasState.highlighterWidth
                : canvasState.strokeWidth,
            onChanged: (value) {
              final notifier = ref.read(canvasProvider(widget.pageId).notifier);
              if (canvasState.currentTool == ToolType.highlighter) {
                notifier.setHighlighterWidth(value);
              } else {
                notifier.setStrokeWidth(value);
              }
            },
          ),
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
