import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '한걸음 디지털',
      showBackButton: false,
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.accessibilitySettings),
          icon: const Icon(Icons.settings_outlined),
          tooltip: '화면 설정',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘도 천천히 연습해 볼까요?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _HomeMessageCard(
            title: '오늘의 연습',
            message: '한 단계씩 따라 해보세요.',
            icon: Icons.eco_outlined,
          ),
          const SizedBox(height: 28),
          _HomeFeatureCard(
            title: '카페 키오스크 연습',
            message: '화면을 보며 주문 순서를 연습해요',
            icon: Icons.local_cafe_outlined,
            onPressed: () => context.go(AppRoutes.cafeStart),
          ),
          const SizedBox(height: 16),
          _ProgressCard(onPressed: () => context.go(AppRoutes.progress)),
          const SizedBox(height: 30),
          Text('다른 연습', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _PracticeGrid(
            items: [
              _PracticeItem(
                title: '병원 접수',
                icon: Icons.local_hospital_outlined,
                onPressed: () => context.go(AppRoutes.hospitalStart),
              ),
              _PracticeItem(
                title: '사진 보내기',
                icon: Icons.photo_outlined,
                onPressed: () => context.go(AppRoutes.photoStart),
              ),
              _PracticeItem(
                title: '기차표 예매',
                icon: Icons.train_outlined,
                onPressed: () => context.go(AppRoutes.trainStart),
              ),
              _PracticeItem(
                title: '햄버거 주문',
                icon: Icons.lunch_dining_outlined,
                onPressed: () => context.go(AppRoutes.hamburgerStart),
              ),
              _PracticeItem(
                title: 'ATM 출금',
                icon: Icons.account_balance_outlined,
                onPressed: () => context.go(AppRoutes.atmStart),
              ),
              _PracticeItem(
                title: '서류 발급',
                icon: Icons.description_outlined,
                onPressed: () => context.go(AppRoutes.civilDocumentStart),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeMessageCard extends StatelessWidget {
  const _HomeMessageCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F3EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9FCBB4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: const Color(0xFF286A5B)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(message, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
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
                child: Icon(icon, size: 34, color: const Color(0xFF286A5B)),
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
                    const SizedBox(height: 4),
                    Text(message, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 22,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useColumn =
                  constraints.maxWidth < 340 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              final title = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 34,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      '나의 디지털 걸음',
                      softWrap: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                  ),
                ],
              );
              final detail = Text(
                '기록과 포인트 보기',
                softWrap: true,
                style: Theme.of(context).textTheme.bodyLarge,
              );
              if (useColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 8), detail],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  Flexible(child: detail),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PracticeItem {
  const _PracticeItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
}

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid({required this.items});

  final List<_PracticeItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final oneColumn =
            constraints.maxWidth < 430 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;
        final cardWidth = oneColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _CompactPracticeCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _CompactPracticeCard extends StatelessWidget {
  const _CompactPracticeCard({required this.item});

  final _PracticeItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F3EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 28, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
