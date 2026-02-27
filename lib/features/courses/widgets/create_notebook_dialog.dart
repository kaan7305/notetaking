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
    _TemplateOption('blank', 'Blank', Icons.crop_portrait_outlined),
    _TemplateOption('lined', 'Lined', Icons.format_align_left_outlined),
    _TemplateOption('grid', 'Grid', Icons.grid_on_outlined),
    _TemplateOption('dotted', 'Dotted', Icons.blur_on_outlined),
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
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool get _hasLines =>
      _selectedTemplate == 'lined' ||
      _selectedTemplate == 'grid' ||
      _selectedTemplate == 'dotted';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                AppStrings.newNotebook,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Title field.
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: AppStrings.notebookTitle,
                  hintText: 'e.g. Week 1 - Vectors',
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

              // Page size.
              _sectionLabel('Page Size'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _PageSizeOption(
                    label: 'Letter',
                    subtitle: '8.5 x 11 in',
                    isSelected: _selectedPageSize == 'letter',
                    onTap: () => setState(() => _selectedPageSize = 'letter'),
                  ),
                  const SizedBox(width: 12),
                  _PageSizeOption(
                    label: 'A4',
                    subtitle: '210 x 297 mm',
                    isSelected: _selectedPageSize == 'a4',
                    onTap: () => setState(() => _selectedPageSize = 'a4'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Template.
              _sectionLabel('Template'),
              const SizedBox(height: 10),
              Row(
                children: _templates.map((t) {
                  final selected = _selectedTemplate == t.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTemplate = t.value),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(t.icon,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.grey.shade500,
                                size: 22),
                            const SizedBox(height: 4),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? AppColors.primary
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Line spacing (only when a lined template is selected).
              if (_hasLines) ...[
                _sectionLabel('Line Spacing'),
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
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _lineSpacing == option.$2
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _lineSpacing == option.$2
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
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
                                    : FontWeight.normal,
                                color: _lineSpacing == option.$2
                                    ? AppColors.primary
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Background color.
              _sectionLabel('Background Color'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bgColors.map((opt) {
                  final hex = opt.hex;
                  final selected = _selectedBgColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBgColor = hex),
                    child: Tooltip(
                      message: opt.label,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _hexToColor(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  )
                                ]
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check,
                                size: 16, color: AppColors.primary)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Buttons.
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
                        : const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
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
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                color: isSelected ? AppColors.primary : Colors.grey.shade500,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
