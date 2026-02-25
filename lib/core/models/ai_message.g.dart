// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiMessageImpl _$$AiMessageImplFromJson(Map<String, dynamic> json) =>
    _$AiMessageImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      imageBase64: json['imageBase64'] as String?,
      mode: json['mode'] as String,
      references:
          (json['references'] as List<dynamic>?)
              ?.map((e) => SourceReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AiMessageImplToJson(_$AiMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'role': instance.role,
      'content': instance.content,
      'imageBase64': instance.imageBase64,
      'mode': instance.mode,
      'references': instance.references,
      'createdAt': instance.createdAt.toIso8601String(),
    };
