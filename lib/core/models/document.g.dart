// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentImpl _$$DocumentImplFromJson(Map<String, dynamic> json) =>
    _$DocumentImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      userId: json['userId'] as String,
      fileName: json['fileName'] as String,
      storagePath: json['storagePath'] as String,
      localPath: json['localPath'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'uploading',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
    );

Map<String, dynamic> _$$DocumentImplToJson(_$DocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'userId': instance.userId,
      'fileName': instance.fileName,
      'storagePath': instance.storagePath,
      'localPath': instance.localPath,
      'pageCount': instance.pageCount,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'isSynced': instance.isSynced,
    };
