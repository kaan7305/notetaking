import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class Document with _$Document {
  const factory Document({
    required String id,
    required String courseId,
    required String userId,
    required String fileName,
    required String storagePath, // Supabase storage path
    String? localPath, // local cached path
    @Default(0) int pageCount,
    @Default('uploading') String status, // 'uploading' | 'processing' | 'ready' | 'error'
    required DateTime createdAt,
    @Default(false) bool isSynced,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
