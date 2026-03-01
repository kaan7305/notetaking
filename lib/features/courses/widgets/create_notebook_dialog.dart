import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/notebook_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A dialog for creating a new notebook inside a specific course.
class CreateNotebookDialog extends ConsumerStatefulWidget {
  const CreateNotebookDialog({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CreateNotebookDialog> createState() =>
      _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends ConsumerState<CreateNotebookDialog> {
  late final TextEditingController _titleController;
  String _selectedPageSize = 'letter';
  String _selectedTemplate = 'blank';
  String _selectedBgColor = '#FFFFFF';
  double _lineSpacing = 32.0;
  bool _isSubmitting = false;
  String? _titleError;

  static const _bgColors = [
    _BgOption('#FFFFFF', 'White'),
    _BgOption('#FFFDE7', 'Cream'),
    _BgOption('#E3F2FD', 'Light Blue'),
    _BgOption('#F1F8E9', 'Light Green'),
    _BgOption('#FFF8E1', 'Yellow'),
    _BgOption('#FCE4EC', 'Pink'),
    _BgOption('#F3E5F5', 'Lavender'),
    _BgOption('#E0F2F1', 'Mint'),
  ];

  static const _templates = [
    _TemplateOption('blank', 'Blank', Icons.crop_portrait_rounded),
    _TemplateOption('lined', 'Lined', Icons.format_align_left_rounded),
    _TemplateOption('grid', 'Grid', Icons.grid_on_rounded),
    _TemplateOption('dotted', 'Dotted', Icons.blur_on_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter a notebook title');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _titleError = null;
    });

    try {
      final notifier = ref.read(notebookProvider(widget.courseId).notifier);
      final result = await notifier.createNotebook(
        title,
        pageSize: _selectedPageSize,
        templateType: _selectedTemplate,
        backgroundColor: _selectedBgColor,
        lineSpacing: _lineSpacing,
      );

      if (!mounted) return;

      switch (result) {
        case Success():
          ref.invalidate(allNotebooksProvider);
          Navigator.of(context).pop(true);
        case Failure(message: final msg):
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create notebook: $msg')),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }

  bool get _hasLines =>
      _selectedTemplate == 'lined' ||
      _selectedTemplate == 'grid' ||
      _selectedTemplate == 'dotted';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                AppStrings.newNotebook,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : AppColors.onSurfaceLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Set up your notebook preferences',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                      : AppColors.onSurfaceLight.withValues(alpha: 0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Title field
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.onSurfaceDark
                      : AppColors.onSurfaceLight,
                ),
                decoration: InputDecoration(
                  labelText: AppStrings.notebookTitle,
                  hintText: 'e.g. Week 1 - Vectors',
                  errorText: _titleError,
                ),
                onChanged: (_) {
                  if (_titleError != null) {
                    setState(() => _titleError = null);
                  }
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),

              // Page size
              _sectionLabel('Page Size', isDark),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PageSizeOption(
                    label: 'Letter',
                    subtitle: '8.5 x 11 in',
                    isSelected: _selectedPageSize == 'letter',
                    onTap: () => setState(() => _selectedPageSize = 'letter'),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _PageSizeOption(
                    label: 'A4',
                    subtitle: '210 x 297 mm',
                    isSelected: _selectedPageSize == 'a4',
                    onTap: () => setState(() => _selectedPageSize = 'a4'),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Template
              _sectionLabel('Template', isDark),
              const SizedBox(height: 10),
              Row(
                children: _templates.map((t) {
                  final selected = _selectedTemplate == t.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTemplate = t.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark
                                  ? AppColors.toolbarActiveDark
                                  : AppColors.primary.withValues(alpha: 0.08))
                              : (isDark
                                  ? const Color(0xFF252838)
                                  : const Color(0xFFF4F5FA)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.cardBorderDark
                                    : AppColors.cardBorderLight),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              t.icon,
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.onSurfaceDark
                                          .withValues(alpha: 0.4)
                                      : AppColors.onSurfaceLight
                                          .withValues(alpha: 0.4)),
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: selected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.onSurfaceDark
                                            .withValues(alpha: 0.6)
                                        : AppColors.onSurfaceLight
                                            .withValues(alpha: 0.6)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Line spacing
              if (_hasLines) ...[
                _sectionLabel('Line Spacing', isDark),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final option in [
                      ('Narrow', 24.0),
                      ('Medium', 32.0),
                      ('Wide', 48.0),
                    ])
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _lineSpacing = option.$2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _lineSpacing == option.$2
                                  ? (isDark
                                      ? AppColors.toolbarActiveDark
                                      : AppColors.primary
                                          .withValues(alpha: 0.08))
                                  : (isDark
                                      ? const Color(0xFF252838)
                                      : const Color(0xFFF4F5FA)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _lineSpacing == option.$2
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.cardBorderDark
                                        : AppColors.cardBorderLight),
                                width: _lineSpacing == option.$2 ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              option.$1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _lineSpacing == option.$2
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _lineSpacing == option.$2
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.onSurfaceDark
                                            .withValues(alpha: 0.6)
                                        : AppColors.onSurfaceLight
                                            .withValues(alpha: 0.6)),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Background color
              _sectionLabel('Background Color', isDark),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bgColors.map((opt) {
                  final hex = opt.hex;
                  final selected = _selectedBgColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBgColor = hex),
                    child: Tooltip(
                      message: opt.label,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _hexToColor(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.cardBorderDark
                                    : Colors.grey.shade300),
                            width: selected ? 2.5 : 1.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    spreadRadius: -1,
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: selected
                            ? Icon(Icons.check_rounded,
                                size: 16, color: AppColors.primary)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.cardBorderDark
                                : AppColors.cardBorderLight,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                              : AppColors.onSurfaceLight.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Notebook'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.onSurfaceDark.withValues(alpha: 0.5)
              : AppColors.onSurfaceLight.withValues(alpha: 0.45),
        ),
      );

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class _BgOption {
  final String hex;
  final String label;
  const _BgOption(this.hex, this.label);
}

class _TemplateOption {
  final String value;
  final String label;
  final IconData icon;
  const _TemplateOption(this.value, this.label, this.icon);
}

/// A tappable page-size option card.
class _PageSizeOption extends StatelessWidget {
  const _PageSizeOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.toolbarActiveDark
                    : AppColors.primary.withValues(alpha: 0.08))
                : (isDark
                    ? const Color(0xFF252838)
                    : const Color(0xFFF4F5FA)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorderLight),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                        : AppColors.onSurfaceLight.withValues(alpha: 0.4)),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : (isDark
                          ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                          : AppColors.onSurfaceLight.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
