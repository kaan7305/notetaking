import 'package:freezed_annotation/freezed_annotation.dart';

import 'source_reference.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

@freezed
class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required String courseId,
    required String role, // 'user' | 'assistant'
    required String content,
    String? imageBase64, // for user messages with canvas selection
    required String mode, // 'hint' | 'check' | 'solve'
    @Default([]) List<SourceReference> references,
    required DateTime createdAt,
  }) = _AiMessage;

  factory AiMessage.fromJson(Map<String, dynamic> json) =>
      _$AiMessageFromJson(json);
}
