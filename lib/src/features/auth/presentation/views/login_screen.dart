import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/src/features/auth/presentation/viewmodels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<LoginViewModel>();
      viewModel.resetForm();
      _emailController.text = viewModel.email;
      _passwordController.text = viewModel.password;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¡Bienvenido de Nuevo!',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  onChanged: (value) => viewModel.email = value,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: viewModel.fieldErrors['email'],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  onChanged: (value) => viewModel.password = value,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: viewModel.fieldErrors['password'],
                  ),
                ),
                const SizedBox(height: 32.0),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: viewModel.isLoading
                      ? const Center(
                          key: ValueKey('login-loading'),
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          key: const ValueKey('login-button'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 20.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 6,
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(64),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            // capture UI pieces before the async gap
                            final messenger = ScaffoldMessenger.of(context);
                            final colorScheme = Theme.of(context).colorScheme;

                            final success = await viewModel.login();
                            if (!context.mounted) return;

                            if (success) {
                              context.go('/');
                            } else if (viewModel.error != null) {
                              final bg = colorScheme.error;
                              final fg = colorScheme.onError;
                              final snack = SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                backgroundColor: bg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                content: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: fg),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        viewModel.error!,
                                        style: TextStyle(color: fg),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              messenger.showSnackBar(snack);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.login_outlined),
                              SizedBox(width: 10),
                              Text('Iniciar Sesión'),
                            ],
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
