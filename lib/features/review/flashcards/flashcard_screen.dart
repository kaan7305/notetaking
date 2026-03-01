import 'dart:math' as math;

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
          if (state.cards.isNotEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${state.currentIndex + 1} / ${state.cards.length}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              tooltip: 'Shuffle cards',
              onPressed: () => notifier.shuffle(),
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'Restart from card 1',
              onPressed: () => notifier.reset(),
            ),
          ],
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

class _FlashcardView extends StatefulWidget {
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
  State<_FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<_FlashcardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  final FocusNode _focusNode = FocusNode();

  /// Minimum horizontal drag velocity (px/s) to trigger card navigation.
  static const _swipeVelocityThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _buildAnimations();
    if (widget.isFlipped) _controller.value = 1.0;
    // Grab focus so keyboard shortcuts work without requiring an explicit tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _buildAnimations() {
    _frontRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: math.pi / 2)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50,
      ),
    ]).animate(_controller);

    _backRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_FlashcardView old) {
    super.didUpdateWidget(old);
    // Card changed (shuffle / next / previous) — snap back without animation.
    if (old.card.id != widget.card.id) {
      _controller.value = widget.isFlipped ? 1.0 : 0.0;
      return;
    }
    // Flip state toggled — animate.
    if (old.isFlipped != widget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        if (widget.hasNext) widget.onNext();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        if (widget.hasPrevious) widget.onPrevious();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.arrowDown:
        widget.onFlip();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity < -_swipeVelocityThreshold) {
      if (widget.hasNext) widget.onNext();
    } else if (velocity > _swipeVelocityThreshold) {
      if (widget.hasPrevious) widget.onPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = TextStyle(fontSize: 11, color: Colors.grey.shade400);
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        // Tap anywhere to flip the card.
        onTap: () {
          widget.onFlip();
          _focusNode.requestFocus();
        },
        // Horizontal swipe to navigate between cards.
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final showFront = _controller.value <= 0.5;
                    final rotation = showFront
                        ? _frontRotation.value
                        : _backRotation.value;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotation),
                      child: showFront
                          ? _CardFace(
                              label: 'QUESTION',
                              labelColor: AppColors.primary,
                              text: widget.card.front,
                              hint: 'Tap to reveal answer',
                              sourceDocument: null,
                              sourcePage: null,
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform:
                                  Matrix4.identity()..rotateY(math.pi),
                              child: _CardFace(
                                label: 'ANSWER',
                                labelColor: AppColors.success,
                                text: widget.card.back,
                                hint: null,
                                sourceDocument: widget.card.sourceDocument,
                                sourcePage: widget.card.sourcePage,
                              ),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Swipe / keyboard hint
              Text(
                '← Swipe to navigate  •  Tap to flip',
                style: hintStyle,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: widget.hasPrevious ? widget.onPrevious : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(width: 32),
                  IconButton.filled(
                    onPressed: widget.hasNext ? widget.onNext : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String label;
  final Color labelColor;
  final String text;
  final String? hint;
  final String? sourceDocument;
  final int? sourcePage;

  const _CardFace({
    required this.label,
    required this.labelColor,
    required this.text,
    required this.hint,
    required this.sourceDocument,
    required this.sourcePage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: labelColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1.5),
            ),
            if (hint != null) ...[
              const SizedBox(height: 24),
              Text(
                hint!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
            if (sourceDocument != null) ...[
              const SizedBox(height: 16),
              Text(
                '$sourceDocument${sourcePage != null ? ', p.$sourcePage' : ''}',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
