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
  String get companyDescription => throw _privateConstructorUsedError;
  String get website => throw _privateConstructorUsedError;
  String get logoUrl =>
      throw _privateConstructorUsedError; // Certificaciones con documentos de respaldo: [{name, documentUrl, documentName}]
  List<Map<String, String>> get certifications =>
      throw _privateConstructorUsedError; // Sistema de cobertura geográfica
  String get coverageLevel =>
      throw _privateConstructorUsedError; // 'Nacional', 'Regional', 'Comunal'
  List<String> get coverageRegions =>
      throw _privateConstructorUsedError; // Regiones seleccionadas si es Regional
  List<String> get coverageCommunes =>
      throw _privateConstructorUsedError; // Comunas seleccionadas si es Comunal
  // Campos para información profesional
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get rut => throw _privateConstructorUsedError;
  int get foundedYear => throw _privateConstructorUsedError;
  int get employeeCount => throw _privateConstructorUsedError;
  List<String> get specialties => throw _privateConstructorUsedError;
  String get missionStatement => throw _privateConstructorUsedError;
  String get visionStatement => throw _privateConstructorUsedError;
  List<Map<String, String>> get socialMedia =>
      throw _privateConstructorUsedError;

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
    String companyDescription,
    String website,
    String logoUrl,
    List<Map<String, String>> certifications,
    String coverageLevel,
    List<String> coverageRegions,
    List<String> coverageCommunes,
    String email,
    String phone,
    String address,
    String rut,
    int foundedYear,
    int employeeCount,
    List<String> specialties,
    String missionStatement,
    String visionStatement,
    List<Map<String, String>> socialMedia,
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
    Object? companyDescription = null,
    Object? website = null,
    Object? logoUrl = null,
    Object? certifications = null,
    Object? coverageLevel = null,
    Object? coverageRegions = null,
    Object? coverageCommunes = null,
    Object? email = null,
    Object? phone = null,
    Object? address = null,
    Object? rut = null,
    Object? foundedYear = null,
    Object? employeeCount = null,
    Object? specialties = null,
    Object? missionStatement = null,
    Object? visionStatement = null,
    Object? socialMedia = null,
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
                      as List<Map<String, String>>,
            coverageLevel: null == coverageLevel
                ? _value.coverageLevel
                : coverageLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            coverageRegions: null == coverageRegions
                ? _value.coverageRegions
                : coverageRegions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            coverageCommunes: null == coverageCommunes
                ? _value.coverageCommunes
                : coverageCommunes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            rut: null == rut
                ? _value.rut
                : rut // ignore: cast_nullable_to_non_nullable
                      as String,
            foundedYear: null == foundedYear
                ? _value.foundedYear
                : foundedYear // ignore: cast_nullable_to_non_nullable
                      as int,
            employeeCount: null == employeeCount
                ? _value.employeeCount
                : employeeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            specialties: null == specialties
                ? _value.specialties
                : specialties // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            missionStatement: null == missionStatement
                ? _value.missionStatement
                : missionStatement // ignore: cast_nullable_to_non_nullable
                      as String,
            visionStatement: null == visionStatement
                ? _value.visionStatement
                : visionStatement // ignore: cast_nullable_to_non_nullable
                      as String,
            socialMedia: null == socialMedia
                ? _value.socialMedia
                : socialMedia // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, String>>,
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
    String companyDescription,
    String website,
    String logoUrl,
    List<Map<String, String>> certifications,
    String coverageLevel,
    List<String> coverageRegions,
    List<String> coverageCommunes,
    String email,
    String phone,
    String address,
    String rut,
    int foundedYear,
    int employeeCount,
    List<String> specialties,
    String missionStatement,
    String visionStatement,
    List<Map<String, String>> socialMedia,
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
    Object? companyDescription = null,
    Object? website = null,
    Object? logoUrl = null,
    Object? certifications = null,
    Object? coverageLevel = null,
    Object? coverageRegions = null,
    Object? coverageCommunes = null,
    Object? email = null,
    Object? phone = null,
    Object? address = null,
    Object? rut = null,
    Object? foundedYear = null,
    Object? employeeCount = null,
    Object? specialties = null,
    Object? missionStatement = null,
    Object? visionStatement = null,
    Object? socialMedia = null,
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
                  as List<Map<String, String>>,
        coverageLevel: null == coverageLevel
            ? _value.coverageLevel
            : coverageLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        coverageRegions: null == coverageRegions
            ? _value._coverageRegions
            : coverageRegions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        coverageCommunes: null == coverageCommunes
            ? _value._coverageCommunes
            : coverageCommunes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        rut: null == rut
            ? _value.rut
            : rut // ignore: cast_nullable_to_non_nullable
                  as String,
        foundedYear: null == foundedYear
            ? _value.foundedYear
            : foundedYear // ignore: cast_nullable_to_non_nullable
                  as int,
        employeeCount: null == employeeCount
            ? _value.employeeCount
            : employeeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        specialties: null == specialties
            ? _value._specialties
            : specialties // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        missionStatement: null == missionStatement
            ? _value.missionStatement
            : missionStatement // ignore: cast_nullable_to_non_nullable
                  as String,
        visionStatement: null == visionStatement
            ? _value.visionStatement
            : visionStatement // ignore: cast_nullable_to_non_nullable
                  as String,
        socialMedia: null == socialMedia
            ? _value._socialMedia
            : socialMedia // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, String>>,
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
    required this.companyDescription,
    required this.website,
    this.logoUrl = '',
    final List<Map<String, String>> certifications = const [],
    this.coverageLevel = 'Nacional',
    final List<String> coverageRegions = const [],
    final List<String> coverageCommunes = const [],
    this.email = '',
    this.phone = '',
    this.address = '',
    this.rut = '',
    this.foundedYear = 0,
    this.employeeCount = 0,
    final List<String> specialties = const [],
    this.missionStatement = '',
    this.visionStatement = '',
    final List<Map<String, String>> socialMedia = const [],
  }) : _certifications = certifications,
       _coverageRegions = coverageRegions,
       _coverageCommunes = coverageCommunes,
       _specialties = specialties,
       _socialMedia = socialMedia;

  factory _$CompanyProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyProfileImplFromJson(json);

  @override
  final String companyName;
  @override
  final String industry;
  @override
  final String companyDescription;
  @override
  final String website;
  @override
  @JsonKey()
  final String logoUrl;
  // Certificaciones con documentos de respaldo: [{name, documentUrl, documentName}]
  final List<Map<String, String>> _certifications;
  // Certificaciones con documentos de respaldo: [{name, documentUrl, documentName}]
  @override
  @JsonKey()
  List<Map<String, String>> get certifications {
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certifications);
  }

  // Sistema de cobertura geográfica
  @override
  @JsonKey()
  final String coverageLevel;
  // 'Nacional', 'Regional', 'Comunal'
  final List<String> _coverageRegions;
  // 'Nacional', 'Regional', 'Comunal'
  @override
  @JsonKey()
  List<String> get coverageRegions {
    if (_coverageRegions is EqualUnmodifiableListView) return _coverageRegions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coverageRegions);
  }

  // Regiones seleccionadas si es Regional
  final List<String> _coverageCommunes;
  // Regiones seleccionadas si es Regional
  @override
  @JsonKey()
  List<String> get coverageCommunes {
    if (_coverageCommunes is EqualUnmodifiableListView)
      return _coverageCommunes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coverageCommunes);
  }

  // Comunas seleccionadas si es Comunal
  // Campos para información profesional
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String rut;
  @override
  @JsonKey()
  final int foundedYear;
  @override
  @JsonKey()
  final int employeeCount;
  final List<String> _specialties;
  @override
  @JsonKey()
  List<String> get specialties {
    if (_specialties is EqualUnmodifiableListView) return _specialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialties);
  }

  @override
  @JsonKey()
  final String missionStatement;
  @override
  @JsonKey()
  final String visionStatement;
  final List<Map<String, String>> _socialMedia;
  @override
  @JsonKey()
  List<Map<String, String>> get socialMedia {
    if (_socialMedia is EqualUnmodifiableListView) return _socialMedia;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_socialMedia);
  }

  @override
  String toString() {
    return 'CompanyProfile(companyName: $companyName, industry: $industry, companyDescription: $companyDescription, website: $website, logoUrl: $logoUrl, certifications: $certifications, coverageLevel: $coverageLevel, coverageRegions: $coverageRegions, coverageCommunes: $coverageCommunes, email: $email, phone: $phone, address: $address, rut: $rut, foundedYear: $foundedYear, employeeCount: $employeeCount, specialties: $specialties, missionStatement: $missionStatement, visionStatement: $visionStatement, socialMedia: $socialMedia)';
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
            (identical(other.companyDescription, companyDescription) ||
                other.companyDescription == companyDescription) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            const DeepCollectionEquality().equals(
              other._certifications,
              _certifications,
            ) &&
            (identical(other.coverageLevel, coverageLevel) ||
                other.coverageLevel == coverageLevel) &&
            const DeepCollectionEquality().equals(
              other._coverageRegions,
              _coverageRegions,
            ) &&
            const DeepCollectionEquality().equals(
              other._coverageCommunes,
              _coverageCommunes,
            ) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.rut, rut) || other.rut == rut) &&
            (identical(other.foundedYear, foundedYear) ||
                other.foundedYear == foundedYear) &&
            (identical(other.employeeCount, employeeCount) ||
                other.employeeCount == employeeCount) &&
            const DeepCollectionEquality().equals(
              other._specialties,
              _specialties,
            ) &&
            (identical(other.missionStatement, missionStatement) ||
                other.missionStatement == missionStatement) &&
            (identical(other.visionStatement, visionStatement) ||
                other.visionStatement == visionStatement) &&
            const DeepCollectionEquality().equals(
              other._socialMedia,
              _socialMedia,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    companyName,
    industry,
    companyDescription,
    website,
    logoUrl,
    const DeepCollectionEquality().hash(_certifications),
    coverageLevel,
    const DeepCollectionEquality().hash(_coverageRegions),
    const DeepCollectionEquality().hash(_coverageCommunes),
    email,
    phone,
    address,
    rut,
    foundedYear,
    employeeCount,
    const DeepCollectionEquality().hash(_specialties),
    missionStatement,
    visionStatement,
    const DeepCollectionEquality().hash(_socialMedia),
  ]);

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
    required final String companyDescription,
    required final String website,
    final String logoUrl,
    final List<Map<String, String>> certifications,
    final String coverageLevel,
    final List<String> coverageRegions,
    final List<String> coverageCommunes,
    final String email,
    final String phone,
    final String address,
    final String rut,
    final int foundedYear,
    final int employeeCount,
    final List<String> specialties,
    final String missionStatement,
    final String visionStatement,
    final List<Map<String, String>> socialMedia,
  }) = _$CompanyProfileImpl;

  factory _CompanyProfile.fromJson(Map<String, dynamic> json) =
      _$CompanyProfileImpl.fromJson;

  @override
  String get companyName;
  @override
  String get industry;
  @override
  String get companyDescription;
  @override
  String get website;
  @override
  String get logoUrl; // Certificaciones con documentos de respaldo: [{name, documentUrl, documentName}]
  @override
  List<Map<String, String>> get certifications; // Sistema de cobertura geográfica
  @override
  String get coverageLevel; // 'Nacional', 'Regional', 'Comunal'
  @override
  List<String> get coverageRegions; // Regiones seleccionadas si es Regional
  @override
  List<String> get coverageCommunes; // Comunas seleccionadas si es Comunal
  // Campos para información profesional
  @override
  String get email;
  @override
  String get phone;
  @override
  String get address;
  @override
  String get rut;
  @override
  int get foundedYear;
  @override
  int get employeeCount;
  @override
  List<String> get specialties;
  @override
  String get missionStatement;
  @override
  String get visionStatement;
  @override
  List<Map<String, String>> get socialMedia;

  /// Create a copy of CompanyProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyProfileImplCopyWith<_$CompanyProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
