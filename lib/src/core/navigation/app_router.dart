import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_app/src/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_app/src/features/home/presentation/views/main_scaffold.dart';
import 'package:flutter_app/src/features/user_profile/presentation/views/profile_screen.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_profile_screen.dart';
import 'package:flutter_app/src/features/products/presentation/views/new_product_view.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/companies_list_view.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_public_profile_view.dart';

final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainScaffold();
      },
    ),
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
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    GoRoute(
      path: '/company-profile',
      builder: (BuildContext context, GoRouterState state) {
        return const CompanyProfileScreen();
      },
    ),
    GoRoute(
      path: '/products/new',
      builder: (BuildContext context, GoRouterState state) {
        return const NewProductView();
      },
    ),
    GoRoute(
      path: '/companies',
      builder: (BuildContext context, GoRouterState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Empresas'), elevation: 0),
          body: const CompaniesListView(),
        );
      },
    ),
    GoRoute(
      path: '/company/:companyId',
      builder: (BuildContext context, GoRouterState state) {
        final companyId = state.pathParameters['companyId']!;
        return CompanyPublicProfileView(companyId: companyId);
      },
    ),
  ],
);
