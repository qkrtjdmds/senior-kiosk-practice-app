import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';
import 'learning_progress_provider.dart';
import 'widgets/learning_widgets.dart';

class CafeStartPage extends StatelessWidget {
  const CafeStartPage({super.key});

  void _selectMode(BuildContext context, CafeLearningMode mode) {
    context.read<LearningProgressProvider>().selectMode(mode);
    context.go(
      mode == CafeLearningMode.solo
          ? AppRoutes.cafeMission
          : AppRoutes.cafeStepOne,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '카페 키오스크 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('카페 키오스크 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '음료를 주문하는 순서를 천천히 연습해요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F3EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9FCBB4)),
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_cafe_outlined,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '주문 화면을 보며 차근차근 연습해볼까요?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LearningModeCard(
            title: '따라 해보기',
            description: '화면의 안내를 보며 하나씩 연습해요.',
            icon: Icons.menu_book_outlined,
            onPressed: () => _selectMode(context, CafeLearningMode.guided),
          ),
          const SizedBox(height: 18),
          LearningModeCard(
            title: '혼자 해보기',
            description: '오늘의 미션을 기억하고 직접 골라봐요.',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () => _selectMode(context, CafeLearningMode.solo),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
            label: const Text('홈으로 돌아가기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(62),
            ),
          ),
        ],
      ),
    );
  }
}
