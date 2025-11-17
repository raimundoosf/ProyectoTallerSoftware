import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';

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

  Future<void> _navigateToProfile(HomeViewModel viewModel) async {
    final user = viewModel.currentUser;
    if (user == null) return;
    if (viewModel.currentRole == null && !viewModel.isRoleLoading) {
      await viewModel.fetchUserRole();
    }
    if (!mounted) return;
    final destination = viewModel.currentRole == 'Empresa'
        ? '/company-profile'
        : '/profile';
    context.push(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final currentUser = viewModel.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Página Principal'),
            actions: [
              Semantics(
                button: true,
                label: 'Abrir perfil',
                child: IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Perfil',
                  onPressed: currentUser == null
                      ? null
                      : () => _navigateToProfile(viewModel),
                ),
              ),
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
          body: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: viewModel.isRoleLoading
                  ? const CircularProgressIndicator(
                      key: ValueKey('home-loading'),
                    )
                  : Column(
                      key: const ValueKey('home-content'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¡Bienvenido!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        if (currentUser?.email != null)
                          Text(
                            currentUser!.email!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Rol: ${viewModel.currentRole ?? 'No definido'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
