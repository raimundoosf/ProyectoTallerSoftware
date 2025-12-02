import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/company_profile/domain/entities/company_profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Cargar información de la empresa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompanyProfileViewModel>().loadCompanyProfile(
        widget.product.companyId,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
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

                // Descripción
                _buildDescription(),

                const Divider(height: 1),

                // Certificaciones
                if (product.certifications.isNotEmpty) ...[
                  _buildCertifications(),
                  const Divider(height: 1),
                ],

                // Trazabilidad
                if (product.traceability.isNotEmpty) ...[
                  _buildTraceability(),
                  const Divider(height: 1),
                ],

                // Locales de reparación
                if (product.repairLocations.isNotEmpty) ...[
                  _buildRepairLocations(),
                  const Divider(height: 1),
                ],

                // Mapa (si hay puntos de trazabilidad o reparación)
                if (product.traceability.isNotEmpty ||
                    product.repairLocations.isNotEmpty) ...[
                  _buildMap(),
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
                '\$${product.price.toStringAsFixed(0)} CLP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (product.isService && product.serviceDuration.isNotEmpty) ...[
                const Spacer(),
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  product.serviceDuration,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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

  Widget _buildTraceability() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Trazabilidad',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.product.traceability.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final description = (point['description'] as String?) ?? '';
            final mediaPath = point['mediaPath'] as String?;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${(point['lat'] ?? 0.0).toStringAsFixed(4)}, '
                            'Lon: ${(point['lon'] ?? 0.0).toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (mediaPath != null && mediaPath.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                mediaPath,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRepairLocations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.build_circle,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Locales de Reparación',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.product.repairLocations.map((location) {
            final address = (location['address'] as String?) ?? 'Sin nombre';
            final lat = (location['lat'] ?? 0.0);
            final lon = (location['lon'] ?? 0.0);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.store),
                title: Text(address),
                subtitle: Text(
                  'Lat: ${lat.toStringAsFixed(4)}, Lon: ${lon.toStringAsFixed(4)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final markers = <Marker>{};
    LatLng? center;

    // Agregar marcadores de trazabilidad
    for (var i = 0; i < widget.product.traceability.length; i++) {
      final point = widget.product.traceability[i];
      final lat = (point['lat'] as num?)?.toDouble() ?? 0.0;
      final lon = (point['lon'] as num?)?.toDouble() ?? 0.0;
      final description = (point['description'] as String?) ?? '';

      if (lat != 0.0 || lon != 0.0) {
        final position = LatLng(lat, lon);
        center ??= position;

        markers.add(
          Marker(
            markerId: MarkerId('trace_$i'),
            position: position,
            infoWindow: InfoWindow(
              title: 'Trazabilidad ${i + 1}',
              snippet: description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
    }

    // Agregar marcadores de reparación
    for (var i = 0; i < widget.product.repairLocations.length; i++) {
      final location = widget.product.repairLocations[i];
      final lat = (location['lat'] as num?)?.toDouble() ?? 0.0;
      final lon = (location['lon'] as num?)?.toDouble() ?? 0.0;
      final address = (location['address'] as String?) ?? '';

      if (lat != 0.0 || lon != 0.0) {
        final position = LatLng(lat, lon);
        center ??= position;

        markers.add(
          Marker(
            markerId: MarkerId('repair_$i'),
            position: position,
            infoWindow: InfoWindow(title: 'Reparación', snippet: address),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    }

    if (center == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubicaciones en Mapa',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: center, zoom: 12),
                markers: markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Consumer<CompanyProfileViewModel>(
      builder: (context, viewModel, child) {
        final company = viewModel.companyProfile;

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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  company?.logoUrl != null &&
                                      company!.logoUrl.isNotEmpty
                                  ? NetworkImage(company.logoUrl)
                                  : null,
                              child:
                                  company?.logoUrl == null ||
                                      company!.logoUrl.isEmpty
                                  ? const Icon(Icons.business, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company?.companyName ?? 'Cargando...',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.public_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _getCoverageText(company),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (company?.website != null &&
                                      company!.website.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _launchURL(company.website),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.language,
                                            size: 16,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              company.website,
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
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
    if (company == null) return 'Cargando...';

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
