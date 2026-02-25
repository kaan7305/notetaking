import 'package:freezed_annotation/freezed_annotation.dart';

part 'notebook.freezed.dart';
part 'notebook.g.dart';

@freezed
class Notebook with _$Notebook {
  const factory Notebook({
    required String id,
    required String courseId,
    required String userId,
    required String title,
    String? coverImagePath,
    @Default('letter') String pageSize, // 'letter' | 'a4'
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isFavorite,
    @Default(false) bool isSynced,
  }) = _Notebook;

  factory Notebook.fromJson(Map<String, dynamic> json) =>
      _$NotebookFromJson(json);
}
