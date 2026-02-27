// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageModel _$PageModelFromJson(Map<String, dynamic> json) {
  return _PageModel.fromJson(json);
}

/// @nodoc
mixin _$PageModel {
  String get id => throw _privateConstructorUsedError;
  String get notebookId => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  String get templateType =>
      throw _privateConstructorUsedError; // 'blank' | 'lined' | 'grid' | 'dotted'
  String get backgroundColor => throw _privateConstructorUsedError;
  double get lineSpacing => throw _privateConstructorUsedError;
  String? get thumbnailPath => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;

  /// Serializes this PageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageModelCopyWith<PageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageModelCopyWith<$Res> {
  factory $PageModelCopyWith(PageModel value, $Res Function(PageModel) then) =
      _$PageModelCopyWithImpl<$Res, PageModel>;
  @useResult
  $Res call({
    String id,
    String notebookId,
    int pageNumber,
    String templateType,
    String backgroundColor,
    double lineSpacing,
    String? thumbnailPath,
    DateTime createdAt,
    DateTime updatedAt,
    bool isSynced,
  });
}

/// @nodoc
class _$PageModelCopyWithImpl<$Res, $Val extends PageModel>
    implements $PageModelCopyWith<$Res> {
  _$PageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notebookId = null,
    Object? pageNumber = null,
    Object? templateType = null,
    Object? backgroundColor = null,
    Object? lineSpacing = null,
    Object? thumbnailPath = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isSynced = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            notebookId: null == notebookId
                ? _value.notebookId
                : notebookId // ignore: cast_nullable_to_non_nullable
                      as String,
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            templateType: null == templateType
                ? _value.templateType
                : templateType // ignore: cast_nullable_to_non_nullable
                      as String,
            backgroundColor: null == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String,
            lineSpacing: null == lineSpacing
                ? _value.lineSpacing
                : lineSpacing // ignore: cast_nullable_to_non_nullable
                      as double,
            thumbnailPath: freezed == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isSynced: null == isSynced
                ? _value.isSynced
                : isSynced // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageModelImplCopyWith<$Res>
    implements $PageModelCopyWith<$Res> {
  factory _$$PageModelImplCopyWith(
    _$PageModelImpl value,
    $Res Function(_$PageModelImpl) then,
  ) = __$$PageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String notebookId,
    int pageNumber,
    String templateType,
    String backgroundColor,
    double lineSpacing,
    String? thumbnailPath,
    DateTime createdAt,
    DateTime updatedAt,
    bool isSynced,
  });
}

/// @nodoc
class __$$PageModelImplCopyWithImpl<$Res>
    extends _$PageModelCopyWithImpl<$Res, _$PageModelImpl>
    implements _$$PageModelImplCopyWith<$Res> {
  __$$PageModelImplCopyWithImpl(
    _$PageModelImpl _value,
    $Res Function(_$PageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? notebookId = null,
    Object? pageNumber = null,
    Object? templateType = null,
    Object? backgroundColor = null,
    Object? lineSpacing = null,
    Object? thumbnailPath = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isSynced = null,
  }) {
    return _then(
      _$PageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        notebookId: null == notebookId
            ? _value.notebookId
            : notebookId // ignore: cast_nullable_to_non_nullable
                  as String,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        templateType: null == templateType
            ? _value.templateType
            : templateType // ignore: cast_nullable_to_non_nullable
                  as String,
        backgroundColor: null == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String,
        lineSpacing: null == lineSpacing
            ? _value.lineSpacing
            : lineSpacing // ignore: cast_nullable_to_non_nullable
                  as double,
        thumbnailPath: freezed == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isSynced: null == isSynced
            ? _value.isSynced
            : isSynced // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageModelImpl implements _PageModel {
  const _$PageModelImpl({
    required this.id,
    required this.notebookId,
    required this.pageNumber,
    this.templateType = 'blank',
    this.backgroundColor = '#FFFFFF',
    this.lineSpacing = 32.0,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  factory _$PageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String notebookId;
  @override
  final int pageNumber;
  @override
  @JsonKey()
  final String templateType;
  // 'blank' | 'lined' | 'grid' | 'dotted'
  @override
  @JsonKey()
  final String backgroundColor;
  @override
  @JsonKey()
  final double lineSpacing;
  @override
  final String? thumbnailPath;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isSynced;

  @override
  String toString() {
    return 'PageModel(id: $id, notebookId: $notebookId, pageNumber: $pageNumber, templateType: $templateType, backgroundColor: $backgroundColor, lineSpacing: $lineSpacing, thumbnailPath: $thumbnailPath, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.notebookId, notebookId) ||
                other.notebookId == notebookId) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.templateType, templateType) ||
                other.templateType == templateType) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.lineSpacing, lineSpacing) ||
                other.lineSpacing == lineSpacing) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    notebookId,
    pageNumber,
    templateType,
    backgroundColor,
    lineSpacing,
    thumbnailPath,
    createdAt,
    updatedAt,
    isSynced,
  );

  /// Create a copy of PageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageModelImplCopyWith<_$PageModelImpl> get copyWith =>
      __$$PageModelImplCopyWithImpl<_$PageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageModelImplToJson(this);
  }
}

abstract class _PageModel implements PageModel {
  const factory _PageModel({
    required final String id,
    required final String notebookId,
    required final int pageNumber,
    final String templateType,
    final String backgroundColor,
    final double lineSpacing,
    final String? thumbnailPath,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final bool isSynced,
  }) = _$PageModelImpl;

  factory _PageModel.fromJson(Map<String, dynamic> json) =
      _$PageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get notebookId;
  @override
  int get pageNumber;
  @override
  String get templateType; // 'blank' | 'lined' | 'grid' | 'dotted'
  @override
  String get backgroundColor;
  @override
  double get lineSpacing;
  @override
  String? get thumbnailPath;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isSynced;

  /// Create a copy of PageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageModelImplCopyWith<_$PageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
