import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/app/colors.dart';

import 'flashcard_provider.dart';

/// Flashcard review screen with flip animation and navigation.
class FlashcardScreen extends ConsumerWidget {
  final String courseId;

  const FlashcardScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashcardProvider(courseId));
    final notifier = ref.read(flashcardProvider(courseId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          if (state.cards.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${state.currentIndex + 1} / ${state.cards.length}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: state.cards.isEmpty
          ? _EmptyState(
              isGenerating: state.isGenerating,
              error: state.error,
              onGenerate: () => notifier.generateFlashcards(),
            )
          : _FlashcardView(
              card: state.currentCard!,
              isFlipped: state.isFlipped,
              hasNext: state.hasNext,
              hasPrevious: state.hasPrevious,
              onFlip: () => notifier.flip(),
              onNext: () => notifier.next(),
              onPrevious: () => notifier.previous(),
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
            Icon(Icons.style, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Generate flashcards from your course documents',
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
              label:
                  Text(isGenerating ? 'Generating...' : 'Generate Flashcards'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardView extends StatelessWidget {
  final Flashcard card;
  final bool isFlipped;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onFlip;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _FlashcardView({
    required this.card,
    required this.isFlipped,
    required this.hasNext,
    required this.hasPrevious,
    required this.onFlip,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onFlip,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  key: ValueKey('${card.id}_$isFlipped'),
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isFlipped ? 'ANSWER' : 'QUESTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isFlipped
                                ? AppColors.success
                                : AppColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isFlipped ? card.back : card.front,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isFlipped)
                          Text(
                            'Tap to reveal answer',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        if (isFlipped &&
                            card.sourceDocument != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${card.sourceDocument}${card.sourcePage != null ? ', p.${card.sourcePage}' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: hasPrevious ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
              ),
              const SizedBox(width: 32),
              IconButton.filled(
                onPressed: hasNext ? onNext : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
