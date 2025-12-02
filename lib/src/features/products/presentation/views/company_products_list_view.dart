import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/products_list_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/new_product_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/widgets/company_product_card.dart';
import 'package:flutter_app/src/features/products/presentation/views/new_product_view.dart';
import 'package:flutter_app/src/features/products/domain/entities/product.dart';

/// View that displays a company's own products/services with edit and delete options.
class CompanyProductsListView extends StatefulWidget {
  final String companyId;

  const CompanyProductsListView({super.key, required this.companyId});

  @override
  State<CompanyProductsListView> createState() =>
      _CompanyProductsListViewState();
}

class _CompanyProductsListViewState extends State<CompanyProductsListView> {
  @override
  void initState() {
    super.initState();
    // Load products for this company
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ProductsListViewModel>(context, listen: false);
      vm.loadProductsByCompany(widget.companyId);
    });
  }

  void _handleEdit(BuildContext context, Product product) {
    // Initialize the NewProductViewModel for editing
    final newProductVm = Provider.of<NewProductViewModel>(
      context,
      listen: false,
    );
    newProductVm.initForEdit(product);

    // Navigate to edit screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewProductView(
          onCancel: () {
            Navigator.of(context).pop();
          },
          onPublishSuccess: () {
            // Refresh the list after successful edit
            final vm = Provider.of<ProductsListViewModel>(
              context,
              listen: false,
            );
            vm.loadProductsByCompany(widget.companyId);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, Product product) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.name}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final vm = Provider.of<ProductsListViewModel>(context, listen: false);
      try {
        await vm.deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ProductsListViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cargando tus publicaciones...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (vm.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error al cargar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => vm.loadProductsByCompany(widget.companyId),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_business_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sin publicaciones',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aún no has creado ninguna publicación.\nComienza a mostrar tus productos y servicios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await vm.loadProductsByCompany(widget.companyId);
          },
          color: theme.colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: vm.products.length,
            itemBuilder: (context, index) {
              final product = vm.products[index];
              return CompanyProductCard(
                product: product,
                onEdit: () => _handleEdit(context, product),
                onDelete: () => _handleDelete(context, product),
              );
            },
          ),
        );
      },
    );
  }
}
