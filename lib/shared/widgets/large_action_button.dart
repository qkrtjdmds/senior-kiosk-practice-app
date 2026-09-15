import 'package:flutter/material.dart';

class LargeActionButton extends StatelessWidget {
  const LargeActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 82),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      backgroundColor: secondary
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.primary,
      foregroundColor: secondary
          ? Theme.of(context).colorScheme.onSecondaryContainer
          : Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 28),
      label: Text(label, textAlign: TextAlign.center),
      style: buttonStyle,
    );
  }
}
