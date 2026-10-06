import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'burger_kiosk_widgets.dart';
import 'burger_order_provider.dart';
import 'burger_scenario.dart';

class BurgerV2StartPage extends StatelessWidget {
  const BurgerV2StartPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: burgerIvory,
    appBar: AppBar(
      leading: IconButton(
        tooltip: '이전 화면으로 돌아가기',
        onPressed: () => context.go(AppRoutes.home),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text('햄버거 주문 연습'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lunch_dining_outlined,
              size: 72,
              color: burgerGreen,
            ),
            const SizedBox(height: 16),
            Text(
              '가상 키오스크로 주문 순서를 천천히 연습해요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 28),
            BurgerChoice(
              label: '따라 해보기',
              subtitle: '화면의 안내를 보며 하나씩 주문해요.',
              icon: Icons.menu_book_outlined,
              onTap: () {
                context.read<LearningProgressProvider>().selectHamburgerMode(
                  HamburgerLearningMode.guided,
                );
                context.read<BurgerOrderProvider>().begin(
                  HamburgerLearningMode.guided,
                );
                context.go(AppRoutes.hamburgerPractice);
              },
            ),
            const SizedBox(height: 16),
            BurgerChoice(
              label: '혼자 해보기',
              subtitle: '오늘의 주문 미션을 기억하고 직접 해봐요.',
              icon: Icons.self_improvement_outlined,
              onTap: () async {
                await context
                    .read<LearningProgressProvider>()
                    .startHamburgerSoloMission();
                if (!context.mounted) return;
                context.read<BurgerOrderProvider>().begin(
                  HamburgerLearningMode.solo,
                );
                context.go(AppRoutes.hamburgerMission);
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_outlined),
              label: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}

class BurgerV2MissionPage extends StatelessWidget {
  const BurgerV2MissionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final mission = context
        .watch<LearningProgressProvider>()
        .currentHamburgerMission;
    void leaveMission() {
      context.read<DailyMissionProvider>().cancelActiveMission();
      context.go(AppRoutes.hamburgerStart);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveMission();
      },
      child: Scaffold(
        backgroundColor: burgerIvory,
        appBar: AppBar(
          leading: IconButton(
            tooltip: '이전 화면으로 돌아가기',
            onPressed: leaveMission,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('오늘의 햄버거 주문 미션'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD8D4C9)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        size: 54,
                        color: burgerOrange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        BurgerScenario.fromMissionId(mission.id).title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        BurgerScenario.fromMissionId(mission.id).summary,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '주문 내용을 기억하고 직접 선택해 보세요.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    context.read<BurgerOrderProvider>().begin(
                      HamburgerLearningMode.solo,
                    );
                    context.go(AppRoutes.hamburgerPractice);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('혼자 주문해보기'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: leaveMission,
                  child: const Text('햄버거 주문 연습으로 돌아가기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BurgerV2OrderPage extends StatelessWidget {
  const BurgerV2OrderPage({super.key});
  @override
  Widget build(BuildContext context) {
    final order = context.watch<BurgerOrderProvider>();
    void goBack() {
      if (order.step == BurgerOrderStep.dine) {
        context.go(
          order.isSolo ? AppRoutes.hamburgerMission : AppRoutes.hamburgerStart,
        );
      } else {
        order.previous();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: BurgerKioskScaffold(
        onBack: goBack,
        summary: order.summary,
        cartCount: order.cartCount,
        step: order.step.index + 1,
        totalSteps: BurgerOrderStep.values.length,
        modeLabel: practiceSessionLabel(
          isFreePractice: order.isFreePractice,
          isSolo: order.isSolo,
        ),
        bottom: _bottom(context, order),
        child: _body(context, order),
      ),
    );
  }

  Widget _body(BuildContext context, BurgerOrderProvider order) =>
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _question(order.step),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              order.isFreePractice
                  ? '원하는 항목을 자유롭게 골라보세요.'
                  : order.isSolo
                  ? '미션을 기억하고 직접 골라보세요.'
                  : _guided(order.step),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (order.inlineMessage != null) ...[
              const SizedBox(height: 12),
              BurgerInlineNotice(order.inlineMessage!),
            ],
            if (order.showHint) ...[
              const SizedBox(height: 12),
              BurgerInlineNotice(_hint(context, order)),
            ],
            const SizedBox(height: 22),
            _choices(context, order),
          ],
        ),
      );

  Widget _choices(BuildContext context, BurgerOrderProvider order) {
    final mission = context
        .read<LearningProgressProvider>()
        .currentHamburgerMission;
    switch (order.step) {
      case BurgerOrderStep.dine:
        return _list(
          ['매장에서 먹기', '포장하기'],
          [Icons.restaurant, Icons.shopping_bag_outlined],
          (v) => order.chooseDine(
            v,
            correct: order.isSolo
                ? v == BurgerScenario.fromMissionId(mission.id).dine
                : v == '포장하기',
          ),
        );
      case BurgerOrderStep.menu:
        return LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final ratio = textScale > 1.2
                ? .72
                : constraints.maxWidth < 360
                ? .82
                : .94;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BurgerOrderProvider.menus.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: ratio,
              ),
              itemBuilder: (_, i) {
                final menu = BurgerOrderProvider.menus[i];
                return BurgerMenuTile(
                  name: menu.name,
                  description: menu.description,
                  price: won(menu.price),
                  onTap: () => order.chooseMenu(
                    menu,
                    correct: order.isSolo
                        ? menu.name ==
                              BurgerScenario.fromMissionId(mission.id).menu
                        : menu.name == '불고기버거',
                  ),
                );
              },
            );
          },
        );
      case BurgerOrderStep.type:
        return _list(
          ['햄버거만 주문', '세트로 주문'],
          [Icons.lunch_dining_outlined, Icons.fastfood_outlined],
          (v) => order.chooseType(
            v.startsWith('세트') ? BurgerOrderType.set : BurgerOrderType.single,
            correct: order.isSolo
                ? BurgerScenario.fromMissionId(mission.id).type ==
                      (v.startsWith('세트')
                          ? BurgerOrderType.set
                          : BurgerOrderType.single)
                : v.startsWith('세트'),
          ),
          subtitles: ['선택한 햄버거만 받아요.', '사이드와 음료가 함께 나와요. +2,500원'],
        );
      case BurgerOrderStep.side:
        return _list(
          BurgerOrderProvider.sides,
          List.filled(5, Icons.fastfood_outlined),
          (v) => order.chooseSide(
            v,
            correct: order.isSolo
                ? BurgerScenario.fromMissionId(mission.id).side == v
                : v == '감자튀김',
          ),
        );
      case BurgerOrderStep.drink:
        return _list(
          BurgerOrderProvider.drinks,
          List.filled(6, Icons.local_drink_outlined),
          (v) => order.chooseDrink(
            v,
            correct: order.isSolo
                ? BurgerScenario.fromMissionId(mission.id).drink == v
                : v == '콜라',
          ),
        );
      case BurgerOrderStep.extras:
        return Column(
          children: BurgerOrderProvider.extraPrices.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BurgerChoice(
                    label: e.key,
                    subtitle: e.value == 0 ? '추가 금액 없음' : '+${won(e.value)}',
                    icon: Icons.add_circle_outline,
                    selected: order.extras.contains(e.key),
                    onTap: () => order.toggleExtra(e.key),
                  ),
                ),
              )
              .toList(),
        );
      case BurgerOrderStep.cart:
        if (order.cart.isEmpty) {
          return const BurgerInlineNotice('장바구니가 비어 있어요. 메뉴를 먼저 골라주세요.');
        }
        return Column(
          children: [
            for (var i = 0; i < order.cart.length; i++)
              _cartRow(context, order, i),
            const Divider(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '총 가상 금액 ${won(order.totalPrice)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        );
      case BurgerOrderStep.point:
        return _list(
          ['전화번호로 적립', '간편 적립', '적립하지 않기'],
          [
            Icons.phone_outlined,
            Icons.touch_app_outlined,
            Icons.not_interested,
          ],
          (v) => order.choosePoint(
            v,
            correct: order.isSolo
                ? BurgerScenario.fromMissionId(mission.id).point == v
                : v == '적립하지 않기',
          ),
          subtitles: const [
            '실제 번호는 입력하지 않아요.',
            '실제 계정과 연결하지 않아요.',
            '적립을 건너뛰어요.',
          ],
        );
      case BurgerOrderStep.payment:
        return _list(
          ['카드', '간편결제', '현금'],
          [Icons.credit_card, Icons.phone_android, Icons.payments_outlined],
          (v) {
            order.choosePayment(
              v,
              correct: order.isSolo
                  ? BurgerScenario.fromMissionId(mission.id).payment == v
                  : v == '카드',
            );
          },
          subtitles: const [
            '실제 카드 정보는 입력하지 않아요.',
            '실제 결제 서비스와 연결하지 않아요.',
            '실제 현금을 받지 않아요.',
          ],
          selectedLabel: order.paymentMethod,
        );
    }
  }

  Widget _bottom(BuildContext context, BurgerOrderProvider order) {
    if (order.step == BurgerOrderStep.payment) {
      return FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        onPressed: order.paymentMethod == null
            ? null
            : () => context.go(AppRoutes.hamburgerComplete),
        child: const Text('결제 연습 완료하기'),
      );
    }
    if (order.step == BurgerOrderStep.cart) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: order.addAnother,
            child: const Text('메뉴 더 담기'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: order.cart.isEmpty ? null : order.proceedFromCart,
            child: const Text('주문 확인하기'),
          ),
        ],
      );
    }
    if (order.step == BurgerOrderStep.extras) {
      return FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        onPressed: () {
          final mission = context
              .read<LearningProgressProvider>()
              .currentHamburgerMission;
          final target = BurgerScenario.fromMissionId(mission.id).extras;
          if (order.validateExtras(target)) order.addToCart();
        },
        child: const Text('장바구니에 담기'),
      );
    }
    return Row(
      children: [
        if (order.isSolo)
          Expanded(
            child: TextButton.icon(
              onPressed: order.revealHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('힌트 보기'),
            ),
          ),
        if (order.isSolo) const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: order.resetOrder,
            child: const Text('처음부터 다시 하기'),
          ),
        ),
      ],
    );
  }

  Widget _list(
    List<String> labels,
    List<IconData> icons,
    void Function(String) onTap, {
    List<String>? subtitles,
    String? selectedLabel,
  }) => Column(
    children: [
      for (var i = 0; i < labels.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BurgerChoice(
            label: labels[i],
            subtitle: subtitles?[i],
            icon: icons[i],
            selected: labels[i] == selectedLabel,
            onTap: () => onTap(labels[i]),
          ),
        ),
    ],
  );
  Widget _cartRow(BuildContext context, BurgerOrderProvider order, int index) {
    final item = order.cart[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menu.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      [
                        item.type == BurgerOrderType.set ? '세트' : '단품',
                        item.side,
                        item.drink,
                        ...item.extras,
                      ].whereType<String>().join(' · '),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              Text(
                won(item.totalPrice),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => order.changeQuantity(index, -1),
                    icon: const Icon(Icons.remove),
                    tooltip: '수량 줄이기',
                  ),
                  Text(
                    '${item.quantity}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => order.changeQuantity(index, 1),
                    icon: const Icon(Icons.add),
                    tooltip: '수량 늘리기',
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => order.removeItem(index),
                icon: const Icon(Icons.delete_outline),
                label: const Text('삭제'),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  String _question(BurgerOrderStep step) => const [
    '어디에서 드시나요?',
    '어떤 햄버거를 고를까요?',
    '단품과 세트 중 무엇으로 할까요?',
    '사이드를 골라주세요.',
    '음료를 골라주세요.',
    '추가 옵션을 고를까요?',
    '장바구니를 확인해 주세요.',
    '포인트를 적립하시겠어요?',
    '어떤 방법으로 결제하시겠어요?',
  ][step.index];
  String _guided(BurgerOrderStep step) => const [
    '포장하기를 선택해 볼까요?',
    '불고기버거를 골라볼까요?',
    '세트로 주문해 볼까요?',
    '감자튀김을 선택해 볼까요?',
    '콜라를 선택해 볼까요?',
    '추가 옵션 없이 진행해도 좋아요.',
    '수량과 주문 내용을 확인해 보세요.',
    '적립하지 않기를 선택해 볼까요?',
    '카드 결제를 선택해 볼까요?',
  ][step.index];
  String _hint(BuildContext context, BurgerOrderProvider order) {
    final m = context.read<LearningProgressProvider>().currentHamburgerMission;
    return '힌트: ${BurgerScenario.fromMissionId(m.id).summary}';
  }
}

class BurgerV2CompletePage extends StatefulWidget {
  const BurgerV2CompletePage({super.key});
  @override
  State<BurgerV2CompletePage> createState() => _BurgerV2CompletePageState();
}

class _BurgerV2CompletePageState extends State<BurgerV2CompletePage> {
  bool? firstBadge;
  bool dailyMissionRewarded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      final daily = context.read<DailyMissionProvider>();
      bool badge = false;
      if (context.read<BurgerOrderProvider>().isFreePractice) {
        // 자유 연습은 포인트, 횟수, 배지와 미션 상태를 변경하지 않는다.
      } else if (progress.isHamburgerSoloMode) {
        final before = progress.hamburgerSoloCompletionCount;
        badge = await progress.completeHamburgerSoloLearning();
        if (progress.hamburgerSoloCompletionCount > before) {
          dailyMissionRewarded = await daily.completeActiveMission(
            MissionContentType.hamburger,
          );
        }
      } else {
        await progress.completeHamburgerLearning();
      }
      if (mounted) setState(() => firstBadge = badge);
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<BurgerOrderProvider>();
    final progress = context.watch<LearningProgressProvider>();
    return Scaffold(
      backgroundColor: burgerIvory,
      appBar: AppBar(
        title: Text(order.isFreePractice ? '자유 연습 완료' : '주문 연습 완료'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PracticeCompletionHeader(
              title: order.isFreePractice ? '자유 연습을 마쳤어요' : '햄버거 주문 연습을 완료했어요!',
              description: '실제 주문이나 결제가 진행된 것은 아니에요.',
              modeLabel: practiceSessionLabel(
                isFreePractice: order.isFreePractice,
                isSolo: progress.isHamburgerSoloMode,
                dailyMission: dailyMissionRewarded,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _receipt('이용 방법', order.dineOption ?? ''),
            for (final item in order.cart) ..._itemReceipt(item),
            _receipt('포인트', order.pointMethod ?? ''),
            _receipt('결제 방법', order.paymentMethod ?? ''),
            _receipt('총 가상 금액', won(order.totalPrice)),
            const Divider(),
            const SizedBox(height: 12),
            const BurgerInlineNotice('실제 주문이나 결제가 진행된 것은 아니에요.'),
            const SizedBox(height: 16),
            BurgerInlineNotice(
              order.isFreePractice
                  ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                  : progress.isHamburgerSoloMode
                  ? '용기 포인트 +20점${firstBadge == true ? ' · 새 배지: 혼자 햄버거 주문 첫걸음' : ''}'
                  : '한걸음 포인트 +10점',
            ),
            if (dailyMissionRewarded) ...[
              const SizedBox(height: 10),
              const BurgerInlineNotice('오늘의 미션 추가 포인트 +10점'),
            ],
            const SizedBox(height: 22),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () async {
                if (order.isFreePractice) {
                  order.beginFreePractice();
                  context.go(AppRoutes.hamburgerPractice);
                } else if (progress.isHamburgerSoloMode) {
                  await progress.startHamburgerSoloMission();
                  if (!context.mounted) return;
                  order.begin(HamburgerLearningMode.solo);
                  context.go(AppRoutes.hamburgerMission);
                } else {
                  progress.selectHamburgerMode(HamburgerLearningMode.guided);
                  order.begin(HamburgerLearningMode.guided);
                  context.go(AppRoutes.hamburgerPractice);
                }
              },
              child: const Text('한 번 더 연습하기'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _itemReceipt(BurgerCartItem item) {
    final options = <String>[
      item.type == BurgerOrderType.set ? '세트' : '단품',
      if (item.side != null) item.side!,
      if (item.drink != null) item.drink!,
      ...item.extras,
    ];
    return [
      _receipt(item.menu.name, '${item.quantity}개 · ${won(item.totalPrice)}'),
      _receipt('선택 옵션', options.join(' · ')),
    ];
  }

  Widget _receipt(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, softWrap: true),
        ),
      ],
    ),
  );
}
