import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_model.freezed.dart';
part 'page_model.g.dart';

@freezed
class PageModel with _$PageModel {
  const factory PageModel({
    required String id,
    required String notebookId,
    required int pageNumber,
    @Default('blank') String templateType, // 'blank' | 'lined' | 'grid' | 'dotted'
    String? thumbnailPath,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _PageModel;

  factory PageModel.fromJson(Map<String, dynamic> json) =>
      _$PageModelFromJson(json);
}
