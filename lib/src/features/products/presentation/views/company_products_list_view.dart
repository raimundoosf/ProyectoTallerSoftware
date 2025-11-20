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
    return Consumer<ProductsListViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${vm.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => vm.loadProductsByCompany(widget.companyId),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (vm.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes publicaciones aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu primera publicación',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await vm.loadProductsByCompany(widget.companyId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
