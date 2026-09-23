import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'atm_mission.dart';

class AtmPracticePage extends StatefulWidget {
  const AtmPracticePage({super.key});

  @override
  State<AtmPracticePage> createState() => _AtmPracticePageState();
}

class _AtmPracticePageState extends State<AtmPracticePage> {
  int _step = 1;
  bool _isCompleting = false;

  Future<void> _restart() async {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isAtmSoloMode) {
      await progress.startAtmLearning(AtmLearningMode.solo);
      if (mounted) context.go(AppRoutes.atmMission);
      return;
    }
    await progress.startAtmLearning(AtmLearningMode.guided);
    if (mounted) setState(() => _step = 1);
  }

  void _previous() {
    if (_step == 1) {
      final progress = context.read<LearningProgressProvider>();
      context.go(
        progress.isAtmSoloMode ? AppRoutes.atmMission : AppRoutes.atmStart,
      );
      return;
    }
    setState(() => _step -= 1);
  }

  void _finish() {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    context.go(AppRoutes.atmComplete);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isAtmSoloMode;
    final guidance = switch (_step) {
      1 => isSolo ? '카드를 넣고 순서를 시작해보세요.' : '먼저 ATM에 카드를 넣어볼까요?',
      2 => isSolo ? '오늘의 업무를 선택해보세요.' : '원하는 업무를 골라볼까요?',
      3 => isSolo ? '오늘 찾을 금액을 선택해보세요.' : '찾을 금액을 골라볼까요?',
      4 => isSolo ? '마지막으로 금액을 확인해볼까요?' : '출금 내용을 확인해볼까요?',
      _ => isSolo ? '마지막으로 카드와 현금을 챙겨볼까요?' : '카드와 돈을 모두 챙겨볼까요?',
    };
    final question = switch (_step) {
      1 => '카드를 어떻게 할까요?',
      2 => '무엇을 하시겠어요?',
      3 => '얼마를 찾으시겠어요?',
      4 => '출금 내용을 확인해볼까요?',
      _ => '무엇을 먼저 챙길까요?',
    };

    return LearningStepLayout(
      title: 'ATM 출금 연습',
      step: _step,
      totalSteps: 5,
      customPanel: true,
      guidance: guidance,
      question: question,
      onBack: _previous,
      onPrevious: _previous,
      onRestart: _restart,
      onHint: isSolo ? () => AtmMission.showHint(context) : null,
      guidanceDetail: isSolo ? '미션을 기억하고 직접 골라보세요.' : '화면의 안내를 보고 선택해보세요.',
      questionInGuidance: true,
      child: _AtmPanel(child: _buildStep(progress)),
    );
  }

  Widget _buildStep(LearningProgressProvider progress) {
    switch (_step) {
      case 1:
        return Column(
          children: [
            LearningChoiceCard(
              label: '카드를 넣을게요',
              icon: Icons.credit_card_outlined,
              calmStyle: true,
              visualState: progress.isAtmSoloMode
                  ? LearningChoiceVisualState.normal
                  : LearningChoiceVisualState.guided,
              onPressed: () => _moveToStep(2),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '도움이 필요해요',
              icon: Icons.help_outline_rounded,
              secondary: true,
              calmStyle: true,
              onPressed: () => _showCardGuide(progress),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            LearningChoiceCard(
              label: '돈을 찾을게요',
              icon: Icons.payments_outlined,
              calmStyle: true,
              visualState: progress.isAtmSoloMode
                  ? LearningChoiceVisualState.normal
                  : LearningChoiceVisualState.guided,
              onPressed: () => _moveToStep(3),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '잔액을 확인할게요',
              icon: Icons.account_balance_wallet_outlined,
              secondary: true,
              calmStyle: true,
              onPressed: () => _showWithdrawalGuide(progress),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            for (final amount in const ['3만 원', '5만 원', '10만 원']) ...[
              LearningChoiceCard(
                label: amount,
                icon: Icons.payments_outlined,
                calmStyle: true,
                visualState:
                    !progress.isAtmSoloMode && amount == AtmMission.amount
                    ? LearningChoiceVisualState.guided
                    : LearningChoiceVisualState.normal,
                onPressed: () => _selectAmount(progress, amount),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LearningSummaryCard(
              title: '출금 내용',
              icon: Icons.receipt_long_outlined,
              items: [
                LearningSummaryItem(
                  label: '출금 금액',
                  value: progress.atmAmount ?? '',
                ),
                const LearningSummaryItem(label: '수수료', value: '없음'),
                LearningSummaryItem(
                  label: '받을 금액',
                  value: progress.atmAmount ?? '',
                ),
              ],
              footer: '실제 거래가 아닌 연습용 화면이에요.',
            ),
            const SizedBox(height: 22),
            if (progress.isAtmSoloMode)
              FilledButton.icon(
                onPressed: () => _moveToStep(5),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('출금 확인'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(72),
                ),
              )
            else ...[
              FilledButton.icon(
                onPressed: () => _moveToStep(5),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('맞아요, 출금할게요'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(72),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('처음부터 다시 하기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(72),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      default:
        if (progress.isAtmSoloMode) {
          return LearningChoiceCard(
            label: '카드와 현금을 챙길게요',
            icon: Icons.wallet_outlined,
            calmStyle: true,
            onPressed: _finish,
          );
        }
        return Column(
          children: [
            LearningChoiceCard(
              label: '카드와 돈을 챙겼어요',
              icon: Icons.wallet_outlined,
              calmStyle: true,
              visualState: LearningChoiceVisualState.guided,
              onPressed: _finish,
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '카드만 챙겼어요',
              icon: Icons.credit_card_outlined,
              secondary: true,
              calmStyle: true,
              onPressed: _showCashGuide,
            ),
          ],
        );
    }
  }

  void _selectAmount(LearningProgressProvider progress, String amount) {
    if (progress.isAtmSoloMode && amount != AtmMission.amount) {
      _showMissionReminder();
      return;
    }
    progress.selectAtmAmount(amount);
    _moveToStep(4);
  }

  void _moveToStep(int step) {
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _step = step);
  }

  void _showWithdrawalGuide(LearningProgressProvider progress) {
    if (progress.isAtmSoloMode) {
      _showMissionReminder();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이번에는 돈을 찾는 연습을 해볼까요?')));
  }

  void _showCardGuide(LearningProgressProvider progress) {
    if (progress.isAtmSoloMode) {
      _showMissionReminder();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('괜찮아요. 카드를 넣는 것부터 천천히 해볼까요?')));
  }

  void _showCashGuide() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('돈도 함께 챙기면 더 안전해요.')));
  }

  void _showMissionReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '괜찮아요. 오늘의 출금 내용을 다시 확인해볼까요?\n'
          '힌트 보기를 누르면 출금 내용을 확인할 수 있어요.',
        ),
      ),
    );
  }
}

class _AtmPanel extends StatelessWidget {
  const _AtmPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.local_atm_outlined, size: 34, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '연습용 ATM 화면',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.lock_outline_rounded),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FBF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: child,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors.onSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              const Icon(Icons.credit_card_outlined, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}
