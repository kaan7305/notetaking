// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Stroke _$StrokeFromJson(Map<String, dynamic> json) {
  return _Stroke.fromJson(json);
}

/// @nodoc
mixin _$Stroke {
  String get id => throw _privateConstructorUsedError;
  String get pageId => throw _privateConstructorUsedError;
  String get toolType =>
      throw _privateConstructorUsedError; // 'pen' | 'highlighter'
  String get color =>
      throw _privateConstructorUsedError; // hex string like '#FF0000'
  double get strokeWidth => throw _privateConstructorUsedError;
  List<StrokePoint> get points => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  /// Serializes this Stroke to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrokeCopyWith<Stroke> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrokeCopyWith<$Res> {
  factory $StrokeCopyWith(Stroke value, $Res Function(Stroke) then) =
      _$StrokeCopyWithImpl<$Res, Stroke>;
  @useResult
  $Res call({
    String id,
    String pageId,
    String toolType,
    String color,
    double strokeWidth,
    List<StrokePoint> points,
    DateTime createdAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$StrokeCopyWithImpl<$Res, $Val extends Stroke>
    implements $StrokeCopyWith<$Res> {
  _$StrokeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? toolType = null,
    Object? color = null,
    Object? strokeWidth = null,
    Object? points = null,
    Object? createdAt = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pageId: null == pageId
                ? _value.pageId
                : pageId // ignore: cast_nullable_to_non_nullable
                      as String,
            toolType: null == toolType
                ? _value.toolType
                : toolType // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            strokeWidth: null == strokeWidth
                ? _value.strokeWidth
                : strokeWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<StrokePoint>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isDeleted: null == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrokeImplCopyWith<$Res> implements $StrokeCopyWith<$Res> {
  factory _$$StrokeImplCopyWith(
    _$StrokeImpl value,
    $Res Function(_$StrokeImpl) then,
  ) = __$$StrokeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pageId,
    String toolType,
    String color,
    double strokeWidth,
    List<StrokePoint> points,
    DateTime createdAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$StrokeImplCopyWithImpl<$Res>
    extends _$StrokeCopyWithImpl<$Res, _$StrokeImpl>
    implements _$$StrokeImplCopyWith<$Res> {
  __$$StrokeImplCopyWithImpl(
    _$StrokeImpl _value,
    $Res Function(_$StrokeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? toolType = null,
    Object? color = null,
    Object? strokeWidth = null,
    Object? points = null,
    Object? createdAt = null,
    Object? isDeleted = null,
  }) {
    return _then(
      _$StrokeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pageId: null == pageId
            ? _value.pageId
            : pageId // ignore: cast_nullable_to_non_nullable
                  as String,
        toolType: null == toolType
            ? _value.toolType
            : toolType // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        strokeWidth: null == strokeWidth
            ? _value.strokeWidth
            : strokeWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<StrokePoint>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isDeleted: null == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrokeImpl implements _Stroke {
  const _$StrokeImpl({
    required this.id,
    required this.pageId,
    required this.toolType,
    required this.color,
    required this.strokeWidth,
    required final List<StrokePoint> points,
    required this.createdAt,
    this.isDeleted = false,
  }) : _points = points;

  factory _$StrokeImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrokeImplFromJson(json);

  @override
  final String id;
  @override
  final String pageId;
  @override
  final String toolType;
  // 'pen' | 'highlighter'
  @override
  final String color;
  // hex string like '#FF0000'
  @override
  final double strokeWidth;
  final List<StrokePoint> _points;
  @override
  List<StrokePoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'Stroke(id: $id, pageId: $pageId, toolType: $toolType, color: $color, strokeWidth: $strokeWidth, points: $points, createdAt: $createdAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrokeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.toolType, toolType) ||
                other.toolType == toolType) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.strokeWidth, strokeWidth) ||
                other.strokeWidth == strokeWidth) &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pageId,
    toolType,
    color,
    strokeWidth,
    const DeepCollectionEquality().hash(_points),
    createdAt,
    isDeleted,
  );

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrokeImplCopyWith<_$StrokeImpl> get copyWith =>
      __$$StrokeImplCopyWithImpl<_$StrokeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrokeImplToJson(this);
  }
}

abstract class _Stroke implements Stroke {
  const factory _Stroke({
    required final String id,
    required final String pageId,
    required final String toolType,
    required final String color,
    required final double strokeWidth,
    required final List<StrokePoint> points,
    required final DateTime createdAt,
    final bool isDeleted,
  }) = _$StrokeImpl;

  factory _Stroke.fromJson(Map<String, dynamic> json) = _$StrokeImpl.fromJson;

  @override
  String get id;
  @override
  String get pageId;
  @override
  String get toolType; // 'pen' | 'highlighter'
  @override
  String get color; // hex string like '#FF0000'
  @override
  double get strokeWidth;
  @override
  List<StrokePoint> get points;
  @override
  DateTime get createdAt;
  @override
  bool get isDeleted;

  /// Create a copy of Stroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrokeImplCopyWith<_$StrokeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
