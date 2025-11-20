import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/products/presentation/viewmodels/products_list_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/widgets/product_card.dart';

class ProductsListView extends StatefulWidget {
  const ProductsListView({super.key});

  @override
  State<ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<ProductsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsListViewModel>().loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null && viewModel.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadAllProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (viewModel.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay publicaciones disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Las publicaciones aparecerán aquí',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: viewModel.products.length,
            itemBuilder: (context, index) {
              final product = viewModel.products[index];
              return ProductCard(product: product);
            },
          ),
        );
      },
    );
  }
}
