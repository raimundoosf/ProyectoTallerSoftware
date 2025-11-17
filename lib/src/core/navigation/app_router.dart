import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/auth/presentation/views/login_screen.dart';
import 'package:flutter_app/src/features/auth/presentation/views/register_screen.dart';
import 'package:flutter_app/src/features/home/presentation/views/home_screen.dart';
import 'package:flutter_app/src/features/user_profile/presentation/views/profile_screen.dart';
import 'package:flutter_app/src/features/company_profile/presentation/views/company_profile_screen.dart';

final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
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
  ],
);
