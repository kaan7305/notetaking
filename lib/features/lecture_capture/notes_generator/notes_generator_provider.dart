import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';
import 'package:study_notebook/core/storage/storage.dart';

class GeneratedNotes {
  final String id;
  final String title;
  final String summary;
  final List<String> keyPoints;
  final String fullNotes;
  final DateTime createdAt;

  const GeneratedNotes({
    required this.id,
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.fullNotes,
    required this.createdAt,
  });
}

class NotesGeneratorState {
  final GeneratedNotes? notes;
  final bool isGenerating;

  /// True while the most-recent persisted note is loading from SQLite on init.
  final bool isLoadingHistory;

  final String? error;

  const NotesGeneratorState({
    this.notes,
    this.isGenerating = false,
    this.isLoadingHistory = false,
    this.error,
  });

  NotesGeneratorState copyWith({
    GeneratedNotes? Function()? notes,
    bool? isGenerating,
    bool? isLoadingHistory,
    String? Function()? error,
  }) {
    return NotesGeneratorState(
      notes: notes != null ? notes() : this.notes,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      error: error != null ? error() : this.error,
    );
  }
}

/// Generates structured notes from a lecture transcript and persists them to
/// SQLite so they survive navigation.
///
/// The provider is a family keyed by [courseId]. On first build it loads the
/// most recently generated note for that course from the DB.
class NotesGeneratorNotifier extends StateNotifier<NotesGeneratorState> {
  final ApiClient _apiClient;
  final LectureNoteDao _dao;
  final String _courseId;

  NotesGeneratorNotifier(this._apiClient, this._dao, this._courseId)
      : super(const NotesGeneratorState(isLoadingHistory: true)) {
    _loadHistory();
  }

  // ──────────────────── persistence ────────────────────

  Future<void> _loadHistory() async {
    final result = await _dao.getMostRecentByCourseId(_courseId);
    switch (result) {
      case Success(data: final row):
        final notes = row == null
            ? null
            : GeneratedNotes(
                id: row.id,
                title: row.title,
                summary: row.summary,
                keyPoints: row.keyPoints,
                fullNotes: row.fullNotes,
                createdAt: row.createdAt,
              );
        state = state.copyWith(
          notes: () => notes,
          isLoadingHistory: false,
        );
      case Failure():
        // On load failure keep the UI unblocked — start with no notes.
        state = state.copyWith(isLoadingHistory: false);
    }
  }

  // ──────────────────── actions ────────────────────

  Future<void> generateNotes(String transcript) async {
    state = state.copyWith(
      isGenerating: true,
      error: () => null,
    );

    final result = await _apiClient.post(
      ApiEndpoints.studyAgentChat,
      body: {
        'action': 'generate_notes',
        'transcript': transcript,
        'courseId': _courseId,
      },
    );

    switch (result) {
      case Success(data: final data):
        final id = const Uuid().v4();
        final now = DateTime.now();
        final notes = GeneratedNotes(
          id: id,
          title: data['title'] as String? ?? 'Lecture Notes',
          summary: data['summary'] as String? ?? '',
          keyPoints: (data['keyPoints'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          fullNotes: data['notes'] as String? ?? transcript,
          createdAt: now,
        );
        state = state.copyWith(
          notes: () => notes,
          isGenerating: false,
        );

        // Persist to SQLite in the background.
        await _dao.insert(LectureNoteRow(
          id: notes.id,
          courseId: _courseId,
          title: notes.title,
          summary: notes.summary,
          keyPoints: notes.keyPoints,
          fullNotes: notes.fullNotes,
          createdAt: notes.createdAt,
        ));

      case Failure(message: final msg):
        state = state.copyWith(
          isGenerating: false,
          error: () => msg,
        );
    }
  }

  /// Deletes the currently displayed notes from the DB and clears the UI.
  Future<void> deleteCurrentNotes() async {
    final id = state.notes?.id;
    state = state.copyWith(notes: () => null);
    if (id != null) {
      await _dao.deleteById(id);
    }
  }

  void reset() {
    state = const NotesGeneratorState();
  }
}

/// Family provider keyed by courseId.
final notesGeneratorProvider = StateNotifierProvider.family<
    NotesGeneratorNotifier, NotesGeneratorState, String>(
  (ref, courseId) {
    final apiClient = ref.watch(apiClientProvider);
    return NotesGeneratorNotifier(apiClient, LectureNoteDao(), courseId);
  },
);
