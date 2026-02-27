import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/api/api_client.dart';
import 'package:study_notebook/core/api/api_endpoints.dart';
import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/providers/api_provider.dart';

/// State for the AI chat, scoped to a course.
class AiChatState {
  final List<AiMessage> messages;
  final AiMode currentMode;
  final bool isLoading;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.currentMode = AiMode.hint,
    this.isLoading = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    AiMode? currentMode,
    bool? isLoading,
    String? Function()? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      currentMode: currentMode ?? this.currentMode,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// Manages AI chat for a course.
class AiChatNotifier extends StateNotifier<AiChatState> {
  final ApiClient _apiClient;
  final String _courseId;

  AiChatNotifier(this._apiClient, this._courseId)
      : super(const AiChatState());

  void setMode(AiMode mode) {
    state = state.copyWith(currentMode: mode);
  }

  /// Sends a text query to the AI backend.
  Future<void> sendMessage(String content, {String? imageBase64}) async {
    final userMessage = AiMessage(
      id: const Uuid().v4(),
      courseId: _courseId,
      role: 'user',
      content: content,
      imageBase64: imageBase64,
      mode: state.currentMode.name,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: () => null,
    );

    // Build the request body for the backend.
    final body = <String, dynamic>{
      'courseId': _courseId,
      'mode': state.currentMode.name,
      'message': content,
      if (imageBase64 != null) 'image': imageBase64,
      'history': state.messages
          .take(20) // Limit context window
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
    };

    final result = await _apiClient.post(
      ApiEndpoints.queryAI,
      body: body,
    );

    switch (result) {
      case Success(data: final data):
        final responseText = data['response'] as String? ??
            data['answer'] as String? ??
            'No response received.';
        final refsJson = data['references'] as List? ?? [];
        final references = refsJson
            .map((r) => SourceReference(
                  documentId: r['documentId'] as String? ?? '',
                  documentName: r['documentName'] as String? ?? '',
                  pageNumber: r['pageNumber'] as int? ?? 0,
                  snippet: r['snippet'] as String?,
                ))
            .toList();

        final assistantMessage = AiMessage(
          id: const Uuid().v4(),
          courseId: _courseId,
          role: 'assistant',
          content: responseText,
          mode: state.currentMode.name,
          references: references,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, assistantMessage],
          isLoading: false,
        );

      case Failure(message: final msg):
        state = state.copyWith(
          isLoading: false,
          error: () => msg,
        );
    }
  }

  void clearChat() {
    state = const AiChatState();
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

/// Family provider keyed by courseId.
final aiChatProvider =
    StateNotifierProvider.family<AiChatNotifier, AiChatState, String>(
  (ref, courseId) {
    final apiClient = ref.watch(apiClientProvider);
    return AiChatNotifier(apiClient, courseId);
  },
);
