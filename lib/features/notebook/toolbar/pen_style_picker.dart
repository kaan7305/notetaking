import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';

/// A bottom sheet that lets the user choose a pen rendering style.
class PenStylePicker extends StatelessWidget {
  final PenStyle currentStyle;
  final ValueChanged<PenStyle> onStyleSelected;

  const PenStylePicker({
    super.key,
    required this.currentStyle,
    required this.onStyleSelected,
  });

  static const _icons = <PenStyle, IconData>{
    PenStyle.standard: Icons.edit_rounded,
    PenStyle.calligraphy: Icons.brush_rounded,
    PenStyle.fountain: Icons.create_rounded,
    PenStyle.marker: Icons.format_paint_rounded,
    PenStyle.fineLiner: Icons.drive_file_rename_outline_rounded,
    PenStyle.pencil: Icons.mode_edit_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pen Style',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a style for your pen strokes',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.onSurfaceDark.withValues(alpha: 0.4)
                  : AppColors.onSurfaceLight.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: PenStyle.values.map((style) {
              final config = PenStyleConfig.forStyle(style);
              final isSelected = style == currentStyle;
              return GestureDetector(
                onTap: () => onStyleSelected(style),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 90,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.toolbarActiveDark
                            : AppColors.primary.withValues(alpha: 0.08))
                        : (isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight),
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
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? const Color(0xFF2A2D3E)
                                  : const Color(0xFFF0F2F8)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _icons[style] ?? Icons.edit_rounded,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.onSurfaceDark
                                      .withValues(alpha: 0.5)
                                  : AppColors.onSurfaceLight
                                      .withValues(alpha: 0.5)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        config.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.onSurfaceDark
                                      .withValues(alpha: 0.7)
                                  : AppColors.onSurfaceLight
                                      .withValues(alpha: 0.6)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
