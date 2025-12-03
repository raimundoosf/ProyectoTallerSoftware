import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/company_profile/domain/constants/business_constants.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_filter.dart';
import 'package:flutter_app/src/core/config/certifications.dart';

class CompanyFilterSheet extends StatefulWidget {
  final CompanyFilter initialFilter;
  final List<String> availableIndustries;

  const CompanyFilterSheet({
    super.key,
    required this.initialFilter,
    required this.availableIndustries,
  });

  @override
  State<CompanyFilterSheet> createState() => _CompanyFilterSheetState();
}

class _CompanyFilterSheetState extends State<CompanyFilterSheet> {
  late CompanyFilter _filter;
  final _minEmployeesController = TextEditingController();
  final _maxEmployeesController = TextEditingController();
  final _minYearController = TextEditingController();
  final _maxYearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    if (_filter.minEmployees != null) {
      _minEmployeesController.text = _filter.minEmployees.toString();
    }
    if (_filter.maxEmployees != null) {
      _maxEmployeesController.text = _filter.maxEmployees.toString();
    }
    if (_filter.minFoundedYear != null) {
      _minYearController.text = _filter.minFoundedYear.toString();
    }
    if (_filter.maxFoundedYear != null) {
      _maxYearController.text = _filter.maxFoundedYear.toString();
    }
  }

  @override
  void dispose() {
    _minEmployeesController.dispose();
    _maxEmployeesController.dispose();
    _minYearController.dispose();
    _maxYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (_filter.hasActiveFilters)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filter = _filter.clearFilters();
                            _minEmployeesController.clear();
                            _maxEmployeesController.clear();
                            _minYearController.clear();
                            _maxYearController.clear();
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Industria
                  _buildSectionTitle(theme, 'Industria'),
                  const SizedBox(height: 12),
                  _buildIndustryFilter(theme),
                  const SizedBox(height: 24),

                  // Nivel de cobertura
                  _buildSectionTitle(theme, 'Nivel de cobertura'),
                  const SizedBox(height: 12),
                  _buildCoverageLevelFilter(theme),
                  const SizedBox(height: 24),

                  // Regiones (si aplica)
                  if (_filter.coverageLevel == 'Regional' ||
                      _filter.coverageLevel == null) ...[
                    _buildSectionTitle(theme, 'Regiones'),
                    const SizedBox(height: 12),
                    _buildRegionsFilter(theme),
                    const SizedBox(height: 24),
                  ],

                  // Certificaciones
                  _buildSectionTitle(theme, 'Certificaciones'),
                  const SizedBox(height: 12),
                  _buildCertificationsFilter(theme),
                  const SizedBox(height: 24),

                  // Número de empleados
                  _buildSectionTitle(theme, 'Número de empleados'),
                  const SizedBox(height: 12),
                  _buildEmployeeRangeFilter(theme),
                  const SizedBox(height: 24),

                  // Año de fundación
                  _buildSectionTitle(theme, 'Año de fundación'),
                  const SizedBox(height: 12),
                  _buildFoundedYearFilter(theme),
                ],
              ),
            ),
          ),
          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Actualizar rangos antes de aplicar
                    final minEmp = int.tryParse(_minEmployeesController.text);
                    final maxEmp = int.tryParse(_maxEmployeesController.text);
                    final minYear = int.tryParse(_minYearController.text);
                    final maxYear = int.tryParse(_maxYearController.text);
                    final finalFilter = _filter.copyWith(
                      minEmployees: minEmp,
                      maxEmployees: maxEmp,
                      minFoundedYear: minYear,
                      maxFoundedYear: maxYear,
                      clearEmployeeRange: minEmp == null && maxEmp == null,
                      clearFoundedYearRange: minYear == null && maxYear == null,
                    );
                    Navigator.pop(context, finalFilter);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _filter.hasActiveFilters
                        ? 'Aplicar filtros (${_filter.activeFilterCount})'
                        : 'Aplicar filtros',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildIndustryFilter(ThemeData theme) {
    if (widget.availableIndustries.isEmpty) {
      return Text(
        'No hay industrias disponibles',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableIndustries.map((industry) {
        final isSelected = _filter.industry == industry;
        return FilterChip(
          label: Text(industry),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                industry: selected ? industry : null,
                clearIndustry: !selected,
              );
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCoverageLevelFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BusinessConstants.coverageLevels.map((level) {
        final isSelected = _filter.coverageLevel == level;
        return FilterChip(
          label: Text(level),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = _filter.copyWith(
                coverageLevel: selected ? level : null,
                clearCoverageLevel: !selected,
              );
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRegionsFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: BusinessConstants.regions.map((region) {
        final isSelected = _filter.coverageRegions.contains(region);
        return FilterChip(
          label: Text(region, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final newRegions = List<String>.from(_filter.coverageRegions);
              if (selected) {
                newRegions.add(region);
              } else {
                newRegions.remove(region);
              }
              _filter = _filter.copyWith(coverageRegions: newRegions);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCertificationsFilter(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableCertifications.map((cert) {
        final isSelected = _filter.certifications.contains(cert);
        return FilterChip(
          label: Text(cert),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final newCerts = List<String>.from(_filter.certifications);
              if (selected) {
                newCerts.add(cert);
              } else {
                newCerts.remove(cert);
              }
              _filter = _filter.copyWith(certifications: newCerts);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmployeeRangeFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minEmployeesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Mínimo',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('-'),
        ),
        Expanded(
          child: TextField(
            controller: _maxEmployeesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Máximo',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFoundedYearFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minYearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Desde',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('-'),
        ),
        Expanded(
          child: TextField(
            controller: _maxYearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Hasta',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
