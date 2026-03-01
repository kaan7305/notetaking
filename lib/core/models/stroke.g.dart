// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stroke.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrokeImpl _$$StrokeImplFromJson(Map<String, dynamic> json) => _$StrokeImpl(
  id: json['id'] as String,
  pageId: json['pageId'] as String,
  toolType: json['toolType'] as String,
  color: json['color'] as String,
  strokeWidth: (json['strokeWidth'] as num).toDouble(),
  points: (json['points'] as List<dynamic>)
      .map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  penStyle: json['penStyle'] as String? ?? 'standard',
);

Map<String, dynamic> _$$StrokeImplToJson(_$StrokeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'toolType': instance.toolType,
      'color': instance.color,
      'strokeWidth': instance.strokeWidth,
      'points': instance.points,
      'createdAt': instance.createdAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'penStyle': instance.penStyle,
    };
