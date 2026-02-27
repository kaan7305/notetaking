import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';

class Flashcard {
  final String id;
  final String front;
  final String back;
  final String? sourceDocument;
  final int? sourcePage;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.sourceDocument,
    this.sourcePage,
  });
}

class FlashcardState {
  final List<Flashcard> cards;
  final int currentIndex;
  final bool isFlipped;
  final bool isGenerating;
  final String? error;

  const FlashcardState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.isGenerating = false,
    this.error,
  });

  Flashcard? get currentCard =>
      cards.isNotEmpty && currentIndex < cards.length
          ? cards[currentIndex]
          : null;

  bool get hasNext => currentIndex < cards.length - 1;
  bool get hasPrevious => currentIndex > 0;

  FlashcardState copyWith({
    List<Flashcard>? cards,
    int? currentIndex,
    bool? isFlipped,
    bool? isGenerating,
    String? Function()? error,
  }) {
    return FlashcardState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error != null ? error() : this.error,
    );
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  final ApiClient _apiClient;
  final String _courseId;

  FlashcardNotifier(this._apiClient, this._courseId)
      : super(const FlashcardState());

  Future<void> generateFlashcards() async {
    state = state.copyWith(isGenerating: true, error: () => null);

    final result = await _apiClient.post(
      ApiEndpoints.studyAgentChat,
      body: {
        'action': 'generate_flashcards',
        'courseId': _courseId,
      },
    );

    switch (result) {
      case Success(data: final data):
        final cardsJson = data['flashcards'] as List? ?? [];
        final cards = cardsJson.asMap().entries.map((entry) {
          final c = entry.value as Map<String, dynamic>;
          return Flashcard(
            id: '${entry.key}',
            front: c['front'] as String? ?? '',
            back: c['back'] as String? ?? '',
            sourceDocument: c['sourceDocument'] as String?,
            sourcePage: c['sourcePage'] as int?,
          );
        }).toList();

        state = state.copyWith(
          cards: cards,
          currentIndex: 0,
          isFlipped: false,
          isGenerating: false,
        );
      case Failure(message: final msg):
        state = state.copyWith(
          isGenerating: false,
          error: () => msg,
        );
    }
  }

  void flip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  void next() {
    if (!state.hasNext) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      isFlipped: false,
    );
  }

  void previous() {
    if (!state.hasPrevious) return;
    state = state.copyWith(
      currentIndex: state.currentIndex - 1,
      isFlipped: false,
    );
  }

  void reset() {
    state = state.copyWith(currentIndex: 0, isFlipped: false);
  }
}

final flashcardProvider =
    StateNotifierProvider.family<FlashcardNotifier, FlashcardState, String>(
  (ref, courseId) {
    final apiClient = ref.watch(apiClientProvider);
    return FlashcardNotifier(apiClient, courseId);
  },
);
