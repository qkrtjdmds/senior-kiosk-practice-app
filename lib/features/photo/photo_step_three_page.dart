import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'photo_mission.dart';

class PhotoStepThreePage extends StatelessWidget {
  const PhotoStepThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isPhotoSoloMode;

    return LearningStepLayout(
      title: '사진 보내기 연습',
      step: 3,
      guidance: isSolo ? '메시지를 선택해보세요.' : '사진과 함께 짧은 인사를 보내볼까요?',
      question: '어떤 말을 함께 보낼까요?',
      phonePanel: true,
      onBack: () => context.go(AppRoutes.photoStepTwo),
      onPrevious: () => context.go(AppRoutes.photoStepTwo),
      onRestart: () {
        context.read<LearningProgressProvider>().resetPhotoLearning();
        context.go(AppRoutes.photoStepOne);
      },
      onHint: isSolo ? () => showPhotoMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MessageChoice(
            label: '사진 보세요!',
            highlighted: !isSolo,
            onPressed: () => _select(context, '사진 보세요!'),
          ),
          const SizedBox(height: 16),
          _MessageChoice(
            label: '오늘 즐거웠어요.',
            highlighted: !isSolo,
            onPressed: () => _select(context, '오늘 즐거웠어요.'),
          ),
          const SizedBox(height: 16),
          _MessageChoice(
            label: '건강 잘 챙기세요.',
            highlighted: !isSolo,
            onPressed: () => _select(context, '건강 잘 챙기세요.'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String message) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isPhotoSoloMode &&
        !PhotoMission.today.isCorrect(PhotoMissionStep.message, message)) {
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
    progress.selectPhotoMessage(message);
    context.go(AppRoutes.photoStepFour);
  }
}

class _MessageChoice extends StatelessWidget {
  const _MessageChoice({
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return LearningChoiceCard(
      label: label,
      icon: Icons.chat_bubble_outline_rounded,
      secondary: true,
      highlighted: highlighted,
      onPressed: onPressed,
    );
  }
}
