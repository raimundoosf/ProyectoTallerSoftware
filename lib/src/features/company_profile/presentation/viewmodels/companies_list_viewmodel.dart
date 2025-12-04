import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_with_id.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_filter.dart';
import 'package:flutter_app/src/features/company_profile/domain/repositories/company_profile_repository.dart';

class CompaniesListViewModel extends ChangeNotifier {
  final CompanyProfileRepository _repository;

  CompaniesListViewModel(this._repository);

  List<CompanyWithId> _allCompanies = [];
  List<CompanyWithId> _filteredCompanies = [];
  bool _isLoading = false;
  String? _error;
  CompanyFilter _filter = const CompanyFilter();

  List<CompanyWithId> get companies => _filteredCompanies;
  List<CompanyWithId> get allCompanies => _allCompanies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CompanyFilter get filter => _filter;

  /// Carga todas las empresas
  Future<void> loadAllCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCompanies = await _repository.getAllCompanies();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar empresas: $e';
      _allCompanies = [];
      _filteredCompanies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aplica los filtros a la lista de empresas
  void _applyFilters() {
    _filteredCompanies = _allCompanies.where((companyWithId) {
      final company = companyWithId.profile;

      // Filtro por texto de búsqueda
      if (_filter.searchQuery.isNotEmpty) {
        final query = _filter.searchQuery.toLowerCase();
        final matchesName = company.companyName.toLowerCase().contains(query);
        final matchesIndustry = company.industry.toLowerCase().contains(query);
        final matchesDescription = company.companyDescription
            .toLowerCase()
            .contains(query);
        final matchesSpecialties = company.specialties.any(
          (spec) => spec.toLowerCase().contains(query),
        );

        if (!matchesName &&
            !matchesIndustry &&
            !matchesDescription &&
            !matchesSpecialties) {
          return false;
        }
      }

      // Filtro por industria
      if (_filter.industry != null && company.industry != _filter.industry) {
        return false;
      }

      // Filtro por nivel de cobertura
      if (_filter.coverageLevel != null &&
          company.coverageLevel != _filter.coverageLevel) {
        return false;
      }

      // Filtro por regiones
      if (_filter.coverageRegions.isNotEmpty) {
        final hasMatchingRegion = _filter.coverageRegions.any(
          (region) => company.coverageRegions.contains(region),
        );
        if (!hasMatchingRegion) return false;
      }

      // Filtro por comunas
      if (_filter.coverageCommunes.isNotEmpty) {
        final hasMatchingCommune = _filter.coverageCommunes.any(
          (commune) => company.coverageCommunes.contains(commune),
        );
        if (!hasMatchingCommune) return false;
      }

      // Filtro por certificaciones
      if (_filter.certifications.isNotEmpty) {
        final companyCertNames = company.certifications
            .map((cert) => cert['name']?.toLowerCase() ?? '')
            .toList();
        final hasMatchingCert = _filter.certifications.any(
          (cert) =>
              companyCertNames.any((name) => name.contains(cert.toLowerCase())),
        );
        if (!hasMatchingCert) return false;
      }

      // Filtro por rango de empleados
      if (_filter.minEmployees != null &&
          company.employeeCount < _filter.minEmployees!) {
        return false;
      }
      if (_filter.maxEmployees != null &&
          company.employeeCount > _filter.maxEmployees!) {
        return false;
      }

      // Filtro por año de fundación
      if (company.foundedYear > 0) {
        if (_filter.minFoundedYear != null &&
            company.foundedYear < _filter.minFoundedYear!) {
          return false;
        }
        if (_filter.maxFoundedYear != null &&
            company.foundedYear > _filter.maxFoundedYear!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Actualiza el texto de búsqueda
  void updateSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    _applyFilters();
    notifyListeners();
  }

  /// Actualiza el filtro completo
  void updateFilter(CompanyFilter newFilter) {
    _filter = newFilter;
    _applyFilters();
    notifyListeners();
  }

  /// Limpia todos los filtros
  void clearFilters() {
    _filter = _filter.clearFilters();
    _applyFilters();
    notifyListeners();
  }

  /// Limpia todo (búsqueda y filtros)
  void clearAll() {
    _filter = const CompanyFilter();
    _applyFilters();
    notifyListeners();
  }

  /// Obtiene las industrias disponibles
  List<String> getAvailableIndustries() {
    final Set<String> industries = {};
    for (final companyWithId in _allCompanies) {
      if (companyWithId.profile.industry.isNotEmpty) {
        industries.add(companyWithId.profile.industry);
      }
    }
    return industries.toList()..sort();
  }

  /// Refresca la lista de empresas
  Future<void> refresh() async {
    await loadAllCompanies();
  }
}
