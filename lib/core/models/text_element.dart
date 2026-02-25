import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_element.freezed.dart';
part 'text_element.g.dart';

@freezed
class TextElement with _$TextElement {
  const factory TextElement({
    required String id,
    required String pageId,
    required String content,
    required double x,
    required double y,
    required double width,
    @Default(16.0) double fontSize,
    @Default('system') String fontFamily,
    @Default('#000000') String color,
    required DateTime createdAt,
    @Default(false) bool isDeleted,
  }) = _TextElement;

  factory TextElement.fromJson(Map<String, dynamic> json) =>
      _$TextElementFromJson(json);
}
