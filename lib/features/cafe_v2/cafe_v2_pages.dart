import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/large_action_button.dart';
import '../learning/learning_progress_provider.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'cafe_kiosk_widgets.dart';
import 'cafe_order_provider.dart';

const _soloHint = '힌트: 차가운 아메리카노 · 보통 크기 · 포장';
const _tryAgain = '괜찮아요. 주문 내용을 다시 살펴볼까요?';

String _currentSummary(CafeOrderProvider order) {
  final parts = <String>[];
  if (order.selectedMenu != null) parts.add(order.selectedMenu!.name);
  if (order.temperature != null && order.temperature != CafeTemperature.none) {
    parts.add(order.temperature!.label);
  }
  if (order.size != null) parts.add(order.size!.label);
  if (order.dineOption != null) parts.add(order.dineOption!.label);
  return parts.join(' · ');
}

class CafeV2MenuPage extends StatefulWidget {
  const CafeV2MenuPage({super.key});

  @override
  State<CafeV2MenuPage> createState() => _CafeV2MenuPageState();
}

class _CafeV2MenuPageState extends State<CafeV2MenuPage> {
  String? _feedback;
  bool _showHint = false;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    final items = order.visibleMenuItems.toList();
    return CafeKioskScaffold(
      stageLabel: '1 / 7 · 메뉴 고르기',
      cartCount: order.cartCount,
      onBack: () => context.go(AppRoutes.cafeStart),
      onCart: () {
        if (order.cart.isNotEmpty) context.go(AppRoutes.cafeV2Cart);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '어떤 메뉴를 고를까요?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.isSolo ? '미션을 기억하고 메뉴를 골라보세요.' : '커피 탭에서 아메리카노를 골라보세요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (_feedback != null || _showHint) ...[
                  const SizedBox(height: 10),
                  CafePracticeNotice(
                    message: _feedback ?? _soloHint,
                    icon: _feedback == null
                        ? Icons.lightbulb_outline
                        : Icons.refresh,
                  ),
                ],
                if (order.isSolo)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _showHint = !_showHint;
                      if (_showHint) _feedback = null;
                    }),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(_showHint ? '힌트 닫기' : '힌트 보기'),
                  ),
              ],
            ),
          ),
          CafeCategoryTabs(
            selected: order.category,
            onSelected: order.selectCategory,
          ),
          const Divider(height: 1, color: learningSageBorder),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = MediaQuery.textScalerOf(context).scale(1);
                final extent = scale > 1.15 ? 214.0 : 180.0;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: extent,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CafeMenuCard(
                      item: item,
                      recommended: !order.isSolo && item.id == 'americano',
                      onPressed: () {
                        if (!order.selectMenu(item)) {
                          setState(() {
                            _feedback = _tryAgain;
                            _showHint = false;
                          });
                          return;
                        }
                        context.go(AppRoutes.cafeV2Temperature);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CafeV2TemperaturePage extends StatelessWidget {
  const CafeV2TemperaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    final menu = order.selectedMenu;
    if (menu == null) return const _MissingCafeSession();
    final options = menu.temperatures.toList();
    return _CafeOptionPage<CafeTemperature>(
      stageLabel: '2 / 7 · 온도 고르기',
      question: options.singleOrNull == CafeTemperature.none
          ? '이 메뉴는 온도를 고르지 않아요.'
          : '온도를 어떻게 할까요?',
      guidance: order.isSolo
          ? '미션을 기억하고 직접 골라보세요.'
          : menu.id == 'americano'
          ? '차갑게를 선택해 볼까요?'
          : '원하는 온도를 선택해보세요.',
      order: order,
      values: options,
      label: (value) => value.label,
      icon: (value) => value == CafeTemperature.hot
          ? Icons.local_fire_department_outlined
          : value == CafeTemperature.iced
          ? Icons.ac_unit_outlined
          : Icons.check_circle_outline,
      onBack: () => context.go(AppRoutes.cafeV2Menu),
      onSubmit: order.selectTemperature,
      onNext: () => context.go(AppRoutes.cafeV2Size),
    );
  }
}

class CafeV2SizePage extends StatelessWidget {
  const CafeV2SizePage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    if (order.selectedMenu == null || order.temperature == null) {
      return const _MissingCafeSession();
    }
    return _CafeOptionPage<CafeSize>(
      stageLabel: '3 / 7 · 크기 고르기',
      question: '어떤 크기로 주문할까요?',
      guidance: order.isSolo ? '미션을 기억하고 직접 골라보세요.' : '보통 크기를 선택해 볼까요?',
      helper: '큰 사이즈는 연습용 금액 500원이 추가돼요.',
      order: order,
      values: CafeSize.values,
      label: (value) => value.label,
      icon: (value) => value == CafeSize.large
          ? Icons.local_cafe
          : Icons.local_cafe_outlined,
      onBack: () => context.go(AppRoutes.cafeV2Temperature),
      onSubmit: order.selectSize,
      onNext: () => context.go(AppRoutes.cafeV2DineOption),
    );
  }
}

class CafeV2DineOptionPage extends StatelessWidget {
  const CafeV2DineOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    if (order.selectedMenu == null || order.size == null) {
      return const _MissingCafeSession();
    }
    return _CafeOptionPage<CafeDineOption>(
      stageLabel: '4 / 7 · 이용 방법',
      question: '매장에서 드시나요?',
      guidance: order.isSolo ? '미션을 기억하고 직접 골라보세요.' : '포장을 선택해 볼까요?',
      order: order,
      values: CafeDineOption.values,
      label: (value) => value == CafeDineOption.dineIn ? '매장' : '포장',
      icon: (value) => value == CafeDineOption.dineIn
          ? Icons.restaurant_outlined
          : Icons.takeout_dining_outlined,
      onBack: () => context.go(AppRoutes.cafeV2Size),
      onSubmit: order.selectDineOption,
      nextLabel: '장바구니에 담기',
      onNext: () {
        order.addCurrentItem();
        context.go(AppRoutes.cafeV2Cart);
      },
    );
  }
}

class _CafeOptionPage<T> extends StatefulWidget {
  const _CafeOptionPage({
    required this.stageLabel,
    required this.question,
    required this.guidance,
    required this.order,
    required this.values,
    required this.label,
    required this.icon,
    required this.onBack,
    required this.onSubmit,
    required this.onNext,
    this.helper,
    this.nextLabel = '다음으로',
  });

  final String stageLabel;
  final String question;
  final String guidance;
  final String? helper;
  final CafeOrderProvider order;
  final List<T> values;
  final String Function(T) label;
  final IconData Function(T) icon;
  final VoidCallback onBack;
  final bool Function(T) onSubmit;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  State<_CafeOptionPage<T>> createState() => _CafeOptionPageState<T>();
}

class _CafeOptionPageState<T> extends State<_CafeOptionPage<T>> {
  T? _selected;
  String? _feedback;
  bool _showHint = false;

  @override
  Widget build(BuildContext context) {
    return CafeKioskScaffold(
      stageLabel: widget.stageLabel,
      cartCount: widget.order.cartCount,
      orderSummary: _currentSummary(widget.order),
      onBack: widget.onBack,
      onCart: () {
        if (widget.order.cart.isNotEmpty) context.go(AppRoutes.cafeV2Cart);
      },
      bottom: FilledButton(
        onPressed: _selected == null ? null : _continue,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
        child: Text(widget.nextLabel, textAlign: TextAlign.center),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: _progressValue(widget.stageLabel),
              minHeight: 5,
            ),
            const SizedBox(height: 24),
            Text(
              widget.question,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(widget.guidance, style: Theme.of(context).textTheme.bodyLarge),
            if (_feedback != null || _showHint) ...[
              const SizedBox(height: 14),
              CafePracticeNotice(
                message: _feedback ?? _soloHint,
                icon: _feedback == null
                    ? Icons.lightbulb_outline
                    : Icons.refresh,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                for (var index = 0; index < widget.values.length; index++) ...[
                  Expanded(
                    child: CafeOptionCard(
                      label: widget.label(widget.values[index]),
                      icon: widget.icon(widget.values[index]),
                      selected: _selected == widget.values[index],
                      onPressed: () => setState(() {
                        _selected = widget.values[index];
                        _feedback = null;
                      }),
                    ),
                  ),
                  if (index < widget.values.length - 1)
                    const SizedBox(width: 12),
                ],
              ],
            ),
            if (widget.helper != null) ...[
              const SizedBox(height: 14),
              Text(
                widget.helper!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (widget.order.isSolo) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showHint = !_showHint),
                  icon: const Icon(Icons.lightbulb_outline),
                  label: Text(_showHint ? '힌트 닫기' : '힌트 보기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _continue() {
    final selected = _selected;
    if (selected == null) return;
    if (!widget.onSubmit(selected)) {
      setState(() {
        _feedback = _tryAgain;
        _showHint = false;
      });
      return;
    }
    widget.onNext();
  }

  double _progressValue(String label) {
    final step = int.tryParse(label.characters.first) ?? 1;
    return step / 7;
  }
}

class CafeV2CartPage extends StatelessWidget {
  const CafeV2CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    return CafeKioskScaffold(
      stageLabel: '5 / 7 · 장바구니',
      cartCount: order.cartCount,
      onBack: () => context.go(AppRoutes.cafeV2Menu),
      onCart: () {},
      bottom: order.cart.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(
                      '총 가상 금액',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      formatPracticePrice(order.totalPrice),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFF23413C),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.cafeV2Point),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: const Text('주문 확인하기'),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.cafeV2Menu),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('주문 계속하기'),
                ),
              ],
            ),
      child: order.cart.isEmpty
          ? _EmptyCart(onMenu: () => context.go(AppRoutes.cafeV2Menu))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              children: [
                Text(
                  '주문 내역',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '가격은 모두 연습용 가상 금액이에요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                for (final item in order.cart)
                  CafeCartItemCard(
                    item: item,
                    onDecrease: () => order.changeQuantity(item.id, -1),
                    onIncrease: () => order.changeQuantity(item.id, 1),
                    onRemove: () => order.removeItem(item.id),
                  ),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onMenu});
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Color(0xFF23413C),
            ),
            const SizedBox(height: 16),
            Text(
              '장바구니가 비어 있어요.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onMenu,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              child: const Text('메뉴판으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class CafeV2PointPage extends StatelessWidget {
  const CafeV2PointPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    if (order.cart.isEmpty) return const _MissingCafeSession();
    return _SimpleSelectionPage<CafePointMethod>(
      stageLabel: '6 / 7 · 포인트 적립',
      question: '포인트를 적립하시겠어요?',
      notice: '연습 화면입니다. 실제 적립은 되지 않아요.',
      order: order,
      values: CafePointMethod.values,
      label: (value) => value.label,
      icon: (value) => switch (value) {
        CafePointMethod.phone => Icons.phone_outlined,
        CafePointMethod.messenger => Icons.chat_bubble_outline,
        CafePointMethod.none => Icons.not_interested_outlined,
      },
      onBack: () => context.go(AppRoutes.cafeV2Cart),
      onSubmit: (value) {
        order.selectPointMethod(value);
        context.go(AppRoutes.cafeV2Payment);
      },
    );
  }
}

class CafeV2PaymentPage extends StatelessWidget {
  const CafeV2PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    if (order.cart.isEmpty || order.pointMethod == null) {
      return const _MissingCafeSession();
    }
    return _SimpleSelectionPage<CafePaymentMethod>(
      stageLabel: '7 / 7 · 결제 방법',
      question: '어떤 방법으로 결제하시겠어요?',
      notice: '실제 결제가 진행되지 않습니다. 카드나 개인정보를 입력하지 않아요.',
      order: order,
      values: CafePaymentMethod.values,
      label: (value) => value.label,
      icon: (value) => switch (value) {
        CafePaymentMethod.creditCard => Icons.credit_card_outlined,
        CafePaymentMethod.mobilePay => Icons.qr_code_rounded,
        CafePaymentMethod.simplePay => Icons.phone_android_outlined,
        CafePaymentMethod.cash => Icons.payments_outlined,
      },
      onBack: () => context.go(AppRoutes.cafeV2Point),
      actionLabel: '결제 연습 완료하기',
      onSubmit: (value) {
        order.selectPaymentMethod(value);
        context.go(AppRoutes.cafeV2Complete);
      },
    );
  }
}

class _SimpleSelectionPage<T> extends StatefulWidget {
  const _SimpleSelectionPage({
    required this.stageLabel,
    required this.question,
    required this.notice,
    required this.order,
    required this.values,
    required this.label,
    required this.icon,
    required this.onBack,
    required this.onSubmit,
    this.actionLabel = '다음으로',
  });

  final String stageLabel;
  final String question;
  final String notice;
  final CafeOrderProvider order;
  final List<T> values;
  final String Function(T) label;
  final IconData Function(T) icon;
  final VoidCallback onBack;
  final ValueChanged<T> onSubmit;
  final String actionLabel;

  @override
  State<_SimpleSelectionPage<T>> createState() =>
      _SimpleSelectionPageState<T>();
}

class _SimpleSelectionPageState<T> extends State<_SimpleSelectionPage<T>> {
  T? _selected;

  @override
  Widget build(BuildContext context) {
    return CafeKioskScaffold(
      stageLabel: widget.stageLabel,
      cartCount: widget.order.cartCount,
      onBack: widget.onBack,
      onCart: () => context.go(AppRoutes.cafeV2Cart),
      bottom: FilledButton(
        onPressed: _selected == null
            ? null
            : () => widget.onSubmit(_selected as T),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
        child: Text(widget.actionLabel, textAlign: TextAlign.center),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        children: [
          Text(
            widget.question,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          CafePracticeNotice(message: widget.notice),
          const SizedBox(height: 18),
          for (final value in widget.values)
            CafeSelectionRow(
              icon: widget.icon(value),
              label: widget.label(value),
              selected: _selected == value,
              onPressed: () => setState(() => _selected = value),
            ),
        ],
      ),
    );
  }
}

class CafeV2CompletePage extends StatefulWidget {
  const CafeV2CompletePage({super.key});

  @override
  State<CafeV2CompletePage> createState() => _CafeV2CompletePageState();
}

class _CafeV2CompletePageState extends State<CafeV2CompletePage> {
  bool _badgeEarned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final order = context.read<CafeOrderProvider>();
      final progress = context.read<LearningProgressProvider>();
      final daily = context.read<DailyMissionProvider>();
      final before = progress.soloCompletionCount;
      final earned = await context
          .read<LearningProgressProvider>()
          .completeCafeLearning();
      if (order.isSolo && progress.soloCompletionCount > before) {
        await daily.completeActiveMission(MissionContentType.cafe);
      }
      if (mounted) setState(() => _badgeEarned = earned);
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<CafeOrderProvider>();
    final progress = context.watch<LearningProgressProvider>();
    if (order.cart.isEmpty ||
        order.paymentMethod == null ||
        order.pointMethod == null) {
      return const _MissingCafeSession();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      appBar: AppBar(
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFAF9F4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: learningSageBorder)),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.cafeV2Payment),
          tooltip: '이전 화면으로 돌아가기',
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 4,
        title: const Text('카페 주문'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 62,
              color: Color(0xFF23413C),
            ),
            const SizedBox(height: 14),
            Text(
              '주문 연습을 완료했어요!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            Text('연습 주문서', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24, color: learningSageBorder),
            for (final item in order.cart)
              _ReceiptLine(
                label: '${item.menu.name} ${item.quantity}개',
                value:
                    '${item.temperature.label} · ${item.size.label} · ${item.dineOption.label}',
              ),
            _ReceiptLine(label: '포인트', value: order.pointMethod!.label),
            _ReceiptLine(label: '결제 방법', value: order.paymentMethod!.label),
            const Divider(height: 24, color: learningSageBorder),
            _ReceiptLine(
              label: '총 가상 금액',
              value: formatPracticePrice(order.totalPrice),
              strong: true,
            ),
            const SizedBox(height: 18),
            CafePracticeNotice(
              message: progress.isSoloMode ? '용기 포인트 +20점' : '한걸음 포인트 +10점',
              icon: Icons.stars_outlined,
            ),
            if (_badgeEarned) ...[
              const SizedBox(height: 10),
              const CafePracticeNotice(
                message: '새 배지: 혼자 주문 첫걸음',
                icon: Icons.workspace_premium_outlined,
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '실제 주문이나 결제가 진행된 것은 아니에요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                final mode = progress.mode ?? CafeLearningMode.guided;
                progress.selectMode(mode);
                order.start(mode);
                context.go(AppRoutes.cafeV2Menu);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              child: const Text('한 번 더 연습하기'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  (strong
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.bodyLarge)
                      ?.copyWith(
                        fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingCafeSession extends StatelessWidget {
  const _MissingCafeSession();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카페 주문')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  '주문 연습을 처음부터 시작해 주세요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 320,
                  child: LargeActionButton(
                    label: '카페 연습으로 돌아가기',
                    onPressed: () => context.go(AppRoutes.cafeStart),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
