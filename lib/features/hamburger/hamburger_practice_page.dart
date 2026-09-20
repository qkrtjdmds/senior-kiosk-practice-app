import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'hamburger_mission.dart';

class HamburgerPracticePage extends StatefulWidget {
  const HamburgerPracticePage({super.key});

  @override
  State<HamburgerPracticePage> createState() => _HamburgerPracticePageState();
}

class _HamburgerPracticePageState extends State<HamburgerPracticePage> {
  int _step = 1;
  bool _isCompleting = false;

  void _restart() {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isHamburgerSoloMode) {
      progress.startHamburgerSoloMission().then((_) {
        if (mounted) context.go(AppRoutes.hamburgerMission);
      });
      return;
    }
    progress.resetHamburgerLearning();
    setState(() => _step = 1);
  }

  void _previous() {
    if (_step == 1) {
      final progress = context.read<LearningProgressProvider>();
      context.go(
        progress.isHamburgerSoloMode
            ? AppRoutes.hamburgerMission
            : AppRoutes.hamburgerStart,
      );
      return;
    }
    setState(() => _step -= 1);
  }

  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    if (mounted) context.go(AppRoutes.hamburgerComplete);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isHamburgerSoloMode;
    final mission = progress.currentHamburgerMission;
    final guidance = switch (_step) {
      1 => isSolo ? '주문 방법을 선택해보세요.' : '먼저 어디에서 드실지 골라볼까요?',
      2 => isSolo ? '햄버거를 선택해보세요.' : '먹고 싶은 햄버거를 골라볼까요?',
      3 => isSolo ? '세트와 음료를 선택해보세요.' : '세트 메뉴와 음료를 골라볼까요?',
      _ => '선택한 메뉴가 맞는지 천천히 살펴보세요.',
    };
    final question = switch (_step) {
      1 => '매장에서 드시나요, 포장하시나요?',
      2 => '어떤 햄버거를 선택할까요?',
      3 => '어떻게 주문할까요?',
      _ => '주문 내용을 확인해볼까요?',
    };

    return LearningStepLayout(
      title: '햄버거 주문 연습',
      step: _step,
      guidance: guidance,
      question: question,
      onBack: _previous,
      onPrevious: _previous,
      onRestart: _restart,
      onHint: isSolo ? () => showHamburgerMissionHint(context, mission) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KioskHeading(step: _step),
          const SizedBox(height: 16),
          if (_step > 1) ...[
            _MiniCart(progress: progress),
            const SizedBox(height: 18),
          ],
          _buildStep(progress),
        ],
      ),
    );
  }

  Widget _buildStep(LearningProgressProvider progress) {
    switch (_step) {
      case 1:
        return Column(
          children: [
            LearningChoiceCard(
              label: '매장에서 먹을게요',
              icon: Icons.restaurant_outlined,
              highlighted: !progress.isHamburgerSoloMode,
              onPressed: () => _selectDineOption(progress, '매장 식사'),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '포장할게요',
              icon: Icons.shopping_bag_outlined,
              onPressed: () => _selectDineOption(progress, '포장'),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _MenuChoice(
              label: '치즈버거',
              icon: Icons.lunch_dining,
              color: const Color(0xFFFFD166),
              onPressed: () => _selectMenu(progress, '치즈버거'),
            ),
            const SizedBox(height: 14),
            _MenuChoice(
              label: '불고기버거',
              icon: Icons.lunch_dining,
              color: const Color(0xFFEF8354),
              onPressed: () => _selectMenu(progress, '불고기버거'),
            ),
            const SizedBox(height: 14),
            _MenuChoice(
              label: '새우버거',
              icon: Icons.lunch_dining,
              color: const Color(0xFF6CC4A1),
              onPressed: () => _selectMenu(progress, '새우버거'),
            ),
          ],
        );
      case 3:
        if (progress.hamburgerIsSet == true) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('음료를 골라주세요', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              for (final drink in const [
                ('콜라', Icons.local_drink_outlined),
                ('사이다', Icons.local_drink_outlined),
                ('물', Icons.water_drop_outlined),
              ]) ...[
                LearningChoiceCard(
                  label: drink.$1,
                  icon: drink.$2,
                  onPressed: () => _selectDrink(progress, drink.$1),
                ),
                const SizedBox(height: 14),
              ],
              TextButton.icon(
                onPressed: () => _selectOrderType(progress, false),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('햄버거만 주문하기'),
              ),
            ],
          );
        }
        return Column(
          children: [
            LearningChoiceCard(
              label: '세트로 주문할게요',
              icon: Icons.fastfood_outlined,
              highlighted: !progress.isHamburgerSoloMode,
              onPressed: () => _selectOrderType(progress, true),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '햄버거만 주문할게요',
              icon: Icons.lunch_dining_outlined,
              onPressed: () => _selectOrderType(progress, false),
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OrderSummary(progress: progress),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _isCompleting ? null : _complete,
              icon: const Icon(Icons.payment_outlined),
              label: Text(_isCompleting ? '완료하는 중이에요' : '결제하기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(72),
              ),
            ),
          ],
        );
    }
  }

  void _selectMenu(LearningProgressProvider progress, String menu) {
    if (progress.isHamburgerSoloMode &&
        !progress.currentHamburgerMission.isCorrect(
          HamburgerMissionStep.menu,
          menu,
        )) {
      _showReminder();
      return;
    }
    progress.selectHamburgerMenu(menu);
    setState(() => _step = 3);
  }

  void _selectDineOption(LearningProgressProvider progress, String dineOption) {
    if (progress.isHamburgerSoloMode &&
        !progress.currentHamburgerMission.isCorrect(
          HamburgerMissionStep.dineOption,
          dineOption,
        )) {
      _showReminder();
      return;
    }
    progress.selectHamburgerDineOption(dineOption);
    setState(() => _step = 2);
  }

  void _selectOrderType(LearningProgressProvider progress, bool isSet) {
    if (progress.isHamburgerSoloMode &&
        !progress.currentHamburgerMission.isCorrect(
          HamburgerMissionStep.orderType,
          isSet,
        )) {
      _showReminder();
      return;
    }
    progress.selectHamburgerOrderType(isSet);
    if (!isSet) {
      setState(() => _step = 4);
    }
  }

  void _selectDrink(LearningProgressProvider progress, String drink) {
    if (progress.isHamburgerSoloMode &&
        !progress.currentHamburgerMission.isCorrect(
          HamburgerMissionStep.drink,
          drink,
        )) {
      _showReminder();
      return;
    }
    progress.selectHamburgerDrink(drink);
    setState(() => _step = 4);
  }

  void _showReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '괜찮아요. 오늘의 주문 내용을 다시 확인해볼까요?\n'
          '힌트 보기를 누르면 주문 내용을 확인할 수 있어요.',
        ),
      ),
    );
  }
}

class _KioskHeading extends StatelessWidget {
  const _KioskHeading({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.tablet_mac_outlined,
          size: 34,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step == 4 ? '내 장바구니' : '연습용 메뉴판',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Icon(Icons.shopping_cart_outlined, size: 30),
      ],
    );
  }
}

class _MiniCart extends StatelessWidget {
  const _MiniCart({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final items = <String>[
      if (progress.hamburgerDineOption != null) progress.hamburgerDineOption!,
      if (progress.hamburgerMenu != null) progress.hamburgerMenu!,
      if (progress.hamburgerIsSet != null)
        progress.hamburgerIsSet! ? '세트' : '단품',
      if (progress.hamburgerDrink != null) progress.hamburgerDrink!,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shopping_cart_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              items.isEmpty ? '장바구니가 비어 있어요' : items.join(' · '),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuChoice extends StatelessWidget {
  const _MenuChoice({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 38),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.add_shopping_cart_outlined, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.progress});

  final LearningProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final mission = progress.currentHamburgerMission;
    final isSolo = progress.isHamburgerSoloMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: '이용 방법',
            value: isSolo
                ? mission.dineLabel
                : progress.hamburgerDineOption ?? '',
          ),
          _SummaryRow(label: '햄버거', value: progress.hamburgerMenu ?? ''),
          _SummaryRow(
            label: '세트 여부',
            value: isSolo
                ? mission.orderLabel
                : progress.hamburgerIsSet == true
                ? '세트'
                : '햄버거만',
          ),
          _SummaryRow(
            label: '음료',
            value: isSolo
                ? mission.drink ?? '선택하지 않음'
                : progress.hamburgerIsSet == true
                ? progress.hamburgerDrink ?? ''
                : '선택하지 않음',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
