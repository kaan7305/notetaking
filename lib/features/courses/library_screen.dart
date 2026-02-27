import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/models/notebook.dart';
import 'package:study_notebook/core/providers/course_provider.dart';
import 'package:study_notebook/core/providers/notebook_provider.dart';
import 'package:study_notebook/core/providers/search_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/courses/widgets/create_course_dialog.dart';
import 'package:study_notebook/features/courses/widgets/create_notebook_dialog.dart';
import 'package:study_notebook/features/courses/widgets/library_content.dart';
import 'package:study_notebook/features/courses/widgets/library_sidebar.dart';

/// The main Library screen.
///
/// Uses a horizontal [Row] layout with a fixed-width dark sidebar on the left
/// and an [Expanded] content area on the right. All data is wired to real
/// Riverpod providers.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  /// The currently selected course id, or `null` for "All Notes".
  String? _selectedCourseId;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get _contentTitle {
    if (_selectedCourseId == null) {
      return 'All Notes';
    }
    final coursesAsync = ref.read(courseProvider);
    return coursesAsync.whenOrNull(
          data: (courses) {
            final match =
                courses.where((c) => c.id == _selectedCourseId).firstOrNull;
            return match?.name;
          },
        ) ??
        'All Notes';
  }

  void _openCreateCourseDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => const CreateCourseDialog(),
    );
  }

  void _openCreateNotebookDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) =>
          CreateNotebookDialog(courseId: _selectedCourseId ?? ''),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final coursesAsync = query.isEmpty
        ? ref.watch(courseProvider)
        : ref.watch(filteredCoursesProvider);

    // Determine which notebooks to show based on selection.
    final List<Notebook> visibleNotebooks;
    final bool isLoadingNotebooks;
    final String? notebookError;

    if (_selectedCourseId == null) {
      // All Notes view — apply search filter when query is active.
      final allAsync = query.isEmpty
          ? ref.watch(allNotebooksProvider)
          : ref.watch(filteredNotebooksProvider);
      visibleNotebooks = allAsync.valueOrNull ?? [];
      isLoadingNotebooks = allAsync.isLoading;
      notebookError = allAsync.hasError ? allAsync.error.toString() : null;
    } else {
      // Per-course view
      final courseAsync = ref.watch(notebookProvider(_selectedCourseId!));
      final notebooks = courseAsync.valueOrNull ?? [];
      // Apply local search filter within selected course.
      visibleNotebooks = query.isEmpty
          ? notebooks
          : notebooks
              .where(
                  (n) => n.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
      isLoadingNotebooks = courseAsync.isLoading;
      notebookError = courseAsync.hasError ? courseAsync.error.toString() : null;
    }

    final allNotesCount =
        ref.watch(allNotebooksProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      body: Row(
        children: [
          // -- Sidebar -------------------------------------------------------
          SizedBox(
            width: AppDimensions.sidebarWidth,
            child: LibrarySidebar(
              coursesAsync: coursesAsync,
              selectedCourseId: _selectedCourseId,
              allNotesCount: allNotesCount,
              onCourseSelected: (courseId) {
                setState(() => _selectedCourseId = courseId);
              },
              onAllNotesSelected: () {
                setState(() => _selectedCourseId = null);
              },
              onAddCourse: _openCreateCourseDialog,
            ),
          ),

          // -- Content area --------------------------------------------------
          Expanded(
            child: LibraryContent(
              title: _contentTitle,
              notebooks: visibleNotebooks,
              isLoading: isLoadingNotebooks,
              errorMessage: notebookError,
              onNewNotebook: _openCreateNotebookDialog,
              onRetry: () {
                if (_selectedCourseId == null) {
                  ref.read(allNotebooksProvider.notifier).loadNotebooks();
                } else {
                  ref
                      .read(notebookProvider(_selectedCourseId!).notifier)
                      .loadNotebooks();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
