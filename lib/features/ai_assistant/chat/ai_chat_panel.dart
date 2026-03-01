import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/ai_provider.dart';
import 'package:study_notebook/core/utils/constants.dart';

import '../modes/ai_mode_selector.dart';
import 'chat_message_bubble.dart';

/// Slide-out AI chat panel for the notebook screen.
class AiChatPanel extends ConsumerStatefulWidget {
  final String courseId;

  /// Optional callback that captures the current canvas page as a base64 PNG.
  /// Called automatically in [AiMode.check] and [AiMode.solve] modes.
  final Future<String?> Function()? captureCanvas;

  const AiChatPanel({
    super.key,
    required this.courseId,
    this.captureCanvas,
  });

  @override
  ConsumerState<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends ConsumerState<AiChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    // For Check and Solve modes, capture the current canvas page as an image.
    String? imageBase64;
    final mode =
        ref.read(aiChatProvider(widget.courseId)).currentMode;
    if ((mode == AiMode.check || mode == AiMode.solve) &&
        widget.captureCanvas != null) {
      imageBase64 = await widget.captureCanvas!();
    }

    ref
        .read(aiChatProvider(widget.courseId).notifier)
        .sendMessage(text, imageBase64: imageBase64);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider(widget.courseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll to the bottom when the AI finishes responding.
    ref.listen<AiChatState>(aiChatProvider(widget.courseId), (prev, next) {
      if ((prev?.isLoading ?? false) && !next.isLoading) {
        _scrollToBottom();
      }
    });

    // Clamp panel width to 40 % of the screen, between 300 and 480 px.
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = (screenWidth * 0.4).clamp(300.0, 480.0);

    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          left: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header with mode selector.
          _ChatHeader(courseId: widget.courseId),

          // Error banner.
          if (chatState.error != null)
            _ErrorBanner(
              error: chatState.error!,
              canRetry: chatState.retryContent != null,
              onRetry: () =>
                  ref.read(aiChatProvider(widget.courseId).notifier).retry(),
              onDismiss: () => ref
                  .read(aiChatProvider(widget.courseId).notifier)
                  .clearError(),
            ),

          // Messages list.
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyChat(mode: chatState.currentMode)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: chatState.messages.length +
                        (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return const _TypingIndicator();
                      }
                      return ChatMessageBubble(
                        message: chatState.messages[index],
                        courseId: widget.courseId,
                      );
                    },
                  ),
          ),

          // Input bar.
          _ChatInput(
            controller: _controller,
            isLoading: chatState.isLoading,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  final String courseId;
  const _ChatHeader({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'AI Assistant',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                onPressed: () => ref
                    .read(aiChatProvider(courseId).notifier)
                    .clearChat(),
                tooltip: 'Clear chat',
              ),
            ],
          ),
          const SizedBox(height: 4),
          AiModeSelector(courseId: courseId),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final AiMode mode;
  const _EmptyChat({required this.mode});

  @override
  Widget build(BuildContext context) {
    final description = switch (mode) {
      AiMode.hint => AppStrings.aiHintDescription,
      AiMode.check => AppStrings.aiCheckDescription,
      AiMode.solve => AppStrings.aiSolveDescription,
    };

    final modeColor = switch (mode) {
      AiMode.hint => AppColors.aiHintMode,
      AiMode.check => AppColors.aiCheckMode,
      AiMode.solve => AppColors.aiSolveMode,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: modeColor),
            const SizedBox(height: 16),
            Text(
              '${mode.name[0].toUpperCase()}${mode.name.substring(1)} Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: modeColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.toolbarDivider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primary,
            onPressed: isLoading ? null : onSend,
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.error,
    required this.canRetry,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
          if (canRetry)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Retry', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
