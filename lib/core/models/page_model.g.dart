// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageModelImpl _$$PageModelImplFromJson(Map<String, dynamic> json) =>
    _$PageModelImpl(
      id: json['id'] as String,
      notebookId: json['notebookId'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      templateType: json['templateType'] as String? ?? 'blank',
      thumbnailPath: json['thumbnailPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$$PageModelImplToJson(_$PageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notebookId': instance.notebookId,
      'pageNumber': instance.pageNumber,
      'templateType': instance.templateType,
      'thumbnailPath': instance.thumbnailPath,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isSynced': instance.isSynced,
    };
