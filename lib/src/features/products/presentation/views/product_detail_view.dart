import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/company_profile/presentation/viewmodels/company_profile_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isRepairExpanded = false;
  bool _companyLoadFailed = false;

  @override
  void initState() {
    super.initState();
    // Cargar información de la empresa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyProfile();
    });
  }

  Future<void> _loadCompanyProfile() async {
    try {
      await context.read<CompanyProfileViewModel>().loadCompanyProfile(
        widget.product.companyId,
      );
      if (mounted) {
        final profile = context.read<CompanyProfileViewModel>().companyProfile;
        if (profile == null) {
          setState(() => _companyLoadFailed = true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _companyLoadFailed = true);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageGallery()),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con tipo, nombre y precio
                _buildHeader(),

                const Divider(height: 1),

                // Detalles específicos del producto o servicio
                if (!product.isService) ...[
                  _buildProductDetails(),
                  const Divider(height: 1),
                ] else ...[
                  _buildServiceDetails(),
                  const Divider(height: 1),
                ],

                // Descripción
                _buildDescription(),

                const Divider(height: 1),

                // Etiquetas
                if (product.tags.isNotEmpty) ...[
                  _buildTags(),
                  const Divider(height: 1),
                ],

                // Certificaciones
                if (product.certifications.isNotEmpty) ...[
                  _buildCertifications(),
                  const Divider(height: 1),
                ],

                // Locales de reparación
                if (product.repairLocations.isNotEmpty) ...[
                  _buildRepairLocations(),
                  const Divider(height: 1),
                ],

                // Términos y condiciones
                if (product.terms.isNotEmpty) ...[
                  _buildTerms(),
                  const Divider(height: 1),
                ],

                // Información de la empresa
                _buildCompanyInfo(),

                const SizedBox(height: 80), // Espacio para el botón flotante
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildContactButton(),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.imageUrls;

    if (images.isEmpty) {
      return Hero(
        tag: 'product-image-${widget.product.id}',
        child: Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              widget.product.isService ? Icons.room_service : Icons.inventory_2,
              size: 80,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            // Solo la primera imagen tiene Hero para la animación
            if (index == 0) {
              return Hero(
                tag: 'product-image-${widget.product.id}',
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 64),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            // Las demás imágenes sin Hero
            return Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 64),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            );
          },
        ),
        // Indicador de página
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        // Contador de imágenes
        if (images.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final product = widget.product;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo y categoría
          Row(
            children: [
              Icon(
                product.isService ? Icons.room_service : Icons.shopping_bag,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                product.isService ? 'Servicio' : 'Producto',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (product.isService && product.serviceCategory.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '• ${product.serviceCategory}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Nombre
          Text(
            product.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Precio y duración
          Row(
            children: [
              Text(
                product.priceOnRequest
                    ? 'Solicitar cotización'
                    : '\$${product.price.toStringAsFixed(0)} CLP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (product.isService && product.serviceDurationMinutes > 0) ...[
                const Spacer(),
                Icon(
                  Icons.schedule_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(product.serviceDurationMinutes),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours ${hours == 1 ? 'hora' : 'horas'}';
      } else {
        return '$hours${hours == 1 ? 'h' : 'h'} $mins min';
      }
    }
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    final product = widget.product;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Producto',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (product.productCategory.isNotEmpty)
            _buildDetailRow(
              icon: Icons.category_outlined,
              label: 'Categoría',
              value: product.productCategory,
            ),
          if (product.condition.isNotEmpty)
            _buildDetailRow(
              icon: Icons.star_outline,
              label: 'Condición',
              value: product.condition,
            ),
          if (product.warrantyMonths > 0)
            _buildDetailRow(
              icon: Icons.verified_user_outlined,
              label: 'Garantía',
              value:
                  '${product.warrantyMonths} ${product.warrantyMonths == 1 ? 'mes' : 'meses'}',
            ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    final product = widget.product;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Servicio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (product.serviceCategory.isNotEmpty)
            _buildDetailRow(
              icon: Icons.category_outlined,
              label: 'Categoría',
              value: product.serviceCategory,
            ),
          if (product.serviceModality.isNotEmpty)
            _buildDetailRow(
              icon: Icons.place_outlined,
              label: 'Modalidad',
              value: product.serviceModality,
            ),
          if (product.serviceSchedule.isNotEmpty)
            _buildDetailRow(
              icon: Icons.access_time_outlined,
              label: 'Horarios',
              value: product.serviceSchedule,
            ),
          if (product.serviceCoverage.isNotEmpty)
            _buildDetailRow(
              icon: Icons.map_outlined,
              label: 'Cobertura',
              value: product.serviceCoverage.join(', '),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final product = widget.product;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sell_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Etiquetas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTerms() {
    final product = widget.product;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Términos y Condiciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.terms,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertifications() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Certificaciones',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.certifications.map((cert) {
              return Chip(
                avatar: const Icon(Icons.check_circle, size: 18),
                label: Text(cert),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairLocations() {
    final locations = widget.product.repairLocations;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isRepairExpanded = !_isRepairExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Locales de Reparación',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${locations.length} ${locations.length == 1 ? 'local' : 'locales'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isRepairExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_isRepairExpanded) ...[
            const SizedBox(height: 8),
            ...locations.map((location) {
              final address = (location['address'] as String?) ?? 'Sin nombre';
              final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
              final lon = (location['lon'] as num?)?.toDouble() ?? 0.0;

              return InkWell(
                onTap: () => _openInMaps(lat, lon, address),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        final company = viewModel.companyProfile;
        final isLoading = viewModel.isLoading;
        final hasCompany = company != null && company.companyName.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendido por',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  onTap: hasCompany
                      ? () => _navigateToCompanyProfile(
                          context,
                          widget.product.companyId,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isLoading && !_companyLoadFailed
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    hasCompany && company.logoUrl.isNotEmpty
                                    ? NetworkImage(company.logoUrl)
                                    : null,
                                child: !hasCompany || company.logoUrl.isEmpty
                                    ? Icon(
                                        Icons.business,
                                        size: 24,
                                        color: Colors.grey[600],
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasCompany
                                          ? company.companyName
                                          : _companyLoadFailed
                                          ? 'Empresa no disponible'
                                          : 'Sin información',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (hasCompany) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        _getCoverageText(company),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (hasCompany)
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCompanyProfile(BuildContext context, String companyId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _CompanyProfileViewWrapper(companyId: companyId),
      ),
    );
  }

  Widget _buildContactButton() {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        final company = viewModel.companyProfile;
        if (company?.website == null || company!.website.isEmpty) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _launchURL(company.website),
          icon: const Icon(Icons.language),
          label: const Text('Visitar sitio web'),
        );
      },
    );
  }

  Future<void> _openInMaps(double lat, double lon, String label) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede abrir el mapa')),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se puede abrir: $url')));
      }
    }
  }

  String _getCoverageText(CompanyProfile? company) {
    if (company == null) return '';

    final level = company.coverageLevel;
    if (level == 'Nacional') {
      return 'Cobertura Nacional';
    } else if (level == 'Regional') {
      final count = company.coverageRegions.length;
      if (count == 0) return 'Cobertura Regional';
      return 'Cobertura en $count ${count == 1 ? 'región' : 'regiones'}';
    } else if (level == 'Comunal') {
      final count = company.coverageCommunes.length;
      if (count == 0) return 'Cobertura Comunal';
      return 'Cobertura en $count ${count == 1 ? 'comuna' : 'comunas'}';
    }
    return 'Cobertura no especificada';
  }
}

/// Widget para mostrar el perfil de empresa en modo solo lectura
class _CompanyProfileViewWrapper extends StatefulWidget {
  final String companyId;

  const _CompanyProfileViewWrapper({required this.companyId});

  @override
  State<_CompanyProfileViewWrapper> createState() =>
      _CompanyProfileViewWrapperState();
}

class _CompanyProfileViewWrapperState
    extends State<_CompanyProfileViewWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileViewModel>().loadCompanyProfile(
        widget.companyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        final company = viewModel.companyProfile;

        if (viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil de Empresa')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (company == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil de Empresa')),
            body: const Center(child: Text('No se pudo cargar la información')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(company.companyName)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo y nombre
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: company.logoUrl.isNotEmpty
                            ? NetworkImage(company.logoUrl)
                            : null,
                        child: company.logoUrl.isEmpty
                            ? Icon(
                                Icons.business,
                                size: 50,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        company.companyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (company.industry.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          company.industry,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Descripción
                if (company.companyDescription.isNotEmpty) ...[
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(company.companyDescription),
                  const SizedBox(height: 24),
                ],

                // Información de contacto
                if (company.email.isNotEmpty ||
                    company.phone.isNotEmpty ||
                    company.website.isNotEmpty) ...[
                  Text(
                    'Contacto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (company.email.isNotEmpty)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined),
                      title: Text(company.email),
                    ),
                  if (company.phone.isNotEmpty)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(company.phone),
                    ),
                  if (company.website.isNotEmpty)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language),
                      title: Text(
                        company.website,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () async {
                        var url = company.website;
                        if (!url.startsWith('http')) url = 'https://$url';
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  const SizedBox(height: 24),
                ],

                // Certificaciones
                if (company.certifications.isNotEmpty) ...[
                  Text(
                    'Certificaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: company.certifications.map((cert) {
                      final name = cert['name'] ?? '';
                      return Chip(
                        avatar: const Icon(Icons.verified, size: 18),
                        label: Text(name),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
