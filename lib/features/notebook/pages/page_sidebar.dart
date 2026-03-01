import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/page_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/notebook/canvas/canvas_notifier.dart';
import 'package:study_notebook/features/notebook/canvas/page_background_painter.dart';
import 'package:study_notebook/features/notebook/canvas/stroke_painter.dart';

/// A side panel showing page thumbnails for the current notebook.
/// Pages can be reordered by dragging the handle icon at the bottom of each
/// thumbnail.
class PageSidebar extends ConsumerWidget {
  final String notebookId;
  final String selectedPageId;
  final ValueChanged<String> onPageSelected;

  const PageSidebar({
    super.key,
    required this.notebookId,
    required this.selectedPageId,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pageProvider(notebookId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: AppDimensions.pageSidebarWidth,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.sidebarBackground
            : AppColors.sidebarBackgroundLight,
        border: Border(
          right: BorderSide(
            color: isDark
                ? AppColors.toolbarDividerDark
                : AppColors.toolbarDivider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            child: Row(
              children: [
                Text(
                  'Pages',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.7)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ref.read(pageProvider(notebookId).notifier).addPage();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF252838)
                            : const Color(0xFFEEF0F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                            : AppColors.onSurfaceLight.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: isDark
                ? AppColors.toolbarDividerDark
                : AppColors.toolbarDivider,
          ),

          // Page list
          Expanded(
            child: pagesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.4),
                  ),
                ),
              ),
              data: (pages) {
                if (pages.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.noPages,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                            : AppColors.onSurfaceLight.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }
                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: pages.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    // Flutter's newIndex is the insertion position *before* the
                    // item at oldIndex is removed, so adjust when moving down.
                    if (newIndex > oldIndex) newIndex -= 1;
                    final pageId = pages[oldIndex].id;
                    // reorderPage expects a 1-based position.
                    ref
                        .read(pageProvider(notebookId).notifier)
                        .reorderPage(pageId, newIndex + 1);
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    final isSelected = page.id == selectedPageId;
                    return _PageThumbnail(
                      key: ValueKey(page.id),
                      page: page,
                      index: index,
                      isSelected: isSelected,
                      onTap: () => onPageSelected(page.id),
                      onDuplicate: () {
                        ref
                            .read(pageProvider(notebookId).notifier)
                            .duplicatePage(page.id);
                      },
                      onDelete: pages.length > 1
                          ? () {
                              ref
                                  .read(pageProvider(notebookId).notifier)
                                  .deletePage(page.id);
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PageThumbnail extends ConsumerWidget {
  final PageModel page;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const _PageThumbnail({
    super.key,
    required this.page,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasState = ref.watch(canvasProvider(page.id));

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.cardBorderDark
                    : AppColors.cardBorderLight),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Thumbnail area
            AspectRatio(
              aspectRatio:
                  AppDimensions.letterWidth / AppDimensions.letterHeight,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(9)),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: AppDimensions.letterWidth,
                    height: AppDimensions.letterHeight,
                    child: Stack(
                      children: [
                        Container(color: _hexToColor(page.backgroundColor)),
                        CustomPaint(
                          size: Size(AppDimensions.letterWidth,
                              AppDimensions.letterHeight),
                          painter: PageBackgroundPainter(
                            templateType: page.templateType,
                            lineSpacing: page.lineSpacing,
                          ),
                        ),
                        CustomPaint(
                          size: Size(AppDimensions.letterWidth,
                              AppDimensions.letterHeight),
                          painter: StrokePainter(
                            strokes: canvasState.strokes,
                            activeStroke: canvasState.activeStroke,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Page number row with drag handle
            SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${page.pageNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                              : AppColors.onSurfaceLight
                                  .withValues(alpha: 0.45)),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          size: 14,
                          color: isDark
                              ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                              : AppColors.onSurfaceLight.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length != 8) return Colors.white;
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  void _showContextMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.copy_rounded,
                color: isDark
                    ? AppColors.onSurfaceDark
                    : AppColors.onSurfaceLight,
              ),
              title: Text(
                'Duplicate Page',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : AppColors.onSurfaceLight,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDuplicate?.call();
              },
            ),
            if (onDelete != null)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                title: Text(
                  'Delete Page',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
          ],
        ),
      ),
    );
  }
}
