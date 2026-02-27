import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/ai_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

/// A segmented button for selecting AI mode (Hint / Check / Solve).
class AiModeSelector extends ConsumerWidget {
  final String courseId;

  const AiModeSelector({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(aiChatProvider(courseId)).currentMode;

    return Row(
      children: AiMode.values.map((mode) {
        final isActive = mode == currentMode;
        final color = _modeColor(mode);
        final label = _modeLabel(mode);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => ref
                    .read(aiChatProvider(courseId).notifier)
                    .setMode(mode),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _modeIcon(mode),
                        size: 18,
                        color: isActive ? color : Colors.grey,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: isActive ? color : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _modeColor(AiMode mode) => switch (mode) {
        AiMode.hint => AppColors.aiHintMode,
        AiMode.check => AppColors.aiCheckMode,
        AiMode.solve => AppColors.aiSolveMode,
      };

  String _modeLabel(AiMode mode) => switch (mode) {
        AiMode.hint => AppStrings.aiHint,
        AiMode.check => AppStrings.aiCheck,
        AiMode.solve => AppStrings.aiSolve,
      };

  IconData _modeIcon(AiMode mode) => switch (mode) {
        AiMode.hint => Icons.lightbulb_outline,
        AiMode.check => Icons.check_circle_outline,
        AiMode.solve => Icons.auto_fix_high,
      };
}
