import 'package:freezed_annotation/freezed_annotation.dart';

part 'source_reference.freezed.dart';
part 'source_reference.g.dart';

@freezed
class SourceReference with _$SourceReference {
  const factory SourceReference({
    required String documentId,
    required String documentName,
    required int pageNumber,
    String? snippet,
  }) = _SourceReference;

  factory SourceReference.fromJson(Map<String, dynamic> json) =>
      _$SourceReferenceFromJson(json);
}
