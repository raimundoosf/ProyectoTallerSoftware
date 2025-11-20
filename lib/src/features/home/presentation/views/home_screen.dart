import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/products_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().fetchUserRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final currentUser = viewModel.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Publicaciones'),
            actions: [
              Semantics(
                button: true,
                label: 'Cerrar sesión',
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar Sesión',
                  onPressed: () {
                    viewModel.signOut().then((_) {
                      if (context.mounted) context.go('/login');
                    });
                  },
                ),
              ),
            ],
          ),
          body: currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : const ProductsListView(),
        );
      },
    );
  }
}
