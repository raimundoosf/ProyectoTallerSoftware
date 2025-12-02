// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Certification _$CertificationFromJson(Map<String, dynamic> json) {
  return _Certification.fromJson(json);
}

/// @nodoc
mixin _$Certification {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get issuer => throw _privateConstructorUsedError;
  DateTime? get issueDate => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  List<String> get documentUrls => throw _privateConstructorUsedError;
  List<String> get documentNames => throw _privateConstructorUsedError;
  CertificationType get type => throw _privateConstructorUsedError;
  VerificationStatus get status => throw _privateConstructorUsedError;
  String get verificationNotes => throw _privateConstructorUsedError;
  String get verifiedBy => throw _privateConstructorUsedError;
  DateTime? get verifiedDate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Certification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificationCopyWith<Certification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificationCopyWith<$Res> {
  factory $CertificationCopyWith(
    Certification value,
    $Res Function(Certification) then,
  ) = _$CertificationCopyWithImpl<$Res, Certification>;
  @useResult
  $Res call({
    String id,
    String name,
    String issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    List<String> documentUrls,
    List<String> documentNames,
    CertificationType type,
    VerificationStatus status,
    String verificationNotes,
    String verifiedBy,
    DateTime? verifiedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$CertificationCopyWithImpl<$Res, $Val extends Certification>
    implements $CertificationCopyWith<$Res> {
  _$CertificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? issuer = null,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? documentUrls = null,
    Object? documentNames = null,
    Object? type = null,
    Object? status = null,
    Object? verificationNotes = null,
    Object? verifiedBy = null,
    Object? verifiedDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            issuer: null == issuer
                ? _value.issuer
                : issuer // ignore: cast_nullable_to_non_nullable
                      as String,
            issueDate: freezed == issueDate
                ? _value.issueDate
                : issueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            documentUrls: null == documentUrls
                ? _value.documentUrls
                : documentUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            documentNames: null == documentNames
                ? _value.documentNames
                : documentNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CertificationType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as VerificationStatus,
            verificationNotes: null == verificationNotes
                ? _value.verificationNotes
                : verificationNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            verifiedBy: null == verifiedBy
                ? _value.verifiedBy
                : verifiedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            verifiedDate: freezed == verifiedDate
                ? _value.verifiedDate
                : verifiedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificationImplCopyWith<$Res>
    implements $CertificationCopyWith<$Res> {
  factory _$$CertificationImplCopyWith(
    _$CertificationImpl value,
    $Res Function(_$CertificationImpl) then,
  ) = __$$CertificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    List<String> documentUrls,
    List<String> documentNames,
    CertificationType type,
    VerificationStatus status,
    String verificationNotes,
    String verifiedBy,
    DateTime? verifiedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CertificationImplCopyWithImpl<$Res>
    extends _$CertificationCopyWithImpl<$Res, _$CertificationImpl>
    implements _$$CertificationImplCopyWith<$Res> {
  __$$CertificationImplCopyWithImpl(
    _$CertificationImpl _value,
    $Res Function(_$CertificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? issuer = null,
    Object? issueDate = freezed,
    Object? expiryDate = freezed,
    Object? documentUrls = null,
    Object? documentNames = null,
    Object? type = null,
    Object? status = null,
    Object? verificationNotes = null,
    Object? verifiedBy = null,
    Object? verifiedDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CertificationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        issuer: null == issuer
            ? _value.issuer
            : issuer // ignore: cast_nullable_to_non_nullable
                  as String,
        issueDate: freezed == issueDate
            ? _value.issueDate
            : issueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        documentUrls: null == documentUrls
            ? _value._documentUrls
            : documentUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        documentNames: null == documentNames
            ? _value._documentNames
            : documentNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CertificationType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as VerificationStatus,
        verificationNotes: null == verificationNotes
            ? _value.verificationNotes
            : verificationNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        verifiedBy: null == verifiedBy
            ? _value.verifiedBy
            : verifiedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        verifiedDate: freezed == verifiedDate
            ? _value.verifiedDate
            : verifiedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificationImpl implements _Certification {
  const _$CertificationImpl({
    required this.id,
    required this.name,
    this.issuer = '',
    this.issueDate,
    this.expiryDate,
    final List<String> documentUrls = const [],
    final List<String> documentNames = const [],
    this.type = CertificationType.other,
    this.status = VerificationStatus.pending,
    this.verificationNotes = '',
    this.verifiedBy = '',
    this.verifiedDate,
    this.createdAt,
    this.updatedAt,
  }) : _documentUrls = documentUrls,
       _documentNames = documentNames;

  factory _$CertificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String issuer;
  @override
  final DateTime? issueDate;
  @override
  final DateTime? expiryDate;
  final List<String> _documentUrls;
  @override
  @JsonKey()
  List<String> get documentUrls {
    if (_documentUrls is EqualUnmodifiableListView) return _documentUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documentUrls);
  }

  final List<String> _documentNames;
  @override
  @JsonKey()
  List<String> get documentNames {
    if (_documentNames is EqualUnmodifiableListView) return _documentNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documentNames);
  }

  @override
  @JsonKey()
  final CertificationType type;
  @override
  @JsonKey()
  final VerificationStatus status;
  @override
  @JsonKey()
  final String verificationNotes;
  @override
  @JsonKey()
  final String verifiedBy;
  @override
  final DateTime? verifiedDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Certification(id: $id, name: $name, issuer: $issuer, issueDate: $issueDate, expiryDate: $expiryDate, documentUrls: $documentUrls, documentNames: $documentNames, type: $type, status: $status, verificationNotes: $verificationNotes, verifiedBy: $verifiedBy, verifiedDate: $verifiedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.issuer, issuer) || other.issuer == issuer) &&
            (identical(other.issueDate, issueDate) ||
                other.issueDate == issueDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            const DeepCollectionEquality().equals(
              other._documentUrls,
              _documentUrls,
            ) &&
            const DeepCollectionEquality().equals(
              other._documentNames,
              _documentNames,
            ) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.verificationNotes, verificationNotes) ||
                other.verificationNotes == verificationNotes) &&
            (identical(other.verifiedBy, verifiedBy) ||
                other.verifiedBy == verifiedBy) &&
            (identical(other.verifiedDate, verifiedDate) ||
                other.verifiedDate == verifiedDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    issuer,
    issueDate,
    expiryDate,
    const DeepCollectionEquality().hash(_documentUrls),
    const DeepCollectionEquality().hash(_documentNames),
    type,
    status,
    verificationNotes,
    verifiedBy,
    verifiedDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      __$$CertificationImplCopyWithImpl<_$CertificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificationImplToJson(this);
  }
}

abstract class _Certification implements Certification {
  const factory _Certification({
    required final String id,
    required final String name,
    final String issuer,
    final DateTime? issueDate,
    final DateTime? expiryDate,
    final List<String> documentUrls,
    final List<String> documentNames,
    final CertificationType type,
    final VerificationStatus status,
    final String verificationNotes,
    final String verifiedBy,
    final DateTime? verifiedDate,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$CertificationImpl;

  factory _Certification.fromJson(Map<String, dynamic> json) =
      _$CertificationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get issuer;
  @override
  DateTime? get issueDate;
  @override
  DateTime? get expiryDate;
  @override
  List<String> get documentUrls;
  @override
  List<String> get documentNames;
  @override
  CertificationType get type;
  @override
  VerificationStatus get status;
  @override
  String get verificationNotes;
  @override
  String get verifiedBy;
  @override
  DateTime? get verifiedDate;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
