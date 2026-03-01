import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';

import '../canvas/canvas_notifier.dart';

/// Sub-toolbar shown when the lasso tool is active, with mode toggle and delete.
class SelectionToolbar extends ConsumerWidget {
  final String pageId;

  const SelectionToolbar({super.key, required this.pageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider(pageId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Segmented selection mode toggle
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252838) : const Color(0xFFEEF0F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SegmentButton(
                  label: 'Lasso',
                  icon: Icons.gesture_rounded,
                  isSelected:
                      canvasState.selectionMode == SelectionMode.freeform,
                  onTap: () => ref
                      .read(canvasProvider(pageId).notifier)
                      .setSelectionMode(SelectionMode.freeform),
                  isDark: isDark,
                ),
                const SizedBox(width: 2),
                _SegmentButton(
                  label: 'Box',
                  icon: Icons.crop_square_rounded,
                  isSelected: canvasState.selectionMode == SelectionMode.box,
                  onTap: () => ref
                      .read(canvasProvider(pageId).notifier)
                      .setSelectionMode(SelectionMode.box),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (canvasState.hasSelection) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${canvasState.selectedStrokeIds.length} selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref
                    .read(canvasProvider(pageId).notifier)
                    .deleteSelectedStrokes(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
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
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.toolbarActiveDark : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                      : AppColors.onSurfaceLight.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
