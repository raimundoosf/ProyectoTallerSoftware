import 'package:flutter/material.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';
import 'package:flutter_app/src/features/products/presentation/views/product_detail_view.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ProductDetailView(product: product),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    // Fade in del contenido que no es Hero
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            if (product.imageUrls.isNotEmpty)
              Hero(
                tag: 'product-image-${product.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    product.imageUrls.first,
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
                ),
              )
            else
              Hero(
                tag: 'product-image-${product.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[300],
                    child: Icon(
                      product.isService
                          ? Icons.room_service
                          : Icons.inventory_2,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo (Producto o Servicio)
                  Row(
                    children: [
                      Icon(
                        product.isService
                            ? Icons.room_service
                            : Icons.shopping_bag,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isService ? 'Servicio' : 'Producto',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (product.isService &&
                          product.serviceCategory.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${product.serviceCategory}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nombre
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Precio
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(0)} CLP',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product.isService &&
                          product.serviceDuration.isNotEmpty) ...[
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.serviceDuration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Certificaciones
                  if (product.certifications.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: product.certifications.take(3).map((cert) {
                        return Chip(
                          label: Text(
                            cert,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],

                  // Indicadores de características
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (product.traceability.isNotEmpty)
                        _buildFeatureIndicator(
                          Icons.location_on_outlined,
                          'Trazabilidad',
                          context,
                        ),
                      if (product.traceability.isNotEmpty &&
                          product.repairLocations.isNotEmpty)
                        const SizedBox(width: 12),
                      if (product.repairLocations.isNotEmpty)
                        _buildFeatureIndicator(
                          Icons.build_circle_outlined,
                          'Reparación',
                          context,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator(
    IconData icon,
    String label,
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
