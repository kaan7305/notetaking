import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/app/route_names.dart';
import 'package:study_notebook/core/providers/course_provider.dart';
import 'package:study_notebook/core/providers/notebook_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/courses/widgets/create_notebook_dialog.dart';
import 'package:study_notebook/features/courses/widgets/notebook_card.dart';
import 'package:study_notebook/features/documents/document_list.dart';

/// Screen for viewing a single course's content.
///
/// Displays two tabs: "Notebooks" (with real provider data) and "Documents"
/// (a placeholder). A floating action button allows creating new notebooks.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateNotebookDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => CreateNotebookDialog(courseId: widget.courseId),
    );
  }

  String _resolveCourseName() {
    final coursesAsync = ref.watch(courseProvider);
    return coursesAsync.whenOrNull(
          data: (courses) {
            final match = courses.where((c) => c.id == widget.courseId).firstOrNull;
            return match?.name;
          },
        ) ??
        AppStrings.courses;
  }

  @override
  Widget build(BuildContext context) {
    final courseName = _resolveCourseName();
    final notebooksAsync = ref.watch(notebookProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_outlined),
            tooltip: 'Lecture Capture',
            onPressed: () => context.pushNamed(
              RouteNames.lectureCapture,
              pathParameters: {'courseId': widget.courseId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Review & Quiz',
            onPressed: () => context.pushNamed(
              RouteNames.review,
              pathParameters: {'courseId': widget.courseId},
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: AppStrings.notebooks),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Notebooks tab ─────────────────────────────────
          _buildNotebooksTab(notebooksAsync),

          // ── Documents tab ───────────────────────────────
          DocumentList(courseId: widget.courseId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateNotebookDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notebooks tab
  // ---------------------------------------------------------------------------

  Widget _buildNotebooksTab(AsyncValue<List<dynamic>> notebooksAsync) {
    return notebooksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              AppStrings.loadError,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.read(notebookProvider(widget.courseId).notifier).loadNotebooks(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (notebooks) {
        if (notebooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 64, color: Colors.grey.shade300),
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

        return LayoutBuilder(
          builder: (context, constraints) {
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
      },
    );
  }

}
