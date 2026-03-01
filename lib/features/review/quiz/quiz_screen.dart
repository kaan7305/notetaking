import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';

import '../practice/practice_provider.dart';

/// Quiz screen with multiple-choice questions.
class QuizScreen extends ConsumerWidget {
  final String courseId;

  const QuizScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(courseId));
    final notifier = ref.read(practiceProvider(courseId).notifier);

    // Show a compact spinner while SQLite history loads (typically < 100 ms).
    if (state.isLoadingHistory) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Quiz'),
        actions: [
          if (state.questions.isNotEmpty && !state.isComplete)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${state.currentIndex + 1} / ${state.questions.length}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          if (state.isComplete)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'New questions',
              onPressed: state.isGenerating
                  ? null
                  : () => notifier.generateQuestions(),
            ),
        ],
      ),
      body: state.questions.isEmpty
          ? _EmptyState(
              isGenerating: state.isGenerating,
              error: state.error,
              onGenerate: () => notifier.generateQuestions(),
            )
          : state.isComplete
              ? _CompletionScreen(
                  correct: state.correctCount,
                  total: state.questions.length,
                  isGenerating: state.isGenerating,
                  onRestart: () => notifier.restart(),
                  onNewQuestions: () => notifier.generateQuestions(),
                )
              : _QuestionView(
                  question: state.currentQuestion!,
                  currentIndex: state.currentIndex,
                  totalQuestions: state.questions.length,
                  selectedAnswer: state.selectedAnswer,
                  showExplanation: state.showExplanation,
                  onSelect: (index) => notifier.selectAnswer(index),
                  onNext: () => notifier.nextQuestion(),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isGenerating;
  final String? error;
  final VoidCallback onGenerate;

  const _EmptyState({
    required this.isGenerating,
    this.error,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Generate practice questions from your course documents',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (error != null) ...[
              Text(error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                  isGenerating ? 'Generating...' : 'Generate Practice Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  final PracticeQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool showExplanation;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _QuestionView({
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    this.selectedAnswer,
    required this.showExplanation,
    required this.onSelect,
    required this.onNext,
  });

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Grab focus so keyboard shortcuts work immediately without a tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Space / Enter — advance to next question (only after answering).
    if (event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (widget.showExplanation) {
        widget.onNext();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // A/B/C/D — select the corresponding option (only before answering).
    if (!widget.showExplanation) {
      final optionCount = widget.question.options.length;
      int? selectedIndex;
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyA:
          selectedIndex = 0;
        case LogicalKeyboardKey.keyB:
          selectedIndex = 1;
        case LogicalKeyboardKey.keyC:
          selectedIndex = 2;
        case LogicalKeyboardKey.keyD:
          selectedIndex = 3;
      }
      if (selectedIndex != null && selectedIndex < optionCount) {
        widget.onSelect(selectedIndex);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalQuestions > 0
        ? (widget.currentIndex + (widget.showExplanation ? 1 : 0)) /
            widget.totalQuestions
        : 0.0;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Column(
        children: [
          // Progress bar across the full width at the top.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.toDouble()),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question.
                  Text(
                    widget.question.question,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Options.
                  ...widget.question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = widget.selectedAnswer == index;
                    final isCorrect = index == widget.question.correctIndex;

                    Color? bgColor;
                    Color? borderColor;
                    if (widget.showExplanation) {
                      if (isCorrect) {
                        bgColor = AppColors.success.withValues(alpha: 0.1);
                        borderColor = AppColors.success;
                      } else if (isSelected) {
                        bgColor = AppColors.error.withValues(alpha: 0.1);
                        borderColor = AppColors.error;
                      }
                    } else if (isSelected) {
                      bgColor = AppColors.primary.withValues(alpha: 0.1);
                      borderColor = AppColors.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: bgColor ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.showExplanation
                              ? null
                              : () => widget.onSelect(index),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor ?? Colors.grey.shade300,
                                width:
                                    isSelected || (widget.showExplanation && isCorrect)
                                        ? 2
                                        : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: borderColor ?? Colors.grey.shade400,
                                    ),
                                    color: isSelected ||
                                            (widget.showExplanation && isCorrect)
                                        ? borderColor
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected ||
                                                (widget.showExplanation && isCorrect)
                                            ? Colors.white
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(option,
                                      style:
                                          const TextStyle(fontSize: 15)),
                                ),
                                if (widget.showExplanation && isCorrect)
                                  const Icon(Icons.check_circle,
                                      color: AppColors.success, size: 22),
                                if (widget.showExplanation &&
                                    isSelected &&
                                    !isCorrect)
                                  const Icon(Icons.cancel,
                                      color: AppColors.error, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Keyboard hint (shown below options).
                  const SizedBox(height: 4),
                  Text(
                    widget.showExplanation
                        ? 'Space / Enter → Next Question'
                        : 'A / B / C / D to select',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),

                  // Explanation.
                  if (widget.showExplanation) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Explanation',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.question.explanation,
                              style: const TextStyle(height: 1.5),
                            ),
                            if (widget.question.sourceDocument != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Source: ${widget.question.sourceDocument}'
                                '${widget.question.sourcePage != null ? ', p.${widget.question.sourcePage}' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: widget.onNext,
                      child: const Text('Next Question'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionScreen extends StatelessWidget {
  final int correct;
  final int total;
  final bool isGenerating;
  final VoidCallback onRestart;
  final VoidCallback onNewQuestions;

  const _CompletionScreen({
    required this.correct,
    required this.total,
    required this.isGenerating,
    required this.onRestart,
    required this.onNewQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (correct / total * 100).round() : 0;

    final (icon, iconColor, message) = switch (percentage) {
      >= 90 => (
          Icons.emoji_events,
          AppColors.warning,
          'Excellent work! You\'ve mastered this material.',
        ),
      >= 70 => (
          Icons.thumb_up_rounded,
          AppColors.success,
          'Good job! Review the explanations to go further.',
        ),
      >= 50 => (
          Icons.school,
          AppColors.primary,
          'Halfway there. Keep reviewing and try again.',
        ),
      _ => (
          Icons.menu_book_rounded,
          Colors.grey.shade500,
          'More practice needed — re-read the source material.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            const Text(
              'Quiz Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$correct / $total correct ($percentage%)',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isGenerating ? null : onNewQuestions,
              icon: isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(isGenerating ? 'Generating…' : 'New Questions'),
            ),
          ],
        ),
      ),
    );
  }
}
