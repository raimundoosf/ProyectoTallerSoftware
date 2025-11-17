// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CompanyProfile _$CompanyProfileFromJson(Map<String, dynamic> json) {
  return _CompanyProfile.fromJson(json);
}

/// @nodoc
mixin _$CompanyProfile {
  String get companyName => throw _privateConstructorUsedError;
  String get industry => throw _privateConstructorUsedError;
  String get companyLocation => throw _privateConstructorUsedError;
  String get companyDescription => throw _privateConstructorUsedError;
  String get website => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;
  List<String> get certifications => throw _privateConstructorUsedError;

  /// Serializes this CompanyProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyProfileCopyWith<CompanyProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyProfileCopyWith<$Res> {
  factory $CompanyProfileCopyWith(
    CompanyProfile value,
    $Res Function(CompanyProfile) then,
  ) = _$CompanyProfileCopyWithImpl<$Res, CompanyProfile>;
  @useResult
  $Res call({
    String companyName,
    String industry,
    String companyLocation,
    String companyDescription,
    String website,
    String logoUrl,
    List<String> certifications,
  });
}

/// @nodoc
class _$CompanyProfileCopyWithImpl<$Res, $Val extends CompanyProfile>
    implements $CompanyProfileCopyWith<$Res> {
  _$CompanyProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = null,
    Object? industry = null,
    Object? companyLocation = null,
    Object? companyDescription = null,
    Object? website = null,
    Object? logoUrl = null,
    Object? certifications = null,
  }) {
    return _then(
      _value.copyWith(
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            industry: null == industry
                ? _value.industry
                : industry // ignore: cast_nullable_to_non_nullable
                      as String,
            companyLocation: null == companyLocation
                ? _value.companyLocation
                : companyLocation // ignore: cast_nullable_to_non_nullable
                      as String,
            companyDescription: null == companyDescription
                ? _value.companyDescription
                : companyDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            website: null == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String,
            logoUrl: null == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            certifications: null == certifications
                ? _value.certifications
                : certifications // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyProfileImplCopyWith<$Res>
    implements $CompanyProfileCopyWith<$Res> {
  factory _$$CompanyProfileImplCopyWith(
    _$CompanyProfileImpl value,
    $Res Function(_$CompanyProfileImpl) then,
  ) = __$$CompanyProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String companyName,
    String industry,
    String companyLocation,
    String companyDescription,
    String website,
    String logoUrl,
    List<String> certifications,
  });
}

/// @nodoc
class __$$CompanyProfileImplCopyWithImpl<$Res>
    extends _$CompanyProfileCopyWithImpl<$Res, _$CompanyProfileImpl>
    implements _$$CompanyProfileImplCopyWith<$Res> {
  __$$CompanyProfileImplCopyWithImpl(
    _$CompanyProfileImpl _value,
    $Res Function(_$CompanyProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? companyName = null,
    Object? industry = null,
    Object? companyLocation = null,
    Object? companyDescription = null,
    Object? website = null,
    Object? logoUrl = null,
    Object? certifications = null,
  }) {
    return _then(
      _$CompanyProfileImpl(
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        industry: null == industry
            ? _value.industry
            : industry // ignore: cast_nullable_to_non_nullable
                  as String,
        companyLocation: null == companyLocation
            ? _value.companyLocation
            : companyLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        companyDescription: null == companyDescription
            ? _value.companyDescription
            : companyDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        website: null == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String,
        logoUrl: null == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        certifications: null == certifications
            ? _value._certifications
            : certifications // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyProfileImpl implements _CompanyProfile {
  const _$CompanyProfileImpl({
    required this.companyName,
    required this.industry,
    required this.companyLocation,
    required this.companyDescription,
    required this.website,
    this.logoUrl = '',
    final List<String> certifications = const [],
  }) : _certifications = certifications;

  factory _$CompanyProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyProfileImplFromJson(json);

  @override
  final String companyName;
  @override
  final String industry;
  @override
  final String companyLocation;
  @override
  final String companyDescription;
  @override
  final String website;
  @override
  @JsonKey()
  final String logoUrl;
  final List<String> _certifications;
  @override
  @JsonKey()
  List<String> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  @override
  String toString() {
    return 'CompanyProfile(companyName: $companyName, industry: $industry, companyLocation: $companyLocation, companyDescription: $companyDescription, website: $website, logoUrl: $logoUrl, certifications: $certifications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyProfileImpl &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.industry, industry) ||
                other.industry == industry) &&
            (identical(other.companyLocation, companyLocation) ||
                other.companyLocation == companyLocation) &&
            (identical(other.companyDescription, companyDescription) ||
                other.companyDescription == companyDescription) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    companyName,
    industry,
    companyLocation,
    companyDescription,
    website,
    logoUrl,
    const DeepCollectionEquality().hash(_certifications),
  );

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyProfileImplCopyWith<_$CompanyProfileImpl> get copyWith =>
      __$$CompanyProfileImplCopyWithImpl<_$CompanyProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyProfileImplToJson(this);
  }
}

abstract class _CompanyProfile implements CompanyProfile {
  const factory _CompanyProfile({
    required final String companyName,
    required final String industry,
    required final String companyLocation,
    required final String companyDescription,
    required final String website,
    final String logoUrl,
    final List<String> certifications,
  }) = _$CompanyProfileImpl;

  factory _CompanyProfile.fromJson(Map<String, dynamic> json) =
      _$CompanyProfileImpl.fromJson;

  @override
  String get companyName;
  @override
  String get industry;
  @override
  String get companyLocation;
  @override
  String get companyDescription;
  @override
  String get website;
  @override
  String get logoUrl;
  @override
  List<String> get certifications;

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyProfileImplCopyWith<_$CompanyProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
