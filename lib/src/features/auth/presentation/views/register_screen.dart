import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/features/auth/presentation/viewmodels/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<RegisterViewModel>();
      viewModel.resetForm();
      _emailController.text = viewModel.email;
      _passwordController.text = viewModel.password;
      _confirmPasswordController.text = viewModel.confirmPassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Bienvenido a Glooba',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu cuenta para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  onChanged: (value) => viewModel.email = value,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Correo Electrónico',
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
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Contraseña',
                    errorText: viewModel.fieldErrors['password'],
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  onChanged: (value) => viewModel.confirmPassword = value,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Confirmar Contraseña',
                    errorText: viewModel.fieldErrors['confirmPassword'],
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  key: ValueKey('role-${viewModel.role}'),
                  initialValue: viewModel.role,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: const ['Consumidor', 'Empresa']
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      viewModel.role = newValue;
                    }
                  },
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
                          key: ValueKey('register-loading'),
                          child: CircularProgressIndicator(),
                        )
                      : Semantics(
                          key: const ValueKey('register-button'),
                          button: true,
                          label:
                              'Registrarme seleccionando rol de ${viewModel.role}',
                          child: ElevatedButton(
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
                              // capture messenger and theme before async work
                              final messenger = ScaffoldMessenger.of(context);
                              final colorScheme = Theme.of(context).colorScheme;

                              final success = await viewModel.register();
                              if (!context.mounted) return;

                              if (success) {
                                if (viewModel.role == 'Empresa') {
                                  // Redirigir al perfil de la empresa propia
                                  context.go('/profile');
                                } else {
                                  context.go('/profile');
                                }
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
                              children: [
                                const Icon(Icons.person_add_outlined),
                                const SizedBox(width: 10),
                                Text('Registrarme (${viewModel.role})'),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
