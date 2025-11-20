import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/home/presentation/views/home_screen.dart';
import 'package:flutter_app/src/features/products/presentation/views/new_product_view.dart';
import 'package:flutter_app/src/features/user_profile/presentation/views/profile_screen.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_profile_screen.dart';
import 'package:flutter_app/src/features/home/presentation/viewmodels/home_viewmodel.dart';

/// Widget principal que contiene la barra de navegación inferior y gestiona
/// las tres pantallas principales: Home, Crear Publicación y Perfil.
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
    final viewModel = context.read<HomeViewModel>();
    await viewModel.fetchUserRole();
    if (mounted) {
      setState(() {
        _userRole = viewModel.currentRole;
      });
    }
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
      return [
        const HomeScreen(),
        NewProductView(
          onCancel: () => _navigateToIndex(0),
          onPublishSuccess: () => _navigateToIndex(2),
        ),
        const CompanyProfileScreen(),
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
