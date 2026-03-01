import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/utils/constants.dart';

import '../canvas/canvas_notifier.dart';
import 'color_picker_row.dart';
import 'pen_style_picker.dart';
import 'selection_toolbar.dart';
import 'stroke_width_slider.dart';

/// Top toolbar for the notebook screen with drawing tools, undo/redo, etc.
class NotebookToolbar extends ConsumerStatefulWidget {
  final String pageId;
  final VoidCallback? onTogglePageSidebar;
  final VoidCallback? onToggleAiPanel;
  final bool isAiPanelOpen;
  /// Called when the user taps the export (share) button.
  final VoidCallback? onExportPage;

  const NotebookToolbar({
    super.key,
    required this.pageId,
    this.onTogglePageSidebar,
    this.onToggleAiPanel,
    this.isAiPanelOpen = false,
    this.onExportPage,
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
        // Main toolbar
        Container(
          height: AppDimensions.toolbarHeight + 4,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.toolbarBackgroundDark
                : AppColors.toolbarBackgroundLight,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppColors.toolbarDividerDark
                    : AppColors.toolbarDivider,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              // Back button
              _ModernToolbarButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go('/home'),
                tooltip: 'Back to Home',
                isDark: isDark,
              ),
              _toolbarDivider(isDark),

              // Page sidebar toggle
              if (widget.onTogglePageSidebar != null)
                _ModernToolbarButton(
                  icon: Icons.view_sidebar_rounded,
                  onPressed: widget.onTogglePageSidebar!,
                  tooltip: 'Pages',
                  isDark: isDark,
                ),
              _toolbarDivider(isDark),

              const SizedBox(width: 2),

              // Drawing tools group — pill container
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252838)
                      : const Color(0xFFEEF0F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToolPillButton(
                      icon: Icons.near_me_rounded,
                      tool: ToolType.pointer,
                      currentTool: canvasState.currentTool,
                      onPressed: () => _selectTool(ToolType.pointer),
                      isDark: isDark,
                    ),
                    _ToolPillButton(
                      icon: Icons.edit_rounded,
                      tool: ToolType.pen,
                      currentTool: canvasState.currentTool,
                      onPressed: () {
                        if (canvasState.currentTool == ToolType.pen) {
                          _showPenStylePicker(
                              context, canvasState.currentPenStyle);
                        } else {
                          _selectTool(ToolType.pen);
                        }
                      },
                      isDark: isDark,
                    ),
                    _ToolPillButton(
                      icon: Icons.format_color_fill_rounded,
                      tool: ToolType.highlighter,
                      currentTool: canvasState.currentTool,
                      onPressed: () => _selectTool(ToolType.highlighter),
                      isDark: isDark,
                    ),
                    _ToolPillButton(
                      icon: Icons.auto_fix_high_rounded,
                      tool: ToolType.eraser,
                      currentTool: canvasState.currentTool,
                      onPressed: () => _selectTool(ToolType.eraser),
                      isDark: isDark,
                    ),
                    _ToolPillButton(
                      icon: Icons.gesture_rounded,
                      tool: ToolType.lasso,
                      currentTool: canvasState.currentTool,
                      onPressed: () => _selectTool(ToolType.lasso),
                      isDark: isDark,
                    ),
                    _ToolPillButton(
                      icon: Icons.text_fields_rounded,
                      tool: ToolType.text,
                      currentTool: canvasState.currentTool,
                      onPressed: () => _selectTool(ToolType.text),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              _toolbarDivider(isDark),

              // Color indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _ColorIndicatorButton(
                  color: canvasState.currentColor,
                  isActive: _showColorPicker,
                  onPressed: () => setState(() {
                    _showColorPicker = !_showColorPicker;
                    _showStrokeWidth = false;
                  }),
                  isDark: isDark,
                ),
              ),

              // Stroke width button
              _ModernToolbarButton(
                icon: Icons.line_weight_rounded,
                onPressed: () => setState(() {
                  _showStrokeWidth = !_showStrokeWidth;
                  _showColorPicker = false;
                }),
                tooltip: 'Stroke Width',
                isDark: isDark,
                isActive: _showStrokeWidth,
              ),

              const Spacer(),

              // Delete selected stroke(s)
              if ((canvasState.currentTool == ToolType.pointer ||
                      canvasState.currentTool == ToolType.lasso) &&
                  canvasState.hasSelection)
                _ModernToolbarButton(
                  icon: Icons.delete_rounded,
                  iconColor: AppColors.error,
                  onPressed: () => ref
                      .read(canvasProvider(widget.pageId).notifier)
                      .deleteSelectedStrokes(),
                  tooltip: 'Delete selected',
                  isDark: isDark,
                ),

              // Undo / Redo group
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252838)
                      : const Color(0xFFEEF0F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModernToolbarButton(
                      icon: Icons.undo_rounded,
                      onPressed: canvasState.canUndo ? () => _undo() : null,
                      tooltip: 'Undo',
                      isDark: isDark,
                      compact: true,
                    ),
                    _ModernToolbarButton(
                      icon: Icons.redo_rounded,
                      onPressed: canvasState.canRedo ? () => _redo() : null,
                      tooltip: 'Redo',
                      isDark: isDark,
                      compact: true,
                    ),
                  ],
                ),
              ),

              _toolbarDivider(isDark),

              // Export page button
              if (widget.onExportPage != null)
                _ModernToolbarButton(
                  icon: Icons.ios_share_rounded,
                  onPressed: widget.onExportPage,
                  tooltip: AppStrings.exportPage,
                  isDark: isDark,
                ),

              // AI Assistant toggle
              if (widget.onToggleAiPanel != null)
                _AiToggleButton(
                  isActive: widget.isAiPanelOpen,
                  onPressed: widget.onToggleAiPanel!,
                  isDark: isDark,
                ),
            ],
          ),
        ),

        // Color picker row
        if (_showColorPicker && canvasState.currentTool != ToolType.text)
          ColorPickerRow(
            selectedColor: canvasState.currentColor,
            onColorSelected: (color) {
              ref
                  .read(canvasProvider(widget.pageId).notifier)
                  .selectColor(color);
            },
          ),

        // Stroke width slider
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
              final notifier =
                  ref.read(canvasProvider(widget.pageId).notifier);
              if (canvasState.currentTool == ToolType.highlighter) {
                notifier.setHighlighterWidth(value);
              } else if (canvasState.currentTool == ToolType.eraser) {
                notifier.setEraserRadius(value);
              } else {
                notifier.setStrokeWidth(value);
              }
            },
          ),

        // Text formatting toolbar
        if (canvasState.currentTool == ToolType.text)
          _TextFormatToolbar(pageId: widget.pageId),

        // Selection toolbar
        if (canvasState.currentTool == ToolType.lasso)
          SelectionToolbar(pageId: widget.pageId),
      ],
    );
  }

  Widget _toolbarDivider(bool isDark) => Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.toolbarDividerDark : AppColors.toolbarDivider,
          borderRadius: BorderRadius.circular(1),
        ),
      );

  void _selectTool(ToolType tool) {
    ref.read(canvasProvider(widget.pageId).notifier).selectTool(tool);
    setState(() {
      _showColorPicker = false;
      _showStrokeWidth = false;
    });
  }

  void _undo() => ref.read(canvasProvider(widget.pageId).notifier).undo();
  void _redo() => ref.read(canvasProvider(widget.pageId).notifier).redo();

  void _showPenStylePicker(BuildContext context, PenStyle current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => PenStylePicker(
        currentStyle: current,
        onStyleSelected: (style) {
          ref
              .read(canvasProvider(widget.pageId).notifier)
              .selectPenStyle(style);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// A tool button inside the pill container with animated active state.
class _ToolPillButton extends StatelessWidget {
  final IconData icon;
  final ToolType tool;
  final ToolType currentTool;
  final VoidCallback onPressed;
  final bool isDark;

  const _ToolPillButton({
    required this.icon,
    required this.tool,
    required this.currentTool,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = tool == currentTool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.toolbarActiveDark : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A modern toolbar icon button with subtle hover effect.
class _ModernToolbarButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isDark;
  final bool isActive;
  final bool compact;

  const _ModernToolbarButton({
    required this.icon,
    this.iconColor,
    required this.onPressed,
    required this.tooltip,
    required this.isDark,
    this.isActive = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(compact ? 6 : 8),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark
                      ? AppColors.toolbarActiveDark
                      : AppColors.toolbarActiveLight)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: compact ? 18 : 20,
              color: iconColor ??
                  (onPressed == null
                      ? (isDark
                          ? AppColors.onSurfaceDark.withValues(alpha: 0.2)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.2))
                      : isActive
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                              : AppColors.onSurfaceLight
                                  .withValues(alpha: 0.6))),
            ),
          ),
        ),
      ),
    );
  }
}

/// Color indicator circle with selection ring.
class _ColorIndicatorButton extends StatelessWidget {
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;
  final bool isDark;

  const _ColorIndicatorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Color',
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.toolbarDividerDark
                      : AppColors.toolbarDivider),
              width: isActive ? 2.5 : 1.5,
            ),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The AI toggle with a gradient active state.
class _AiToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final bool isDark;

  const _AiToggleButton({
    required this.isActive,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'AI Assistant',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (isDark
                      ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                      : AppColors.onSurfaceLight.withValues(alpha: 0.5)),
            ),
          ),
        ),
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
    ('#EF4444', Color(0xFFEF4444)),
    ('#3B82F6', Color(0xFF3B82F6)),
    ('#22C55E', Color(0xFF22C55E)),
    ('#F97316', Color(0xFFF97316)),
    ('#A855F7', Color(0xFFA855F7)),
    ('#78716C', Color(0xFF78716C)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider(pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.toolbarBackgroundDark
            : AppColors.toolbarBackgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.toolbarDividerDark
                : AppColors.toolbarDivider,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (activeEl == null)
            Text(
              'Tap on the page to add a text box',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.3),
              ),
            )
          else ...[
            // Font size controls in a pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252838) : const Color(0xFFEEF0F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _miniIconButton(
                    Icons.remove_rounded,
                    sizeIdx > 0
                        ? () => updateEl(
                            (el) => el.copyWith(fontSize: _fontSizes[sizeIdx - 1]))
                        : null,
                    isDark,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${currentSize.toInt()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                  _miniIconButton(
                    Icons.add_rounded,
                    lastSizeIdx < _fontSizes.length - 1
                        ? () => updateEl((el) =>
                            el.copyWith(fontSize: _fontSizes[lastSizeIdx + 1]))
                        : null,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1,
              height: 20,
              color: isDark
                  ? AppColors.toolbarDividerDark
                  : AppColors.toolbarDivider,
            ),
            const SizedBox(width: 10),
            // Bold / Italic toggles in a pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252838) : const Color(0xFFEEF0F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _FormatToggleButton(
                    label: 'B',
                    isActive: activeEl?.isBold ?? false,
                    isBoldLabel: true,
                    onTap: () =>
                        updateEl((el) => el.copyWith(isBold: !el.isBold)),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 2),
                  _FormatToggleButton(
                    label: 'I',
                    isActive: activeEl?.isItalic ?? false,
                    isBoldLabel: false,
                    onTap: () =>
                        updateEl((el) => el.copyWith(isItalic: !el.isItalic)),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 1,
              height: 20,
              color: isDark
                  ? AppColors.toolbarDividerDark
                  : AppColors.toolbarDivider,
            ),
            const SizedBox(width: 10),
            // Color swatches
            for (final c in _colorOptions)
              GestureDetector(
                onTap: () => updateEl((el) => el.copyWith(color: c.$1)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: c.$2,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColor == c.$1
                          ? AppColors.primary
                          : (c.$2 == Colors.white
                              ? (isDark
                                  ? AppColors.toolbarDividerDark
                                  : Colors.grey.shade300)
                              : Colors.transparent),
                      width: currentColor == c.$1 ? 2.5 : 1,
                    ),
                    boxShadow: currentColor == c.$1
                        ? [
                            BoxShadow(
                              color: c.$2.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: -1,
                            ),
                          ]
                        : null,
                  ),
                  child: currentColor == c.$1
                      ? Icon(Icons.check_rounded,
                          size: 12,
                          color: c.$1 == '#FFFFFF'
                              ? Colors.black54
                              : Colors.white)
                      : null,
                ),
              ),
            const Spacer(),
            // Delete active text element
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref
                    .read(canvasProvider(pageId).notifier)
                    .deleteTextElement(activeEl.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniIconButton(IconData icon, VoidCallback? onPressed, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: onPressed == null
                ? (isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.2)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.2))
                : (isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}

/// A toggle button for Bold / Italic text formatting.
class _FormatToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isBoldLabel;
  final VoidCallback onTap;
  final bool isDark;

  const _FormatToggleButton({
    required this.label,
    required this.isActive,
    required this.isBoldLabel,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.toolbarActiveDark : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBoldLabel ? FontWeight.w900 : FontWeight.w500,
            fontStyle: isBoldLabel ? FontStyle.normal : FontStyle.italic,
            color: isActive
                ? Colors.white
                : (isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}
