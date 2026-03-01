import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';
import 'package:study_notebook/core/storage/storage.dart';

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

  /// True while the persisted card set is being loaded from SQLite on init.
  final bool isLoadingHistory;

  final String? error;

  const FlashcardState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.isGenerating = false,
    this.isLoadingHistory = false,
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
    bool? isLoadingHistory,
    String? Function()? error,
  }) {
    return FlashcardState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error != null ? error() : this.error,
    );
  }
}

class FlashcardNotifier extends StateNotifier<FlashcardState> {
  final ApiClient _apiClient;
  final FlashcardDao _dao;
  final String _courseId;

  FlashcardNotifier(this._apiClient, this._dao, this._courseId)
      : super(const FlashcardState(isLoadingHistory: true)) {
    _loadHistory();
  }

  // ──────────────────── persistence ────────────────────

  /// Loads previously generated flashcards from SQLite on provider init.
  Future<void> _loadHistory() async {
    final result = await _dao.getByCourseId(_courseId);
    switch (result) {
      case Success(data: final rows):
        final cards = rows
            .map((r) => Flashcard(
                  id: r.id,
                  front: r.front,
                  back: r.back,
                  sourceDocument: r.sourceDocument,
                  sourcePage: r.sourcePage,
                ))
            .toList();
        state = state.copyWith(cards: cards, isLoadingHistory: false);
      case Failure():
        // On load failure start with empty state rather than blocking UX.
        state = state.copyWith(isLoadingHistory: false);
    }
  }

  /// Converts the in-memory card list to [FlashcardRow]s and persists them.
  Future<void> _persistCards(List<Flashcard> cards) async {
    final now = DateTime.now();
    final rows = cards.asMap().entries.map((entry) {
      final c = entry.value;
      return FlashcardRow(
        id: c.id,
        courseId: _courseId,
        sortOrder: entry.key,
        front: c.front,
        back: c.back,
        sourceDocument: c.sourceDocument,
        sourcePage: c.sourcePage,
        createdAt: now,
      );
    }).toList();
    await _dao.replaceByCourseId(_courseId, rows);
  }

  // ──────────────────── actions ────────────────────

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
        List<Flashcard> cards;
        try {
          final cardsJson = data['flashcards'] as List? ?? [];
          cards = cardsJson.asMap().entries.map((entry) {
            Map<String, dynamic> c;
            try {
              c = entry.value as Map<String, dynamic>;
            } catch (_) {
              c = {};
            }
            return Flashcard(
              id: const Uuid().v4(),
              front: c['front'] as String? ?? '',
              back: c['back'] as String? ?? '',
              sourceDocument: c['sourceDocument'] as String?,
              sourcePage: (c['sourcePage'] as num?)?.toInt(),
            );
          }).toList();
        } catch (e) {
          state = state.copyWith(
            isGenerating: false,
            error: () => 'Failed to parse flashcards from server response.',
          );
          return;
        }

        state = state.copyWith(
          cards: cards,
          currentIndex: 0,
          isFlipped: false,
          isGenerating: false,
        );

        // Persist the new card set in the background.
        await _persistCards(cards);

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

  void shuffle() {
    if (state.cards.length < 2) return;
    final shuffled = List<Flashcard>.from(state.cards)..shuffle();
    state = state.copyWith(cards: shuffled, currentIndex: 0, isFlipped: false);
    // Persist the shuffled order so it survives a restart.
    _persistCards(shuffled);
  }
}

final flashcardProvider =
    StateNotifierProvider.family<FlashcardNotifier, FlashcardState, String>(
  (ref, courseId) {
    final apiClient = ref.watch(apiClientProvider);
    return FlashcardNotifier(apiClient, FlashcardDao(), courseId);
  },
);
