import 'package:freezed_annotation/freezed_annotation.dart';

import 'stroke_point.dart';

part 'stroke.freezed.dart';
part 'stroke.g.dart';

@freezed
class Stroke with _$Stroke {
  const factory Stroke({
    required String id,
    required String pageId,
    required String toolType, // 'pen' | 'highlighter'
    required String color, // hex string like '#FF0000'
    required double strokeWidth,
    required List<StrokePoint> points,
    required DateTime createdAt,
    @Default(false) bool isDeleted,
    @Default('standard') String penStyle,
  }) = _Stroke;

  factory Stroke.fromJson(Map<String, dynamic> json) =>
      _$StrokeFromJson(json);
}
