import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_app/src/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_app/src/features/home/presentation/views/main_scaffold.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_profile_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    // Rutas sin barra de navegación (login/registro)
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),

    // ShellRoute para mantener la barra de navegación en todas las demás rutas
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffoldWithChild(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const MainScaffoldContent(tabIndex: 0);
          },
        ),
        GoRoute(
          path: '/publish',
          builder: (BuildContext context, GoRouterState state) {
            return const MainScaffoldContent(tabIndex: 1);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const MainScaffoldContent(tabIndex: 2);
          },
        ),
        GoRoute(
          path: '/company/:companyId',
          builder: (BuildContext context, GoRouterState state) {
            final companyId = state.pathParameters['companyId']!;
            return CompanyProfileView(companyId: companyId);
          },
        ),
      ],
    ),
  ],
);
