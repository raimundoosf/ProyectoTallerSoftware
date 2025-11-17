import 'package:flutter/material.dart';

extension AppSnackBar on BuildContext {
  /// Shows a styled, floating SnackBar with an optional success/error style.
  void showAppSnackBar(
    String message, {
    bool success = true,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(this);
    final background = success
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final foreground = success
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onError;
    final icon = success ? Icons.check_circle_outline : Icons.error_outline;

    final snack = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      backgroundColor: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      duration: duration ?? const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction ?? () {},
              textColor: foreground,
            )
          : null,
    );

    ScaffoldMessenger.of(this).showSnackBar(snack);
  }
}

/// Create the same styled SnackBar instance so the caller can capture
/// a ScaffoldMessenger and show the SnackBar after an async gap safely.
SnackBar makeAppSnackBar(
  BuildContext context,
  String message, {
  bool success = true,
  Duration? duration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final theme = Theme.of(context);
  final background = success
      ? theme.colorScheme.primary
      : theme.colorScheme.error;
  final foreground = success
      ? theme.colorScheme.onPrimary
      : theme.colorScheme.onError;
  final icon = success ? Icons.check_circle_outline : Icons.error_outline;

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    backgroundColor: background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    duration: duration ?? const Duration(seconds: 3),
    content: Row(
      children: [
        Icon(icon, color: foreground),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: TextStyle(color: foreground)),
        ),
      ],
    ),
    action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            onPressed: onAction ?? () {},
            textColor: foreground,
          )
        : null,
  );
}
