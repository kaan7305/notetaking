import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/page_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

import 'package:study_notebook/features/ai_assistant/chat/ai_chat_panel.dart';

import 'canvas/canvas_notifier.dart';
import 'canvas/drawing_canvas.dart';
import 'pages/page_sidebar.dart';
import 'toolbar/notebook_toolbar.dart';

/// The main notebook editing screen with canvas, toolbar, and page sidebar.
class NotebookScreen extends ConsumerStatefulWidget {
  final String notebookId;
  final String courseId;

  const NotebookScreen({
    super.key,
    required this.notebookId,
    required this.courseId,
  });

  @override
  ConsumerState<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends ConsumerState<NotebookScreen> {
  bool _showPageSidebar = true;
  bool _showAiPanel = false;
  String? _selectedPageId;

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(pageProvider(widget.notebookId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.canvasBackgroundDark : Colors.grey.shade200,
      body: SafeArea(
        child: pagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (pages) {
            if (pages.isEmpty) {
              return const Center(child: Text(AppStrings.noPages));
            }

            // Default to first page if no selection.
            final selectedId = _selectedPageId ?? pages.first.id;
            final currentPage =
                pages.firstWhere((p) => p.id == selectedId, orElse: () => pages.first);

            return Column(
              children: [
                // Toolbar.
                NotebookToolbar(
                  pageId: currentPage.id,
                  onTogglePageSidebar: () {
                    setState(() => _showPageSidebar = !_showPageSidebar);
                  },
                  onToggleAiPanel: () {
                    setState(() => _showAiPanel = !_showAiPanel);
                  },
                  isAiPanelOpen: _showAiPanel,
                ),

                // Canvas + optional page sidebar.
                Expanded(
                  child: Row(
                    children: [
                      // Page sidebar.
                      if (_showPageSidebar)
                        PageSidebar(
                          notebookId: widget.notebookId,
                          selectedPageId: currentPage.id,
                          onPageSelected: (pageId) {
                            _saveCurrent(currentPage.id);
                            setState(() => _selectedPageId = pageId);
                          },
                        ),

                      // Canvas area.
                      Expanded(
                        child: _CanvasArea(
                          key: ValueKey(currentPage.id),
                          page: currentPage,
                        ),
                      ),

                      // AI chat panel.
                      if (_showAiPanel)
                        AiChatPanel(courseId: widget.courseId),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _saveCurrent(String pageId) {
    ref.read(canvasProvider(pageId).notifier).forceSave();
  }

  @override
  void deactivate() {
    // Force save when leaving screen.
    if (_selectedPageId != null) {
      _saveCurrent(_selectedPageId!);
    }
    super.deactivate();
  }
}

/// The scrollable canvas area that renders the page at its natural size.
class _CanvasArea extends ConsumerStatefulWidget {
  final PageModel page;

  const _CanvasArea({super.key, required this.page});

  @override
  ConsumerState<_CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<_CanvasArea> {
  final _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use letter size by default; could be made configurable per notebook.
    const pageSize = Size(
      AppDimensions.letterWidth,
      AppDimensions.letterHeight,
    );

    return InteractiveViewer(
      transformationController: _transformController,
      minScale: AppDimensions.canvasMinZoom,
      maxScale: AppDimensions.canvasMaxZoom,
      boundaryMargin: const EdgeInsets.all(100),
      child: Center(
        child: Container(
          width: pageSize.width,
          height: pageSize.height,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.canvasBackgroundDark
                : AppColors.canvasBackground,
            boxShadow: [
              BoxShadow(
                color: AppColors.pageShadow,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DrawingCanvas(
            pageId: widget.page.id,
            templateType: widget.page.templateType,
            pageSize: pageSize,
          ),
        ),
      ),
    );
  }
}
