import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';

class TranscriptionState {
  final String? transcript;
  final bool isTranscribing;
  final String? error;

  const TranscriptionState({
    this.transcript,
    this.isTranscribing = false,
    this.error,
  });

  TranscriptionState copyWith({
    String? Function()? transcript,
    bool? isTranscribing,
    String? Function()? error,
  }) {
    return TranscriptionState(
      transcript: transcript != null ? transcript() : this.transcript,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      error: error != null ? error() : this.error,
    );
  }
}

/// Sends audio to backend for Whisper transcription.
class TranscriptionNotifier extends StateNotifier<TranscriptionState> {
  final ApiClient _apiClient;

  TranscriptionNotifier(this._apiClient) : super(const TranscriptionState());

  Future<void> transcribe(String audioFilePath) async {
    state = state.copyWith(
      isTranscribing: true,
      error: () => null,
      transcript: () => null,
    );

    // Upload audio file for transcription via the study agent.
    final result = await _apiClient.uploadFile(
      ApiEndpoints.studyAgentChat,
      audioFilePath,
      'audio',
      fields: {'action': 'transcribe'},
    );

    switch (result) {
      case Success(data: final data):
        final text = data['transcript'] as String? ??
            data['text'] as String? ??
            '';
        state = state.copyWith(
          transcript: () => text,
          isTranscribing: false,
        );
      case Failure(message: final msg):
        state = state.copyWith(
          isTranscribing: false,
          error: () => msg,
        );
    }
  }

  void reset() {
    state = const TranscriptionState();
  }
}

final transcriptionProvider =
    StateNotifierProvider<TranscriptionNotifier, TranscriptionState>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return TranscriptionNotifier(apiClient);
  },
);
