import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

/// Widget de debug para resetear el onboarding
/// Uso: Agrega FloatingActionButton en cualquier vista para probar
class ResetOnboardingButton extends StatelessWidget {
  const ResetOnboardingButton({super.key});

  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Onboarding reseteado. Reinicia la app para verlo.'),
          backgroundColor: Colors.green,
        ),
      );

      // Opcional: navegar directamente al onboarding
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _resetOnboarding(context),
      icon: const Icon(Icons.refresh),
      label: const Text('Reset Onboarding'),
      backgroundColor: Colors.orange,
    );
  }
}
