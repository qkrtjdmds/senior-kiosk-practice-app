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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      backgroundColor: secondary
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.primary,
      foregroundColor: secondary
          ? Theme.of(context).colorScheme.onSecondaryContainer
          : Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

    return FilledButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical =
              icon != null &&
              label.length > 10 &&
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final labelText = Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: vertical ? 20 : null,
              color: secondary
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          );
          if (vertical) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26),
                const SizedBox(height: 8),
                labelText,
              ],
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 28),
                const SizedBox(width: 10),
              ],
              Flexible(child: labelText),
            ],
          );
        },
      ),
    );
  }
}
