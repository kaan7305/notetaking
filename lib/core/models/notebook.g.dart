// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotebookImpl _$$NotebookImplFromJson(Map<String, dynamic> json) =>
    _$NotebookImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      coverImagePath: json['coverImagePath'] as String?,
      pageSize: json['pageSize'] as String? ?? 'letter',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotebookImplToJson(_$NotebookImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'userId': instance.userId,
      'title': instance.title,
      'coverImagePath': instance.coverImagePath,
      'pageSize': instance.pageSize,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'isSynced': instance.isSynced,
    };
