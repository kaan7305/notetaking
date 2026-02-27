import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';

class GeneratedNotes {
  final String title;
  final String summary;
  final List<String> keyPoints;
  final String fullNotes;

  const GeneratedNotes({
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.fullNotes,
  });
}

class NotesGeneratorState {
  final GeneratedNotes? notes;
  final bool isGenerating;
  final String? error;

  const NotesGeneratorState({
    this.notes,
    this.isGenerating = false,
    this.error,
  });

  NotesGeneratorState copyWith({
    GeneratedNotes? Function()? notes,
    bool? isGenerating,
    String? Function()? error,
  }) {
    return NotesGeneratorState(
      notes: notes != null ? notes() : this.notes,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error != null ? error() : this.error,
    );
  }
}

/// Generates structured notes from a lecture transcript.
class NotesGeneratorNotifier extends StateNotifier<NotesGeneratorState> {
  final ApiClient _apiClient;

  NotesGeneratorNotifier(this._apiClient) : super(const NotesGeneratorState());

  Future<void> generateNotes(String transcript, {String? courseId}) async {
    state = state.copyWith(
      isGenerating: true,
      error: () => null,
    );

    final result = await _apiClient.post(
      ApiEndpoints.studyAgentChat,
      body: {
        'action': 'generate_notes',
        'transcript': transcript,
        if (courseId != null) 'courseId': courseId,
      },
    );

    switch (result) {
      case Success(data: final data):
        final notes = GeneratedNotes(
          title: data['title'] as String? ?? 'Lecture Notes',
          summary: data['summary'] as String? ?? '',
          keyPoints: (data['keyPoints'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          fullNotes: data['notes'] as String? ?? transcript,
        );
        state = state.copyWith(
          notes: () => notes,
          isGenerating: false,
        );
      case Failure(message: final msg):
        state = state.copyWith(
          isGenerating: false,
          error: () => msg,
        );
    }
  }

  void reset() {
    state = const NotesGeneratorState();
  }
}

final notesGeneratorProvider =
    StateNotifierProvider<NotesGeneratorNotifier, NotesGeneratorState>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return NotesGeneratorNotifier(apiClient);
  },
);
