import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/notebook.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/courses/widgets/library_tabs.dart';
import 'package:study_notebook/features/courses/widgets/notebook_card.dart';

/// Main content area of the Library screen (right of the sidebar).
///
/// Displays a header with the current section name and a "+ New" button,
/// a [LibraryTabs] strip, and a responsive grid of notebook cards.
///
/// Now accepts [isLoading] and [errorMessage] so it can display loading /
/// error states while notebook data is being fetched.
class LibraryContent extends ConsumerStatefulWidget {
  const LibraryContent({
    super.key,
    required this.title,
    required this.notebooks,
    required this.onNewNotebook,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  /// Section title shown in the header (e.g. "All Notes", course name).
  final String title;

  /// Notebooks to display in the grid.
  final List<Notebook> notebooks;

  /// Called when the user taps the "+ New" button.
  final VoidCallback onNewNotebook;

  /// Whether the notebook data is still loading.
  final bool isLoading;

  /// An error message to display, if any.
  final String? errorMessage;

  /// Called when the user taps "Retry" on the error state.
  final VoidCallback? onRetry;

  @override
  ConsumerState<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends ConsumerState<LibraryContent> {
  LibraryTab _activeTab = LibraryTab.allNotes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // -- Header -----------------------------------------------------------
        _buildHeader(context),

        // -- Tabs -------------------------------------------------------------
        LibraryTabs(
          activeTab: _activeTab,
          onTabChanged: (tab) => setState(() => _activeTab = tab),
        ),

        // -- Content body -----------------------------------------------------
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body: loading / error / empty / grid
  // ---------------------------------------------------------------------------

  Widget _buildBody() {
    // Loading
    if (widget.isLoading && widget.notebooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (widget.errorMessage != null && widget.notebooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              AppStrings.loadError,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: widget.onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    // Filter then show grid or empty
    final filtered = _filteredNotebooks();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return _buildGrid(context, filtered);
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          // Overflow / more menu
          Icon(
            Icons.more_horiz,
            color: Colors.grey.shade500,
            size: 24,
          ),
          const Spacer(),

          // Section title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // "+ New" button
          TextButton.icon(
            onPressed: widget.onNewNotebook,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noNotebooks,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------
  Widget _buildGrid(BuildContext context, List<Notebook> notebooks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count: 2 for narrow, 3 for medium, 4 for wide.
        final crossAxisCount = constraints.maxWidth < 500
            ? 2
            : constraints.maxWidth < 800
                ? 3
                : 4;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: notebooks.length,
          itemBuilder: (context, index) {
            return NotebookCard(notebook: notebooks[index]);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tab filtering
  // ---------------------------------------------------------------------------
  List<Notebook> _filteredNotebooks() {
    switch (_activeTab) {
      case LibraryTab.allNotes:
        return widget.notebooks;
      case LibraryTab.recents:
        // Sort by updatedAt descending.
        final sorted = List<Notebook>.from(widget.notebooks)
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted;
      case LibraryTab.favorites:
        return widget.notebooks.where((n) => n.isFavorite).toList();
      case LibraryTab.unfiled:
        // Notebooks without a meaningful courseId (empty string) are "unfiled".
        return widget.notebooks
            .where((n) => n.courseId.isEmpty)
            .toList();
    }
  }
}
