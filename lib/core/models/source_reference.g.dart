// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SourceReferenceImpl _$$SourceReferenceImplFromJson(
  Map<String, dynamic> json,
) => _$SourceReferenceImpl(
  documentId: json['documentId'] as String,
  documentName: json['documentName'] as String,
  pageNumber: (json['pageNumber'] as num).toInt(),
  snippet: json['snippet'] as String?,
);

Map<String, dynamic> _$$SourceReferenceImplToJson(
  _$SourceReferenceImpl instance,
) => <String, dynamic>{
  'documentId': instance.documentId,
  'documentName': instance.documentName,
  'pageNumber': instance.pageNumber,
  'snippet': instance.snippet,
};
