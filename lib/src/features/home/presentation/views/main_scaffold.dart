import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/home/presentation/views/home_screen.dart';
import 'package:flutter_app/src/features/products/presentation/views/new_product_view.dart';
import 'package:flutter_app/src/features/user_profile/presentation/views/profile_screen.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_profile_view.dart';
import 'package:flutter_app/src/features/contact/presentation/views/contact_history_view.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';

/// Widget que envuelve el contenido con la barra de navegación inferior.
/// Se usa con ShellRoute para mantener la barra en todas las rutas internas.
class MainScaffoldWithChild extends StatefulWidget {
  final Widget child;

  const MainScaffoldWithChild({super.key, required this.child});

  @override
  State<MainScaffoldWithChild> createState() => _MainScaffoldWithChildState();
}

class _MainScaffoldWithChildState extends State<MainScaffoldWithChild> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserRole();
    });
  }

  Future<void> _loadUserRole() async {
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    final viewModel = context.read<HomeViewModel>();
    await viewModel.fetchUserRole();

    if (!mounted) return;

    if (viewModel.currentRole == null) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    setState(() {
      _userRole = viewModel.currentRole;
    });
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') return 0;
    if (location == '/publish' || location == '/contacts') return 1;
    if (location == '/profile') return 2;
    return 0; // Default para otras rutas (companies, etc.)
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || _userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              // Usuario Empresa va a Publicar, Usuario Consumidor va a Mis Contactos
              if (_userRole == 'Empresa') {
                context.go('/publish');
              } else {
                context.go('/contacts');
              }
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _userRole == 'Empresa'
                  ? Icons.add_circle_outline
                  : Icons.mail_outline,
            ),
            activeIcon: Icon(
              _userRole == 'Empresa' ? Icons.add_circle : Icons.mail,
            ),
            label: _userRole == 'Empresa' ? 'Publicar' : 'Contactos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra el contenido de cada tab principal
class MainScaffoldContent extends StatelessWidget {
  final int tabIndex;

  const MainScaffoldContent({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final userRole = viewModel.currentRole;

        switch (tabIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            if (userRole == 'Empresa') {
              return NewProductView(
                onCancel: () => context.go('/'),
                onPublishSuccess: () => context.go('/profile'),
              );
            } else {
              // Usuario Consumidor ve el historial de contactos
              return const ContactHistoryView();
            }
          case 2:
            if (userRole == 'Empresa') {
              final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              return CompanyProfileView(companyId: userId);
            } else {
              return const ProfileScreen();
            }
          default:
            return const HomeScreen();
        }
      },
    );
  }
}

/// Widget principal que contiene la barra de navegación inferior y gestiona
/// las tres pantallas principales: Home, Crear Publicación y Perfil.
/// @deprecated Usar MainScaffoldWithChild con ShellRoute en su lugar
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserRole();
    });
  }

  Future<void> _loadUserRole() async {
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    final viewModel = context.read<HomeViewModel>();
    await viewModel.fetchUserRole();

    if (!mounted) return;

    if (viewModel.currentRole == null) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go('/login');
      }
      return;
    }

    setState(() {
      _userRole = viewModel.currentRole;
    });
  }

  void _navigateToIndex(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  List<Widget> _getScreens() {
    if (_userRole == 'Empresa') {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      return [
        const HomeScreen(),
        NewProductView(
          onCancel: () => _navigateToIndex(0),
          onPublishSuccess: () => _navigateToIndex(2),
        ),
        CompanyProfileView(companyId: userId),
      ];
    } else {
      return [
        const HomeScreen(),
        const Center(
          child: Text(
            'Función de crear publicación no disponible para usuarios',
          ),
        ),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || _userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = _getScreens();

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _userRole == 'Empresa'
                  ? Icons.add_circle_outline
                  : Icons.post_add_outlined,
            ),
            activeIcon: Icon(
              _userRole == 'Empresa' ? Icons.add_circle : Icons.post_add,
            ),
            label: 'Publicar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
