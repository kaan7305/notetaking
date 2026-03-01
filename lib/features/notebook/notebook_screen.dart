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
          isDark ? AppColors.canvasAreaDark : AppColors.canvasAreaLight,
      body: SafeArea(
        child: pagesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48,
                    color: isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  '$e',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          data: (pages) {
            if (pages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.note_alt_outlined,
                        size: 56,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.2)
                            : AppColors.onSurfaceLight.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.noPages,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                            : AppColors.onSurfaceLight.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              );
            }

            final selectedId = _selectedPageId ?? pages.first.id;
            final currentPage = pages.firstWhere(
                (p) => p.id == selectedId,
                orElse: () => pages.first);

            return Column(
              children: [
                // Toolbar
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

                // Canvas + optional page sidebar
                Expanded(
                  child: Row(
                    children: [
                      // Page sidebar with animated width
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: _showPageSidebar
                            ? AppDimensions.pageSidebarWidth
                            : 0,
                        child: _showPageSidebar
                            ? PageSidebar(
                                notebookId: widget.notebookId,
                                selectedPageId: currentPage.id,
                                onPageSelected: (pageId) {
                                  _saveCurrent(currentPage.id);
                                  setState(
                                      () => _selectedPageId = pageId);
                                },
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Canvas area
                      Expanded(
                        child: _CanvasArea(
                          key: ValueKey(currentPage.id),
                          page: currentPage,
                        ),
                      ),

                      // AI chat panel
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

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasState = ref.watch(canvasProvider(widget.page.id));
    final isDrawingTool = canvasState.currentTool == ToolType.pen ||
        canvasState.currentTool == ToolType.highlighter ||
        canvasState.currentTool == ToolType.eraser ||
        canvasState.currentTool == ToolType.lasso;

    const pageSize = Size(
      AppDimensions.letterWidth,
      AppDimensions.letterHeight,
    );

    return InteractiveViewer(
      transformationController: _transformController,
      minScale: AppDimensions.canvasMinZoom,
      maxScale: AppDimensions.canvasMaxZoom,
      boundaryMargin: const EdgeInsets.all(120),
      panEnabled: !isDrawingTool,
      scaleEnabled: !isDrawingTool,
      child: Center(
        child: Container(
          width: pageSize.width,
          height: pageSize.height,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.canvasBackgroundDark
                : _hexToColor(widget.page.backgroundColor),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: DrawingCanvas(
              pageId: widget.page.id,
              templateType: widget.page.templateType,
              pageSize: pageSize,
              backgroundColor: _hexToColor(widget.page.backgroundColor),
              lineSpacing: widget.page.lineSpacing,
            ),
          ),
        ),
      ),
    );
  }
}
