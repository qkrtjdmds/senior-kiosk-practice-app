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
    this.compact = false,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  final String? label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantics = [title, description, label].whereType<String>().join(' ');
    final iconSize = compact ? 44.0 : 48.0;
    return Semantics(
      button: true,
      label: semantics,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              constraints: BoxConstraints(
                minHeight: compact ? 64 : AppSizes.choiceHeight,
              ),
              padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(
                      icon,
                      color: colors.primary,
                      size: compact ? 26 : 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (label != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            label!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.chevron_right_rounded, color: colors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
