import 'package:flutter/material.dart';

class TabLearningCard extends StatelessWidget {
  const TabLearningCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.status,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F3EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 34, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        status!,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
