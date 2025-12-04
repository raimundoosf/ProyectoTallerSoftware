import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';

class CompanyCard extends StatelessWidget {
  final CompanyProfile company;
  final VoidCallback? onTap;

  const CompanyCard({super.key, required this.company, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con gradiente y logo
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Patrón decorativo
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Badge de industria
                    if (company.industry.isNotEmpty)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            company.industry,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Logo posicionado
                    Positioned(
                      left: 16,
                      bottom: -30,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: company.logoUrl.isNotEmpty
                                ? NetworkImage(company.logoUrl)
                                : null,
                            child: company.logoUrl.isEmpty
                                ? Icon(
                                    Icons.business_rounded,
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company.companyName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),

                    // Descripción
                    if (company.companyDescription.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        company.companyDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Info pills
                    Row(
                      children: [
                        // Cobertura
                        _buildInfoPill(
                          theme,
                          _getCoverageIcon(company.coverageLevel),
                          _getCoverageText(company),
                          theme.colorScheme.secondaryContainer,
                          theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        // Año
                        if (company.foundedYear > 0)
                          _buildInfoPill(
                            theme,
                            Icons.calendar_today_outlined,
                            'Desde ${company.foundedYear}',
                            theme.colorScheme.tertiaryContainer,
                            theme.colorScheme.onTertiaryContainer,
                          ),
                      ],
                    ),

                    // Certificaciones
                    if (company.certifications.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: company.certifications
                              .take(3)
                              .map(
                                (cert) => Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cert['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(
    ThemeData theme,
    IconData icon,
    String text,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCoverageIcon(String coverageLevel) {
    switch (coverageLevel) {
      case 'Nacional':
        return Icons.public;
      case 'Regional':
        return Icons.map_outlined;
      case 'Comunal':
        return Icons.location_city;
      default:
        return Icons.location_on_outlined;
    }
  }

  String _getCoverageText(CompanyProfile company) {
    if (company.coverageLevel == 'Nacional') {
      return 'Nacional';
    } else if (company.coverageLevel == 'Regional') {
      final count = company.coverageRegions.length;
      if (count == 0) return 'Regional';
      return '$count ${count == 1 ? 'región' : 'regiones'}';
    } else if (company.coverageLevel == 'Comunal') {
      final count = company.coverageCommunes.length;
      if (count == 0) return 'Comunal';
      return '$count ${count == 1 ? 'comuna' : 'comunas'}';
    }
    return 'Sin especificar';
  }
}
