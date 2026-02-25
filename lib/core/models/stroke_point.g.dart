// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrokePointImpl _$$StrokePointImplFromJson(Map<String, dynamic> json) =>
    _$StrokePointImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      tilt: (json['tilt'] as num?)?.toDouble() ?? 0.0,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$$StrokePointImplToJson(_$StrokePointImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'pressure': instance.pressure,
      'tilt': instance.tilt,
      'timestamp': instance.timestamp,
    };
