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
        color: isDark ? AppColors.sidebarBackground : Colors.grey.shade100,
        border: Border(
          right: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  AppStrings.notebooks,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.sidebarText : null,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    ref.read(pageProvider(notebookId).notifier).addPage();
                  },
                  tooltip: 'Add Page',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Page list.
          Expanded(
            child: pagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e'),
              ),
              data: (pages) {
                if (pages.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.noPages,
                      style: TextStyle(
                        color: isDark ? AppColors.sidebarText : Colors.grey,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    final isSelected = page.id == selectedPageId;
                    return _PageThumbnail(
                      page: page,
                      isSelected: isSelected,
                      onTap: () => onPageSelected(page.id),
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
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PageThumbnail({
    required this.page,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasState = ref.watch(canvasProvider(page.id));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete != null
          ? () => _showContextMenu(context)
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isDark ? Colors.grey.shade800 : Colors.white,
        ),
        child: Column(
          children: [
            // Thumbnail area — renders actual strokes scaled down.
            AspectRatio(
              aspectRatio: AppDimensions.letterWidth / AppDimensions.letterHeight,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(5)),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: AppDimensions.letterWidth,
                    height: AppDimensions.letterHeight,
                    child: Stack(
                      children: [
                        // Background color.
                        Container(color: _hexToColor(page.backgroundColor)),
                        // Template lines.
                        CustomPaint(
                          size: Size(
                              AppDimensions.letterWidth,
                              AppDimensions.letterHeight),
                          painter: PageBackgroundPainter(
                            templateType: page.templateType,
                            lineSpacing: page.lineSpacing,
                          ),
                        ),
                        // Strokes.
                        CustomPaint(
                          size: Size(
                              AppDimensions.letterWidth,
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
            // Page number.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${page.pageNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isDark ? AppColors.sidebarText : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Page'),
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
