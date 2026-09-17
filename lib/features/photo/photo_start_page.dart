import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../learning/learning_progress_provider.dart';

class PhotoStartPage extends StatelessWidget {
  const PhotoStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '사진 보내기 연습',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('사진 보내기 연습', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Text(
            '가족이나 친구에게 사진을 보내는 순서를 천천히 연습해볼 수 있어요.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 18),
                Text('연습용 휴대폰', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '사진과 짧은 인사를 골라\n천천히 보내보세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          LargeActionButton(
            label: '따라 해보기',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              context.read<LearningProgressProvider>().selectPhotoMode(
                PhotoLearningMode.guided,
              );
              context.go(AppRoutes.photoStepOne);
            },
          ),
          const SizedBox(height: 18),
          Text(
            '화면의 안내를 보며 천천히 사진 보내는 순서를 연습해요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          LargeActionButton(
            label: '혼자 해보기',
            icon: Icons.self_improvement_outlined,
            secondary: true,
            onPressed: () {
              context.read<LearningProgressProvider>().selectPhotoMode(
                PhotoLearningMode.solo,
              );
              context.go(AppRoutes.photoMission);
            },
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 사진 보내기 미션을 기억하고 직접 해봐요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          LargeActionButton(
            label: '홈으로 돌아가기',
            icon: Icons.home_outlined,
            secondary: true,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}
