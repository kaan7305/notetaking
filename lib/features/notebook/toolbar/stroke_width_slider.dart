import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A slider for adjusting pen or highlighter stroke width.
class StrokeWidthSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const StrokeWidthSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1.0,
    this.max = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedValue = value.clamp(min, max);

    return Container(
      height: AppDimensions.colorRowHeight + 4,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        children: [
          // Thin dot indicator
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                  : AppColors.onSurfaceLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.12)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.1),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 18),
              ),
              child: Slider(
                value: clampedValue,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Thick dot indicator
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.onSurfaceDark.withValues(alpha: 0.3)
                  : AppColors.onSurfaceLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          // Current value label
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF252838)
                  : const Color(0xFFEEF0F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              clampedValue.toStringAsFixed(clampedValue < 10 ? 1 : 0),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.onSurfaceDark.withValues(alpha: 0.6)
                    : AppColors.onSurfaceLight.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
