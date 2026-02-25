import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/course.dart';
import 'package:study_notebook/core/providers/course_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';
import 'package:study_notebook/features/courses/widgets/create_course_dialog.dart';

/// A sidebar list-item representing a single [Course].
///
/// Displays a coloured circle indicator, the course name, and an active
/// highlight when selected. A long-press reveals edit / delete actions.
class CourseCard extends ConsumerWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.isActive,
    required this.onSelected,
  });

  final Course course;
  final bool isActive;
  final VoidCallback onSelected;

  Color _courseColor() {
    if (course.color == null || course.color!.isEmpty) {
      return AppColors.primary;
    }
    try {
      final hex = course.color!.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + box.size.width,
        offset.dy,
        offset.dx + box.size.width + 10,
        offset.dy + box.size.height,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'edit') {
        _editCourse(context);
      } else if (value == 'delete') {
        _confirmDelete(context, ref);
      }
    });
  }

  void _editCourse(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => CreateCourseDialog(course: course),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteCourse),
        content: Text(
          'Are you sure you want to delete "${course.name}"? '
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
        ref.read(courseProvider.notifier).deleteCourse(course.id);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onSelected,
      onLongPress: () => _showContextMenu(context, ref),
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
            // Color indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _courseColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            // Course name
            Expanded(
              child: Text(
                course.name,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.sidebarText,
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right,
              color: isActive
                  ? AppColors.primary
                  : AppColors.sidebarText.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
