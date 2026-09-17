import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'photo_mission.dart';

class PhotoStepOnePage extends StatelessWidget {
  const PhotoStepOnePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSolo = context.watch<LearningProgressProvider>().isPhotoSoloMode;

    return LearningStepLayout(
      title: '사진 보내기 연습',
      step: 1,
      guidance: isSolo ? '받는 사람을 선택해보세요.' : '먼저 사진을 보낼 사람을 골라볼까요?',
      question: '누구에게 사진을 보낼까요?',
      phonePanel: true,
      onBack: () => context.go(AppRoutes.photoStart),
      onPrevious: () => context.go(AppRoutes.photoStart),
      onRestart: () {
        context.read<LearningProgressProvider>().resetPhotoLearning();
        context.go(AppRoutes.photoStepOne);
      },
      onHint: isSolo ? () => showPhotoMissionHint(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LearningChoiceCard(
            label: '가족에게 보낼게요',
            icon: Icons.people_outline_rounded,
            highlighted: !isSolo,
            onPressed: () => _select(context, '가족'),
          ),
          const SizedBox(height: 16),
          LearningChoiceCard(
            label: '친구에게 보낼게요',
            icon: Icons.person_outline_rounded,
            secondary: true,
            highlighted: !isSolo,
            onPressed: () => _select(context, '친구'),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, String recipient) {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isPhotoSoloMode &&
        !PhotoMission.today.isCorrect(PhotoMissionStep.recipient, recipient)) {
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
    progress.selectPhotoRecipient(recipient);
    context.go(AppRoutes.photoStepTwo);
  }
}
