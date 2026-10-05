import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'han_geoleum_character.dart';

class CharacterMessage extends StatelessWidget {
  const CharacterMessage({
    required this.title,
    required this.message,
    this.mood = HanGeoleumMood.guide,
    super.key,
  });
  final String title;
  final String message;
  final HanGeoleumMood mood;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 330;
      final character = HanGeoleumCharacter(mood: mood, size: 76);
      final copy = Column(
        crossAxisAlignment: narrow
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: narrow ? TextAlign.center : null,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: narrow ? TextAlign.center : null,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: narrow
            ? Column(children: [character, const SizedBox(height: 10), copy])
            : Row(
                children: [
                  character,
                  const SizedBox(width: 16),
                  Expanded(child: copy),
                ],
              ),
      );
    },
  );
}

class AppListRow extends StatelessWidget {
  const AppListRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.label,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.choiceHeight),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (label != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        label!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
