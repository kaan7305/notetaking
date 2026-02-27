import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';

import '../references/source_reference_chips.dart';

/// A single chat message bubble (user or assistant).
class ChatMessageBubble extends StatelessWidget {
  final AiMessage message;
  final String courseId;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final modeColor = switch (message.mode) {
      'hint' => AppColors.aiHintMode,
      'check' => AppColors.aiCheckMode,
      'solve' => AppColors.aiSolveMode,
      _ => AppColors.primary,
    };

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode badge for assistant messages.
            if (!isUser)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.mode.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: modeColor,
                  ),
                ),
              ),

            // Message text.
            SelectableText(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : null,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            // Source references for assistant messages.
            if (!isUser && message.references.isNotEmpty) ...[
              const SizedBox(height: 8),
              SourceReferenceChips(
                references: message.references,
                courseId: courseId,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
