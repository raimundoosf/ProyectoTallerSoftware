import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:flutter_app/src/features/products/presentation/views/products_list_view.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/companies_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().fetchUserRole();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final currentUser = viewModel.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Explorar'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.inventory_2_outlined),
                  text: 'Publicaciones',
                ),
                Tab(icon: Icon(Icons.business_outlined), text: 'Empresas'),
              ],
            ),
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
              : TabBarView(
                  controller: _tabController,
                  children: const [ProductsListView(), CompaniesListView()],
                ),
        );
      },
    );
  }
}
