import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
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
          onPressed: () => context.go(AppRoutes.accessibilitySettings),
          icon: const Icon(Icons.settings_outlined),
          tooltip: '화면 설정',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('오늘도 천천히 연습해볼까요?', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          _HomeMessageCard(
            title: '오늘의 연습',
            message: '편한 항목부터 하나씩 시작해보세요.',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 28),
          _HomeFeatureCard(
            title: '카페 키오스크 연습',
            message: '음료를 주문하는 순서를 연습해요.',
            icon: Icons.local_cafe_outlined,
            onPressed: () => context.go(AppRoutes.cafeStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '햄버거 주문 연습',
            message: '메뉴와 세트를 고르는 방법을 연습해요.',
            icon: Icons.lunch_dining_outlined,
            onPressed: () => context.go(AppRoutes.hamburgerStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '병원 접수 연습',
            message: '병원에서 접수하는 순서를 연습해요.',
            icon: Icons.local_hospital_outlined,
            onPressed: () => context.go(AppRoutes.hospitalStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '사진 보내기 연습',
            message: '사진을 골라 보내는 방법을 연습해요.',
            icon: Icons.photo_outlined,
            onPressed: () => context.go(AppRoutes.photoStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '기차표 예매 연습',
            message: '기차표를 예매하는 순서를 연습해요.',
            icon: Icons.train_outlined,
            onPressed: () => context.go(AppRoutes.trainStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: 'ATM 출금 연습',
            message: 'ATM에서 돈을 찾는 순서를 연습해요.',
            icon: Icons.account_balance_outlined,
            onPressed: () => context.go(AppRoutes.atmStart),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '무인민원발급기 연습',
            message: '필요한 서류를 고르는 방법을 연습해요.',
            icon: Icons.description_outlined,
            onPressed: () => context.go(AppRoutes.civilDocumentStart),
          ),
          const SizedBox(height: 28),
          _ProgressCard(
            points: context.watch<LearningProgressProvider>().totalPoints,
            onPressed: () => context.go(AppRoutes.progress),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.points, required this.onPressed});

  final int points;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: const Color(0xFFDDF2E7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7DB79B), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 42,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 디지털 걸음',
                      softWrap: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '연습한 기록과 모은 포인트를 확인해요.',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 $points점',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
