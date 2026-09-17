import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'photo_mission.dart';

class PhotoStepTwoPage extends StatelessWidget {
  const PhotoStepTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isPhotoSoloMode;

    return LearningStepLayout(
      title: '사진 보내기 연습',
      step: 2,
      guidance: isSolo ? '사진을 선택해보세요.' : '이제 보내고 싶은 사진을 골라볼까요?',
      question: '어떤 사진을 보낼까요?',
      phonePanel: true,
      onBack: () => context.go(AppRoutes.photoStepOne),
      onPrevious: () => context.go(AppRoutes.photoStepOne),
      onRestart: () {
        context.read<LearningProgressProvider>().resetPhotoLearning();
        context.go(AppRoutes.photoStepOne);
      },
      onHint: isSolo ? () => showPhotoMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoChoice(
            label: '꽃 사진',
            icon: Icons.local_florist_outlined,
            highlighted: !isSolo,
            onPressed: () => _select(context, '꽃 사진'),
          ),
          const SizedBox(height: 16),
          _PhotoChoice(
            label: '맛있는 음식 사진',
            icon: Icons.restaurant_outlined,
            highlighted: !isSolo,
            onPressed: () => _select(context, '맛있는 음식 사진'),
          ),
          const SizedBox(height: 16),
          _PhotoChoice(
            label: '여행 사진',
            icon: Icons.landscape_outlined,
            highlighted: !isSolo,
            onPressed: () => _select(context, '여행 사진'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String photo) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isPhotoSoloMode &&
        !PhotoMission.today.isCorrect(PhotoMissionStep.photo, photo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '괜찮아요. 오늘 보낼 내용을 다시 확인해볼까요?\n'
            '힌트 보기를 누르면 보낼 내용을 확인할 수 있어요.',
          ),
        ),
      );
      return;
    }
    progress.selectPhoto(photo);
    context.go(AppRoutes.photoStepThree);
  }
}

class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return LearningChoiceCard(
      label: label,
      icon: icon,
      secondary: true,
      highlighted: highlighted,
      onPressed: onPressed,
    );
  }
}
