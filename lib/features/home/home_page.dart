import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../../shared/widgets/page_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이 기능은 준비 중이에요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('한걸음 디지털', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            '안녕하세요, 오늘도 천천히 연습해볼까요?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          _HomeMessageCard(
            title: '오늘의 연습',
            message: '천천히 따라 해보세요.\n한 단계씩 연습하면 충분해요.',
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 16),
          _HomeFeatureCard(
            title: '카페 키오스크 연습하기',
            message: '화면을 보며 주문 순서를 연습해요.',
            icon: Icons.local_cafe_outlined,
            onPressed: () => context.go(AppRoutes.cafeStart),
          ),
          const SizedBox(height: 16),
          _HomeMessageCard(
            title: '나의 디지털 걸음',
            message:
                '현재 포인트: ${progress.totalPoints}점\n'
                '카페 따라 해보기: ${progress.guidedCompletionCount}회\n'
                '카페 혼자 해보기: ${progress.soloCompletionCount}회\n\n'
                '한 번씩 연습할수록 디지털 자신감이 자라요.',
            icon: Icons.emoji_events_outlined,
          ),
          const SizedBox(height: 26),
          Text(
            '다른 연습도 준비하고 있어요',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          _HomeFeatureCard(
            title: '병원 접수 연습하기',
            message: '이 기능은 준비 중이에요.',
            icon: Icons.local_hospital_outlined,
            secondary: true,
            onPressed: () => _showComingSoon(context),
          ),
          const SizedBox(height: 12),
          _HomeFeatureCard(
            title: '사진 보내기 연습하기',
            message: '이 기능은 준비 중이에요.',
            icon: Icons.photo_outlined,
            secondary: true,
            onPressed: () => _showComingSoon(context),
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
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
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
    this.secondary = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = secondary
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 42),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(message, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}
