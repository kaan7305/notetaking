import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A horizontal row of color swatches for selecting pen/highlighter color.
class ColorPickerRow extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppDimensions.colorRowHeight,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.toolbarBackgroundDark
            : AppColors.toolbarBackgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AppColors.penColors.map((color) {
          final isSelected = color == selectedColor;
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (color == AppColors.penWhite
                          ? Colors.grey.shade400
                          : Colors.transparent),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
