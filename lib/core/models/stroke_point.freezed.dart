// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stroke_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StrokePoint _$StrokePointFromJson(Map<String, dynamic> json) {
  return _StrokePoint.fromJson(json);
}

/// @nodoc
mixin _$StrokePoint {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get pressure => throw _privateConstructorUsedError;
  double get tilt => throw _privateConstructorUsedError;
  int get timestamp => throw _privateConstructorUsedError;

  /// Serializes this StrokePoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrokePointCopyWith<StrokePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrokePointCopyWith<$Res> {
  factory $StrokePointCopyWith(
    StrokePoint value,
    $Res Function(StrokePoint) then,
  ) = _$StrokePointCopyWithImpl<$Res, StrokePoint>;
  @useResult
  $Res call({double x, double y, double pressure, double tilt, int timestamp});
}

/// @nodoc
class _$StrokePointCopyWithImpl<$Res, $Val extends StrokePoint>
    implements $StrokePointCopyWith<$Res> {
  _$StrokePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? pressure = null,
    Object? tilt = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            pressure: null == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as double,
            tilt: null == tilt
                ? _value.tilt
                : tilt // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrokePointImplCopyWith<$Res>
    implements $StrokePointCopyWith<$Res> {
  factory _$$StrokePointImplCopyWith(
    _$StrokePointImpl value,
    $Res Function(_$StrokePointImpl) then,
  ) = __$$StrokePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double pressure, double tilt, int timestamp});
}

/// @nodoc
class __$$StrokePointImplCopyWithImpl<$Res>
    extends _$StrokePointCopyWithImpl<$Res, _$StrokePointImpl>
    implements _$$StrokePointImplCopyWith<$Res> {
  __$$StrokePointImplCopyWithImpl(
    _$StrokePointImpl _value,
    $Res Function(_$StrokePointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? pressure = null,
    Object? tilt = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$StrokePointImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        pressure: null == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as double,
        tilt: null == tilt
            ? _value.tilt
            : tilt // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrokePointImpl implements _StrokePoint {
  const _$StrokePointImpl({
    required this.x,
    required this.y,
    required this.pressure,
    this.tilt = 0.0,
    required this.timestamp,
  });

  factory _$StrokePointImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrokePointImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double pressure;
  @override
  @JsonKey()
  final double tilt;
  @override
  final int timestamp;

  @override
  String toString() {
    return 'StrokePoint(x: $x, y: $y, pressure: $pressure, tilt: $tilt, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrokePointImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.tilt, tilt) || other.tilt == tilt) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, pressure, tilt, timestamp);

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrokePointImplCopyWith<_$StrokePointImpl> get copyWith =>
      __$$StrokePointImplCopyWithImpl<_$StrokePointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrokePointImplToJson(this);
  }
}

abstract class _StrokePoint implements StrokePoint {
  const factory _StrokePoint({
    required final double x,
    required final double y,
    required final double pressure,
    final double tilt,
    required final int timestamp,
  }) = _$StrokePointImpl;

  factory _StrokePoint.fromJson(Map<String, dynamic> json) =
      _$StrokePointImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get pressure;
  @override
  double get tilt;
  @override
  int get timestamp;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrokePointImplCopyWith<_$StrokePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
