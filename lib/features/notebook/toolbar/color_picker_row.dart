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
      height: AppDimensions.colorRowHeight + 4,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.toolbarBackgroundDark
            : AppColors.toolbarBackgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.toolbarDividerDark
                : AppColors.toolbarDivider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AppColors.penColors.map((color) {
          final isSelected = color == selectedColor;
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 30 : 26,
              height: isSelected ? 30 : 26,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (color == AppColors.penWhite
                          ? (isDark
                              ? AppColors.cardBorderDark
                              : Colors.grey.shade300)
                          : Colors.transparent),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: -1,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
