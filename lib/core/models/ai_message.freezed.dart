// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AiMessage _$AiMessageFromJson(Map<String, dynamic> json) {
  return _AiMessage.fromJson(json);
}

/// @nodoc
mixin _$AiMessage {
  String get id => throw _privateConstructorUsedError;
  String get courseId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError; // 'user' | 'assistant'
  String get content => throw _privateConstructorUsedError;
  String? get imageBase64 =>
      throw _privateConstructorUsedError; // for user messages with canvas selection
  String get mode =>
      throw _privateConstructorUsedError; // 'hint' | 'check' | 'solve'
  List<SourceReference> get references => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AiMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiMessageCopyWith<AiMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiMessageCopyWith<$Res> {
  factory $AiMessageCopyWith(AiMessage value, $Res Function(AiMessage) then) =
      _$AiMessageCopyWithImpl<$Res, AiMessage>;
  @useResult
  $Res call({
    String id,
    String courseId,
    String role,
    String content,
    String? imageBase64,
    String mode,
    List<SourceReference> references,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AiMessageCopyWithImpl<$Res, $Val extends AiMessage>
    implements $AiMessageCopyWith<$Res> {
  _$AiMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? role = null,
    Object? content = null,
    Object? imageBase64 = freezed,
    Object? mode = null,
    Object? references = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            courseId: null == courseId
                ? _value.courseId
                : courseId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            imageBase64: freezed == imageBase64
                ? _value.imageBase64
                : imageBase64 // ignore: cast_nullable_to_non_nullable
                      as String?,
            mode: null == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String,
            references: null == references
                ? _value.references
                : references // ignore: cast_nullable_to_non_nullable
                      as List<SourceReference>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiMessageImplCopyWith<$Res>
    implements $AiMessageCopyWith<$Res> {
  factory _$$AiMessageImplCopyWith(
    _$AiMessageImpl value,
    $Res Function(_$AiMessageImpl) then,
  ) = __$$AiMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String courseId,
    String role,
    String content,
    String? imageBase64,
    String mode,
    List<SourceReference> references,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AiMessageImplCopyWithImpl<$Res>
    extends _$AiMessageCopyWithImpl<$Res, _$AiMessageImpl>
    implements _$$AiMessageImplCopyWith<$Res> {
  __$$AiMessageImplCopyWithImpl(
    _$AiMessageImpl _value,
    $Res Function(_$AiMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? role = null,
    Object? content = null,
    Object? imageBase64 = freezed,
    Object? mode = null,
    Object? references = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AiMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        courseId: null == courseId
            ? _value.courseId
            : courseId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        imageBase64: freezed == imageBase64
            ? _value.imageBase64
            : imageBase64 // ignore: cast_nullable_to_non_nullable
                  as String?,
        mode: null == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String,
        references: null == references
            ? _value._references
            : references // ignore: cast_nullable_to_non_nullable
                  as List<SourceReference>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiMessageImpl implements _AiMessage {
  const _$AiMessageImpl({
    required this.id,
    required this.courseId,
    required this.role,
    required this.content,
    this.imageBase64,
    required this.mode,
    final List<SourceReference> references = const [],
    required this.createdAt,
  }) : _references = references;

  factory _$AiMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String courseId;
  @override
  final String role;
  // 'user' | 'assistant'
  @override
  final String content;
  @override
  final String? imageBase64;
  // for user messages with canvas selection
  @override
  final String mode;
  // 'hint' | 'check' | 'solve'
  final List<SourceReference> _references;
  // 'hint' | 'check' | 'solve'
  @override
  @JsonKey()
  List<SourceReference> get references {
    if (_references is EqualUnmodifiableListView) return _references;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_references);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AiMessage(id: $id, courseId: $courseId, role: $role, content: $content, imageBase64: $imageBase64, mode: $mode, references: $references, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            const DeepCollectionEquality().equals(
              other._references,
              _references,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    courseId,
    role,
    content,
    imageBase64,
    mode,
    const DeepCollectionEquality().hash(_references),
    createdAt,
  );

  /// Create a copy of AiMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiMessageImplCopyWith<_$AiMessageImpl> get copyWith =>
      __$$AiMessageImplCopyWithImpl<_$AiMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiMessageImplToJson(this);
  }
}

abstract class _AiMessage implements AiMessage {
  const factory _AiMessage({
    required final String id,
    required final String courseId,
    required final String role,
    required final String content,
    final String? imageBase64,
    required final String mode,
    final List<SourceReference> references,
    required final DateTime createdAt,
  }) = _$AiMessageImpl;

  factory _AiMessage.fromJson(Map<String, dynamic> json) =
      _$AiMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get courseId;
  @override
  String get role; // 'user' | 'assistant'
  @override
  String get content;
  @override
  String? get imageBase64; // for user messages with canvas selection
  @override
  String get mode; // 'hint' | 'check' | 'solve'
  @override
  List<SourceReference> get references;
  @override
  DateTime get createdAt;

  /// Create a copy of AiMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiMessageImplCopyWith<_$AiMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
