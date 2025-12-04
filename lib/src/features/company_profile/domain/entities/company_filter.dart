/// Modelo para encapsular los filtros de búsqueda de empresas
class CompanyFilter {
  final String searchQuery;
  final String? industry;
  final String? coverageLevel;
  final List<String> coverageRegions;
  final List<String> coverageCommunes;
  final List<String> certifications;
  final int? minEmployees;
  final int? maxEmployees;
  final int? minFoundedYear;
  final int? maxFoundedYear;

  const CompanyFilter({
    this.searchQuery = '',
    this.industry,
    this.coverageLevel,
    this.coverageRegions = const [],
    this.coverageCommunes = const [],
    this.certifications = const [],
    this.minEmployees,
    this.maxEmployees,
    this.minFoundedYear,
    this.maxFoundedYear,
  });

  /// Crea una copia con nuevos valores
  CompanyFilter copyWith({
    String? searchQuery,
    String? industry,
    String? coverageLevel,
    List<String>? coverageRegions,
    List<String>? coverageCommunes,
    List<String>? certifications,
    int? minEmployees,
    int? maxEmployees,
    int? minFoundedYear,
    int? maxFoundedYear,
    bool clearIndustry = false,
    bool clearCoverageLevel = false,
    bool clearCoverageRegions = false,
    bool clearCoverageCommunes = false,
    bool clearCertifications = false,
    bool clearEmployeeRange = false,
    bool clearFoundedYearRange = false,
  }) {
    return CompanyFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      industry: clearIndustry ? null : (industry ?? this.industry),
      coverageLevel: clearCoverageLevel
          ? null
          : (coverageLevel ?? this.coverageLevel),
      coverageRegions: clearCoverageRegions
          ? const []
          : (coverageRegions ?? this.coverageRegions),
      coverageCommunes: clearCoverageCommunes
          ? const []
          : (coverageCommunes ?? this.coverageCommunes),
      certifications: clearCertifications
          ? const []
          : (certifications ?? this.certifications),
      minEmployees: clearEmployeeRange
          ? null
          : (minEmployees ?? this.minEmployees),
      maxEmployees: clearEmployeeRange
          ? null
          : (maxEmployees ?? this.maxEmployees),
      minFoundedYear: clearFoundedYearRange
          ? null
          : (minFoundedYear ?? this.minFoundedYear),
      maxFoundedYear: clearFoundedYearRange
          ? null
          : (maxFoundedYear ?? this.maxFoundedYear),
    );
  }

  /// Verifica si hay algún filtro activo (excluyendo búsqueda)
  bool get hasActiveFilters =>
      industry != null ||
      coverageLevel != null ||
      coverageRegions.isNotEmpty ||
      coverageCommunes.isNotEmpty ||
      certifications.isNotEmpty ||
      minEmployees != null ||
      maxEmployees != null ||
      minFoundedYear != null ||
      maxFoundedYear != null;

  /// Cuenta el número de filtros activos
  int get activeFilterCount {
    int count = 0;
    if (industry != null) count++;
    if (coverageLevel != null) count++;
    if (coverageRegions.isNotEmpty) count++;
    if (coverageCommunes.isNotEmpty) count++;
    if (certifications.isNotEmpty) count++;
    if (minEmployees != null || maxEmployees != null) count++;
    if (minFoundedYear != null || maxFoundedYear != null) count++;
    return count;
  }

  /// Limpia todos los filtros
  CompanyFilter clearAll() {
    return const CompanyFilter();
  }

  /// Limpia solo los filtros (mantiene búsqueda)
  CompanyFilter clearFilters() {
    return CompanyFilter(searchQuery: searchQuery);
  }
}
