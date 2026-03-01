import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/course.dart';
import 'package:study_notebook/core/providers/course_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A dialog for creating or editing a [Course].
///
/// Pass an existing [course] to enter edit mode; otherwise the dialog
/// defaults to create mode.
class CreateCourseDialog extends ConsumerStatefulWidget {
  const CreateCourseDialog({super.key, this.course});

  /// If non-null the dialog operates in edit mode.
  final Course? course;

  @override
  ConsumerState<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends ConsumerState<CreateCourseDialog> {
  late final TextEditingController _nameController;
  String? _selectedColor;
  bool _isSubmitting = false;

  bool get _isEditing => widget.course != null;

  /// Predefined course colors.
  static const List<Color> _courseColors = [
    Color(0xFFFF3B30), // red
    Color(0xFFFF9500), // orange
    Color(0xFFFFCC00), // yellow
    Color(0xFF34C759), // green
    Color(0xFF5AC8FA), // cyan
    Color(0xFF007AFF), // blue
    Color(0xFF5856D6), // indigo
    Color(0xFFAF52DE), // purple
    Color(0xFFFF2D55), // magenta
    Color(0xFF8E8E93), // grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _selectedColor = widget.course?.color ?? _colorToHex(_courseColors.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (name.length > AppDimensions.maxNameLength) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(courseProvider.notifier);

    if (_isEditing) {
      final updated = widget.course!.copyWith(
        name: name,
        color: _selectedColor,
      );
      await notifier.updateCourse(updated);
    } else {
      await notifier.createCourse(name, _selectedColor);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                _isEditing ? AppStrings.editCourse : AppStrings.newCourse,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Name field
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                maxLength: AppDimensions.maxNameLength,
                decoration: InputDecoration(
                  labelText: AppStrings.courseName,
                  hintText: 'e.g. Calculus 3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),

              // Color picker label
              const Text(
                'Course Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),

              // Color grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _courseColors.map((color) {
                  final hex = _colorToHex(color);
                  final isSelected = hex == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black87, width: 2.5)
                            : Border.all(
                                color: Colors.black12,
                                width: 1,
                              ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
