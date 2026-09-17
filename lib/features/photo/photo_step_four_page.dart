import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'photo_mission.dart';

class PhotoStepFourPage extends StatelessWidget {
  const PhotoStepFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();

    return LearningStepLayout(
      title: '사진 보내기 연습',
      step: 4,
      guidance: progress.isPhotoSoloMode
          ? '보낼 내용을 확인해보세요.'
          : '마지막으로 보낼 내용을 확인해볼까요?',
      question: '보낼 내용을 확인해볼까요?',
      phonePanel: true,
      onBack: () => context.go(AppRoutes.photoStepThree),
      onPrevious: () => context.go(AppRoutes.photoStepThree),
      onRestart: () {
        context.read<LearningProgressProvider>().resetPhotoLearning();
        context.go(AppRoutes.photoStepOne);
      },
      child: _PhotoMessagePanel(progress: progress),
    );
  }
}

class _PhotoMessagePanel extends StatelessWidget {
  const _PhotoMessagePanel({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MessageRow(
          label: '받는 사람',
          value: progress.photoRecipient ?? '선택하지 않았어요',
        ),
        _MessageRow(
          label: '선택한 사진',
          value: progress.photoSelection ?? '선택하지 않았어요',
        ),
        _MessageRow(label: '메시지', value: progress.photoMessage ?? '선택하지 않았어요'),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            final mission = PhotoMission.today;
            final complete =
                mission.isCorrect(
                  PhotoMissionStep.recipient,
                  progress.photoRecipient ?? '',
                ) &&
                mission.isCorrect(
                  PhotoMissionStep.photo,
                  progress.photoSelection ?? '',
                ) &&
                mission.isCorrect(
                  PhotoMissionStep.message,
                  progress.photoMessage ?? '',
                );
            if (progress.isPhotoSoloMode && !complete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('괜찮아요. 이전 단계에서 보낼 내용을 다시 선택해볼 수 있어요.'),
                ),
              );
              return;
            }
            context.go(AppRoutes.photoComplete);
          },
          icon: const Icon(Icons.send_outlined, size: 30),
          label: const Text('사진 보내기'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(78),
            textStyle: Theme.of(context).textTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
