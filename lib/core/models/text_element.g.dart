// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TextElementImpl _$$TextElementImplFromJson(Map<String, dynamic> json) =>
    _$TextElementImpl(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      content: json['content'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontFamily: json['fontFamily'] as String? ?? 'system',
      color: json['color'] as String? ?? '#000000',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$TextElementImplToJson(_$TextElementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'content': instance.content,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'fontSize': instance.fontSize,
      'fontFamily': instance.fontFamily,
      'color': instance.color,
      'createdAt': instance.createdAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
