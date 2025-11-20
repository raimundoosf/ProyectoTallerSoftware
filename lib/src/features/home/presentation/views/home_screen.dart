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
                final offset = Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: currentUser == null
                  ? const Text(
                      key: ValueKey('no-user'),
                      'Cargando información del usuario...',
                    )
                  : Column(
                      key: ValueKey('user-${currentUser.uid}'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.home, size: 64),
                        const SizedBox(height: 24),
                        Text(
                          '¡Bienvenido!',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Usa la barra de navegación inferior para explorar',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (viewModel.currentRole != null) ...[
                          const SizedBox(height: 24),
                          Chip(
                            avatar: Icon(
                              viewModel.currentRole == 'Empresa'
                                  ? Icons.business
                                  : Icons.person,
                              size: 18,
                            ),
                            label: Text('Rol: ${viewModel.currentRole}'),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
