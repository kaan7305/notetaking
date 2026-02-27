import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';

class PracticeQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? sourceDocument;
  final int? sourcePage;

  const PracticeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.sourceDocument,
    this.sourcePage,
  });
}

class PracticeState {
  final List<PracticeQuestion> questions;
  final int currentIndex;
  final int? selectedAnswer;
  final bool showExplanation;
  final int correctCount;
  final bool isGenerating;
  final bool isComplete;
  final String? error;

  const PracticeState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.showExplanation = false,
    this.correctCount = 0,
    this.isGenerating = false,
    this.isComplete = false,
    this.error,
  });

  PracticeQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  PracticeState copyWith({
    List<PracticeQuestion>? questions,
    int? currentIndex,
    int? Function()? selectedAnswer,
    bool? showExplanation,
    int? correctCount,
    bool? isGenerating,
    bool? isComplete,
    String? Function()? error,
  }) {
    return PracticeState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: selectedAnswer != null
          ? selectedAnswer()
          : this.selectedAnswer,
      showExplanation: showExplanation ?? this.showExplanation,
      correctCount: correctCount ?? this.correctCount,
      isGenerating: isGenerating ?? this.isGenerating,
      isComplete: isComplete ?? this.isComplete,
      error: error != null ? error() : this.error,
    );
  }
}

class PracticeNotifier extends StateNotifier<PracticeState> {
  final ApiClient _apiClient;
  final String _courseId;

  PracticeNotifier(this._apiClient, this._courseId)
      : super(const PracticeState());

  Future<void> generateQuestions() async {
    state = state.copyWith(isGenerating: true, error: () => null);

    final result = await _apiClient.post(
      ApiEndpoints.studyAgentChat,
      body: {
        'action': 'generate_practice',
        'courseId': _courseId,
      },
    );

    switch (result) {
      case Success(data: final data):
        final questionsJson = data['questions'] as List? ?? [];
        final questions = questionsJson.asMap().entries.map((entry) {
          final q = entry.value as Map<String, dynamic>;
          return PracticeQuestion(
            id: '${entry.key}',
            question: q['question'] as String? ?? '',
            options: (q['options'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            correctIndex: q['correctIndex'] as int? ?? 0,
            explanation: q['explanation'] as String? ?? '',
            sourceDocument: q['sourceDocument'] as String?,
            sourcePage: q['sourcePage'] as int?,
          );
        }).toList();

        state = state.copyWith(
          questions: questions,
          currentIndex: 0,
          selectedAnswer: () => null,
          showExplanation: false,
          correctCount: 0,
          isGenerating: false,
          isComplete: false,
        );
      case Failure(message: final msg):
        state = state.copyWith(
          isGenerating: false,
          error: () => msg,
        );
    }
  }

  void selectAnswer(int index) {
    if (state.showExplanation) return;

    final isCorrect = index == state.currentQuestion?.correctIndex;
    state = state.copyWith(
      selectedAnswer: () => index,
      showExplanation: true,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
    );
  }

  void nextQuestion() {
    if (state.currentIndex >= state.questions.length - 1) {
      state = state.copyWith(isComplete: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedAnswer: () => null,
      showExplanation: false,
    );
  }

  void restart() {
    state = state.copyWith(
      currentIndex: 0,
      selectedAnswer: () => null,
      showExplanation: false,
      correctCount: 0,
      isComplete: false,
    );
  }
}

final practiceProvider =
    StateNotifierProvider.family<PracticeNotifier, PracticeState, String>(
  (ref, courseId) {
    final apiClient = ref.watch(apiClientProvider);
    return PracticeNotifier(apiClient, courseId);
  },
);
