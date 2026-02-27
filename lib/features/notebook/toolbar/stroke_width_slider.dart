import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A slider for adjusting pen or highlighter stroke width.
class StrokeWidthSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const StrokeWidthSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppDimensions.colorRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.toolbarBackgroundDark
            : AppColors.toolbarBackgroundLight,
        border: Border(
          bottom: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Thin line indicator.
          Container(
            width: 16,
            height: 1,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 1.0,
              max: 30.0,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ),
          // Thick line indicator.
          Container(
            width: 16,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.white54 : Colors.black54,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
