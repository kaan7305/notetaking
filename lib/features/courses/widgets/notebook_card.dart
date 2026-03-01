import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/app/route_names.dart';
import 'package:study_notebook/core/models/notebook.dart';
import 'package:study_notebook/core/providers/notebook_provider.dart';
import 'package:study_notebook/core/providers/page_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/notebook/canvas/canvas_notifier.dart';
import 'package:study_notebook/features/notebook/canvas/page_background_painter.dart';
import 'package:study_notebook/features/notebook/canvas/stroke_painter.dart';

/// Renders the first-page preview for a notebook card.
class _NotebookThumbnail extends ConsumerWidget {
  final String notebookId;
  final bool isFavorite;

  const _NotebookThumbnail({
    required this.notebookId,
    required this.isFavorite,
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pageProvider(notebookId));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return pagesAsync.when(
      loading: () => Container(
        color: isDark ? AppColors.cardDark : const Color(0xFFF4F5FA),
      ),
      error: (_, __) => Container(
        color: isDark ? AppColors.cardDark : const Color(0xFFF4F5FA),
      ),
      data: (pages) {
        if (pages.isEmpty) {
          return Container(
            color: isDark ? AppColors.cardDark : const Color(0xFFF4F5FA),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: 40,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.15)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.15),
              ),
            ),
          );
        }

        final firstPage = pages.first;
        final canvasState = ref.watch(canvasProvider(firstPage.id));

        return Stack(
          fit: StackFit.expand,
          children: [
            // Page background color.
            Container(color: _hexToColor(firstPage.backgroundColor)),
            // Template lines.
            CustomPaint(
              painter: PageBackgroundPainter(
                templateType: firstPage.templateType,
                lineSpacing: firstPage.lineSpacing,
              ),
            ),
            // Strokes (scaled down to fit the card).
            FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: AppDimensions.letterWidth,
                height: AppDimensions.letterHeight,
                child: CustomPaint(
                  painter: StrokePainter(strokes: canvasState.strokes),
                ),
              ),
            ),
            // Favourite star overlay.
            if (isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade600,
                  size: 22,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A grid card representing a single [Notebook].
///
/// Shows a thumbnail preview, the notebook title, and the last-modified
/// date. A star icon overlay appears when the notebook is favourited.
/// Long-press reveals rename / favourite / delete options.
class NotebookCard extends ConsumerWidget {
  const NotebookCard({super.key, required this.notebook});

  final Notebook notebook;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openNotebook(BuildContext context) {
    context.goNamed(
      RouteNames.notebook,
      pathParameters: {
        'courseId': notebook.courseId.isEmpty ? '_unfiled' : notebook.courseId,
        'notebookId': notebook.id,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Context menu actions
  // ---------------------------------------------------------------------------

  void _showContextMenu(BuildContext context, WidgetRef ref, Offset position) {
    final isFav = notebook.isFavorite;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        const PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(
          value: 'favorite',
          child: Text(isFav ? 'Unfavorite' : 'Favorite'),
        ),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (!context.mounted) return;
      switch (value) {
        case 'rename':
          _showRenameDialog(context, ref);
        case 'favorite':
          _toggleFavorite(ref);
        case 'delete':
          _confirmDelete(context, ref);
        default:
          break;
      }
    });
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: notebook.title);
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Notebook'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppStrings.notebookTitle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onSubmitted: (value) => Navigator.of(ctx).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((newTitle) {
      if (newTitle != null && newTitle.trim().isNotEmpty) {
        final updated = notebook.copyWith(title: newTitle.trim());
        ref.read(notebookProvider(notebook.courseId).notifier).updateNotebook(updated);
        ref.invalidate(allNotebooksProvider);
      }
    });
  }

  void _toggleFavorite(WidgetRef ref) {
    ref.read(notebookProvider(notebook.courseId).notifier).toggleFavorite(notebook.id);
    ref.invalidate(allNotebooksProvider);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteNotebook),
        content: Text(
          'Are you sure you want to delete "${notebook.title}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(notebookProvider(notebook.courseId).notifier).deleteNotebook(notebook.id);
        ref.invalidate(allNotebooksProvider);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat.yMMMd();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openNotebook(context),
      onLongPressStart: (details) =>
          _showContextMenu(context, ref, details.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.cardBorderDark
                : AppColors.cardBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area
            Expanded(
              child: _NotebookThumbnail(
                notebookId: notebook.id,
                isFavorite: notebook.isFavorite,
              ),
            ),

            // Info strip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notebook.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateFormat.format(notebook.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.onSurfaceDark.withValues(alpha: 0.35)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.35),
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
}
