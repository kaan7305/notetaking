import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke_point.freezed.dart';
part 'stroke_point.g.dart';

@freezed
class StrokePoint with _$StrokePoint {
  const factory StrokePoint({
    required double x,
    required double y,
    required double pressure,
    @Default(0.0) double tilt,
    required int timestamp,
  }) = _StrokePoint;

  factory StrokePoint.fromJson(Map<String, dynamic> json) =>
      _$StrokePointFromJson(json);
}
