// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ContactMessage _$ContactMessageFromJson(Map<String, dynamic> json) {
  return _ContactMessage.fromJson(json);
}

/// @nodoc
mixin _$ContactMessage {
  String get id => throw _privateConstructorUsedError;
  String get senderUserId => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String get senderEmail => throw _privateConstructorUsedError;
  String get recipientCompanyId => throw _privateConstructorUsedError;
  String get recipientCompanyName => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String? get productName => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ContactMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactMessageCopyWith<ContactMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactMessageCopyWith<$Res> {
  factory $ContactMessageCopyWith(
    ContactMessage value,
    $Res Function(ContactMessage) then,
  ) = _$ContactMessageCopyWithImpl<$Res, ContactMessage>;
  @useResult
  $Res call({
    String id,
    String senderUserId,
    String senderName,
    String senderEmail,
    String recipientCompanyId,
    String recipientCompanyName,
    String subject,
    String message,
    String? productId,
    String? productName,
    bool read,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ContactMessageCopyWithImpl<$Res, $Val extends ContactMessage>
    implements $ContactMessageCopyWith<$Res> {
  _$ContactMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderUserId = null,
    Object? senderName = null,
    Object? senderEmail = null,
    Object? recipientCompanyId = null,
    Object? recipientCompanyName = null,
    Object? subject = null,
    Object? message = null,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? read = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            senderUserId: null == senderUserId
                ? _value.senderUserId
                : senderUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderName: null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String,
            senderEmail: null == senderEmail
                ? _value.senderEmail
                : senderEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientCompanyId: null == recipientCompanyId
                ? _value.recipientCompanyId
                : recipientCompanyId // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientCompanyName: null == recipientCompanyName
                ? _value.recipientCompanyName
                : recipientCompanyName // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            productName: freezed == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String?,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContactMessageImplCopyWith<$Res>
    implements $ContactMessageCopyWith<$Res> {
  factory _$$ContactMessageImplCopyWith(
    _$ContactMessageImpl value,
    $Res Function(_$ContactMessageImpl) then,
  ) = __$$ContactMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderUserId,
    String senderName,
    String senderEmail,
    String recipientCompanyId,
    String recipientCompanyName,
    String subject,
    String message,
    String? productId,
    String? productName,
    bool read,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ContactMessageImplCopyWithImpl<$Res>
    extends _$ContactMessageCopyWithImpl<$Res, _$ContactMessageImpl>
    implements _$$ContactMessageImplCopyWith<$Res> {
  __$$ContactMessageImplCopyWithImpl(
    _$ContactMessageImpl _value,
    $Res Function(_$ContactMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderUserId = null,
    Object? senderName = null,
    Object? senderEmail = null,
    Object? recipientCompanyId = null,
    Object? recipientCompanyName = null,
    Object? subject = null,
    Object? message = null,
    Object? productId = freezed,
    Object? productName = freezed,
    Object? read = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ContactMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        senderUserId: null == senderUserId
            ? _value.senderUserId
            : senderUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderName: null == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String,
        senderEmail: null == senderEmail
            ? _value.senderEmail
            : senderEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientCompanyId: null == recipientCompanyId
            ? _value.recipientCompanyId
            : recipientCompanyId // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientCompanyName: null == recipientCompanyName
            ? _value.recipientCompanyName
            : recipientCompanyName // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        productName: freezed == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String?,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactMessageImpl implements _ContactMessage {
  const _$ContactMessageImpl({
    required this.id,
    required this.senderUserId,
    required this.senderName,
    required this.senderEmail,
    required this.recipientCompanyId,
    required this.recipientCompanyName,
    required this.subject,
    required this.message,
    this.productId,
    this.productName,
    this.read = false,
    this.createdAt,
  });

  factory _$ContactMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderUserId;
  @override
  final String senderName;
  @override
  final String senderEmail;
  @override
  final String recipientCompanyId;
  @override
  final String recipientCompanyName;
  @override
  final String subject;
  @override
  final String message;
  @override
  final String? productId;
  @override
  final String? productName;
  @override
  @JsonKey()
  final bool read;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ContactMessage(id: $id, senderUserId: $senderUserId, senderName: $senderName, senderEmail: $senderEmail, recipientCompanyId: $recipientCompanyId, recipientCompanyName: $recipientCompanyName, subject: $subject, message: $message, productId: $productId, productName: $productName, read: $read, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderUserId, senderUserId) ||
                other.senderUserId == senderUserId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderEmail, senderEmail) ||
                other.senderEmail == senderEmail) &&
            (identical(other.recipientCompanyId, recipientCompanyId) ||
                other.recipientCompanyId == recipientCompanyId) &&
            (identical(other.recipientCompanyName, recipientCompanyName) ||
                other.recipientCompanyName == recipientCompanyName) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderUserId,
    senderName,
    senderEmail,
    recipientCompanyId,
    recipientCompanyName,
    subject,
    message,
    productId,
    productName,
    read,
    createdAt,
  );

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactMessageImplCopyWith<_$ContactMessageImpl> get copyWith =>
      __$$ContactMessageImplCopyWithImpl<_$ContactMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactMessageImplToJson(this);
  }
}

abstract class _ContactMessage implements ContactMessage {
  const factory _ContactMessage({
    required final String id,
    required final String senderUserId,
    required final String senderName,
    required final String senderEmail,
    required final String recipientCompanyId,
    required final String recipientCompanyName,
    required final String subject,
    required final String message,
    final String? productId,
    final String? productName,
    final bool read,
    final DateTime? createdAt,
  }) = _$ContactMessageImpl;

  factory _ContactMessage.fromJson(Map<String, dynamic> json) =
      _$ContactMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderUserId;
  @override
  String get senderName;
  @override
  String get senderEmail;
  @override
  String get recipientCompanyId;
  @override
  String get recipientCompanyName;
  @override
  String get subject;
  @override
  String get message;
  @override
  String? get productId;
  @override
  String? get productName;
  @override
  bool get read;
  @override
  DateTime? get createdAt;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactMessageImplCopyWith<_$ContactMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
