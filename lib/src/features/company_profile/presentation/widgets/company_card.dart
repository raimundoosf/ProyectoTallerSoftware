import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';

class CompanyCard extends StatelessWidget {
  final CompanyProfile company;
  final VoidCallback? onTap;

  const CompanyCard({super.key, required this.company, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: company.logoUrl.isNotEmpty
                    ? NetworkImage(company.logoUrl)
                    : null,
                child: company.logoUrl.isEmpty
                    ? Icon(
                        Icons.business,
                        size: 32,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      company.companyName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Industria
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        company.industry,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Descripción
                    if (company.companyDescription.isNotEmpty)
                      Text(
                        company.companyDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Cobertura
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCoverageText(company),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Certificaciones
                    if (company.certifications.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: company.certifications
                            .take(3)
                            .map(
                              (cert) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 10,
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cert['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCoverageText(CompanyProfile company) {
    if (company.coverageLevel == 'Nacional') {
      return 'Cobertura Nacional';
    } else if (company.coverageLevel == 'Regional') {
      final count = company.coverageRegions.length;
      if (count == 0) return 'Cobertura Regional';
      return '$count ${count == 1 ? 'región' : 'regiones'}';
    } else if (company.coverageLevel == 'Comunal') {
      final count = company.coverageCommunes.length;
      if (count == 0) return 'Cobertura Comunal';
      return '$count ${count == 1 ? 'comuna' : 'comunas'}';
    }
    return 'Cobertura no especificada';
  }
}
