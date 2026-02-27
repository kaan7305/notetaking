import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/app/route_names.dart';
import 'package:study_notebook/core/models/course.dart';
import 'package:study_notebook/core/providers/search_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/courses/widgets/course_card.dart';

/// Left sidebar for the Library screen, modelled after Notability's home panel.
///
/// Shows a search field, the "Notes" and "Gallery" quick-access rows, a
/// "Subjects" section header with an add button, and the list of courses.
///
/// Now accepts an [AsyncValue] for courses so it can display loading / error
/// states while the real data is fetched.
class LibrarySidebar extends ConsumerWidget {
  const LibrarySidebar({
    super.key,
    required this.coursesAsync,
    required this.selectedCourseId,
    required this.allNotesCount,
    required this.onCourseSelected,
    required this.onAllNotesSelected,
    required this.onAddCourse,
  });

  /// Async course list from the provider.
  final AsyncValue<List<Course>> coursesAsync;

  /// Currently selected course id, or `null` when "All Notes" is active.
  final String? selectedCourseId;

  /// Total number of notebooks across every course.
  final int allNotesCount;

  /// Called when the user taps a specific course.
  final ValueChanged<String?> onCourseSelected;

  /// Called when the user taps "Notes" (show all notebooks).
  final VoidCallback onAllNotesSelected;

  /// Called when the user taps the "+" button next to the Subjects header.
  final VoidCallback onAddCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.sidebarBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Settings icon ------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: GestureDetector(
                onTap: () => context.pushNamed(RouteNames.settings),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppColors.sidebarText.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
            ),

            // -- Search field -------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
                style: const TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: AppColors.sidebarText.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.sidebarText.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // -- Notes row ----------------------------------------------------
            _SidebarItem(
              icon: Icons.note_outlined,
              label: 'Notes',
              trailing: Text(
                '$allNotesCount',
                style: TextStyle(
                  color: AppColors.sidebarText.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              isActive: selectedCourseId == null,
              onTap: onAllNotesSelected,
            ),

            // -- Gallery row --------------------------------------------------
            _SidebarItem(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              isActive: false,
              onTap: () {
                // Placeholder -- gallery not yet implemented.
              },
            ),

            const SizedBox(height: 8),

            // -- Divider ------------------------------------------------------
            Divider(
              color: AppColors.sidebarText.withValues(alpha: 0.15),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),

            const SizedBox(height: 8),

            // -- Subjects header ----------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Subjects',
                    style: TextStyle(
                      color: AppColors.sidebarText.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onAddCourse,
                    child: Icon(
                      Icons.add,
                      color: AppColors.sidebarText.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // -- Course list --------------------------------------------------
            Expanded(
              child: _buildCourseList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Course list builder
  // ---------------------------------------------------------------------------

  Widget _buildCourseList() {
    return coursesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppStrings.loadError,
            style: TextStyle(
              color: AppColors.sidebarText.withValues(alpha: 0.6),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (courses) {
        if (courses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: AppColors.sidebarText.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create your first course',
                    style: TextStyle(
                      color: AppColors.sidebarText.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onAddCourse,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(AppStrings.newCourse),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return CourseCard(
              course: course,
              isActive: course.id == selectedCourseId,
              onSelected: () => onCourseSelected(course.id),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper: a single tappable row in the sidebar.
// ---------------------------------------------------------------------------

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.sidebarItemActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.sidebarText.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.sidebarText,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
