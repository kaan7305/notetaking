// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'source_reference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SourceReference _$SourceReferenceFromJson(Map<String, dynamic> json) {
  return _SourceReference.fromJson(json);
}

/// @nodoc
mixin _$SourceReference {
  String get documentId => throw _privateConstructorUsedError;
  String get documentName => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  String? get snippet => throw _privateConstructorUsedError;

  /// Serializes this SourceReference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceReferenceCopyWith<SourceReference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceReferenceCopyWith<$Res> {
  factory $SourceReferenceCopyWith(
    SourceReference value,
    $Res Function(SourceReference) then,
  ) = _$SourceReferenceCopyWithImpl<$Res, SourceReference>;
  @useResult
  $Res call({
    String documentId,
    String documentName,
    int pageNumber,
    String? snippet,
  });
}

/// @nodoc
class _$SourceReferenceCopyWithImpl<$Res, $Val extends SourceReference>
    implements $SourceReferenceCopyWith<$Res> {
  _$SourceReferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? documentName = null,
    Object? pageNumber = null,
    Object? snippet = freezed,
  }) {
    return _then(
      _value.copyWith(
            documentId: null == documentId
                ? _value.documentId
                : documentId // ignore: cast_nullable_to_non_nullable
                      as String,
            documentName: null == documentName
                ? _value.documentName
                : documentName // ignore: cast_nullable_to_non_nullable
                      as String,
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            snippet: freezed == snippet
                ? _value.snippet
                : snippet // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SourceReferenceImplCopyWith<$Res>
    implements $SourceReferenceCopyWith<$Res> {
  factory _$$SourceReferenceImplCopyWith(
    _$SourceReferenceImpl value,
    $Res Function(_$SourceReferenceImpl) then,
  ) = __$$SourceReferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String documentId,
    String documentName,
    int pageNumber,
    String? snippet,
  });
}

/// @nodoc
class __$$SourceReferenceImplCopyWithImpl<$Res>
    extends _$SourceReferenceCopyWithImpl<$Res, _$SourceReferenceImpl>
    implements _$$SourceReferenceImplCopyWith<$Res> {
  __$$SourceReferenceImplCopyWithImpl(
    _$SourceReferenceImpl _value,
    $Res Function(_$SourceReferenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourceReference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentId = null,
    Object? documentName = null,
    Object? pageNumber = null,
    Object? snippet = freezed,
  }) {
    return _then(
      _$SourceReferenceImpl(
        documentId: null == documentId
            ? _value.documentId
            : documentId // ignore: cast_nullable_to_non_nullable
                  as String,
        documentName: null == documentName
            ? _value.documentName
            : documentName // ignore: cast_nullable_to_non_nullable
                  as String,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        snippet: freezed == snippet
            ? _value.snippet
            : snippet // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceReferenceImpl implements _SourceReference {
  const _$SourceReferenceImpl({
    required this.documentId,
    required this.documentName,
    required this.pageNumber,
    this.snippet,
  });

  factory _$SourceReferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceReferenceImplFromJson(json);

  @override
  final String documentId;
  @override
  final String documentName;
  @override
  final int pageNumber;
  @override
  final String? snippet;

  @override
  String toString() {
    return 'SourceReference(documentId: $documentId, documentName: $documentName, pageNumber: $pageNumber, snippet: $snippet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceReferenceImpl &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.documentName, documentName) ||
                other.documentName == documentName) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.snippet, snippet) || other.snippet == snippet));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, documentId, documentName, pageNumber, snippet);

  /// Create a copy of SourceReference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceReferenceImplCopyWith<_$SourceReferenceImpl> get copyWith =>
      __$$SourceReferenceImplCopyWithImpl<_$SourceReferenceImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceReferenceImplToJson(this);
  }
}

abstract class _SourceReference implements SourceReference {
  const factory _SourceReference({
    required final String documentId,
    required final String documentName,
    required final int pageNumber,
    final String? snippet,
  }) = _$SourceReferenceImpl;

  factory _SourceReference.fromJson(Map<String, dynamic> json) =
      _$SourceReferenceImpl.fromJson;

  @override
  String get documentId;
  @override
  String get documentName;
  @override
  int get pageNumber;
  @override
  String? get snippet;

  /// Create a copy of SourceReference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceReferenceImplCopyWith<_$SourceReferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
