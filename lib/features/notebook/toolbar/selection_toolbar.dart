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
          ChoiceChip(
            label: const Text('Lasso', style: TextStyle(fontSize: 12)),
            selected: canvasState.selectionMode == SelectionMode.freeform,
            onSelected: (_) => ref
                .read(canvasProvider(pageId).notifier)
                .setSelectionMode(SelectionMode.freeform),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Box', style: TextStyle(fontSize: 12)),
            selected: canvasState.selectionMode == SelectionMode.box,
            onSelected: (_) => ref
                .read(canvasProvider(pageId).notifier)
                .setSelectionMode(SelectionMode.box),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          if (canvasState.hasSelection) ...[
            Text(
              '${canvasState.selectedStrokeIds.length} selected',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => ref
                  .read(canvasProvider(pageId).notifier)
                  .deleteSelectedStrokes(),
              tooltip: 'Delete selected',
            ),
          ],
        ],
      ),
    );
  }
}
