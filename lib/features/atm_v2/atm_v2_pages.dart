import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'atm_kiosk_widgets.dart';
import 'atm_withdrawal_models.dart';
import 'atm_withdrawal_provider.dart';

class AtmV2StartPage extends StatelessWidget {
  const AtmV2StartPage({super.key});

  Future<void> _start(BuildContext context, AtmLearningMode mode) async {
    final progress = context.read<LearningProgressProvider>();
    await progress.startAtmLearning(mode);
    if (!context.mounted) return;
    context.read<AtmWithdrawalProvider>().begin(
      mode,
      completedCount: progress.atmSoloCompletionCount,
    );
    context.go(AppRoutes.atmV2Services);
  }

  @override
  Widget build(BuildContext context) => AtmKioskScaffold(
    onBack: () => context.go(AppRoutes.home),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      children: [
        const AtmQuestion(
          title: 'ATM 출금 연습',
          description: '실제 금융 거래 없이 돈을 찾는 순서를 천천히 연습해요.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: atmSage,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.account_balance_outlined, size: 44, color: atmNavy),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  '연습용 가상 ATM입니다. 실제 카드나 계좌 정보는 사용하지 않아요.',
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AtmChoiceRow(
          label: '따라 해보기',
          subtitle: '화면의 안내를 보며 하나씩 연습해요. 완료하면 10점을 받아요.',
          icon: Icons.directions_walk_outlined,
          emphasized: true,
          onTap: () => _start(context, AtmLearningMode.guided),
        ),
        const SizedBox(height: 12),
        AtmChoiceRow(
          label: '혼자 해보기',
          subtitle: '오늘의 출금 미션을 기억하고 직접 해봐요. 완료하면 20점을 받아요.',
          icon: Icons.psychology_alt_outlined,
          onTap: () => context.go(AppRoutes.atmMission),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.home_outlined),
          label: const Text('홈으로'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
      ],
    ),
  );
}

class AtmV2MissionPage extends StatefulWidget {
  const AtmV2MissionPage({super.key});
  @override
  State<AtmV2MissionPage> createState() => _AtmV2MissionPageState();
}

class _AtmV2MissionPageState extends State<AtmV2MissionPage> {
  bool _prepared = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    final progress = context.read<LearningProgressProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AtmWithdrawalProvider>().begin(
        AtmLearningMode.solo,
        completedCount: progress.atmSoloCompletionCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AtmWithdrawalProvider>();
    final scenario = provider.scenario;
    final account = scenario.account == AtmAccountType.checking
        ? '입출금 계좌'
        : '생활비 계좌';
    return AtmKioskScaffold(
      modeLabel: practiceSessionLabel(
        isFreePractice: provider.isFreePractice,
        isSolo: provider.isSolo,
      ),
      onBack: () {
        context.read<DailyMissionProvider>().cancelActiveMission();
        context.go(AppRoutes.atmStart);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
        children: [
          const AtmQuestion(
            title: '오늘의 ATM 출금 미션',
            description: '내용을 기억하고 직접 순서대로 선택해 보세요.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: atmBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  scenario.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(height: 28),
                Text('계좌: $account'),
                const SizedBox(height: 8),
                Text('금액: ${formatAtmWon(scenario.amount)}'),
                const SizedBox(height: 8),
                Text('가상 수수료: ${formatAtmWon(scenario.fee)}'),
                const SizedBox(height: 8),
                Text(
                  '명세표: ${scenario.receipt == AtmReceiptChoice.receive ? '받기' : '받지 않기'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const AtmInlineNotice('힌트가 필요하면 각 화면에서 언제든 확인할 수 있어요.'),
          const SizedBox(height: 24),
          atmPrimaryButton('혼자 해보기', () async {
            final progress = context.read<LearningProgressProvider>();
            final daily = context.read<DailyMissionProvider>();
            if (daily.activeMissionId != 'atm_solo_complete') {
              await progress.startAtmLearning(AtmLearningMode.solo);
            }
            if (!context.mounted) return;
            context.read<AtmWithdrawalProvider>().begin(
              AtmLearningMode.solo,
              completedCount: progress.atmSoloCompletionCount,
            );
            context.go(AppRoutes.atmV2Services);
          }),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.atmStart),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('ATM 출금 연습으로 돌아가기'),
          ),
        ],
      ),
    );
  }
}

class AtmV2FlowPage extends StatefulWidget {
  const AtmV2FlowPage({super.key, required this.pageStep});
  final AtmV2Step pageStep;
  @override
  State<AtmV2FlowPage> createState() => _AtmV2FlowPageState();
}

class _AtmV2FlowPageState extends State<AtmV2FlowPage>
    with WidgetsBindingObserver {
  String _directAmount = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<AtmWithdrawalProvider>().clearSensitiveState();
    }
  }

  String _route(AtmV2Step step) => switch (step) {
    AtmV2Step.services => AppRoutes.atmV2Services,
    AtmV2Step.transaction => AppRoutes.atmV2Transaction,
    AtmV2Step.card => AppRoutes.atmV2Card,
    AtmV2Step.pin => AppRoutes.atmV2Pin,
    AtmV2Step.account => AppRoutes.atmV2Account,
    AtmV2Step.amount => AppRoutes.atmV2Amount,
    AtmV2Step.review => AppRoutes.atmV2Review,
    AtmV2Step.processing => AppRoutes.atmV2Processing,
    AtmV2Step.cardReturn => AppRoutes.atmV2CardReturn,
    AtmV2Step.cashReturn => AppRoutes.atmV2CashReturn,
    AtmV2Step.receipt => AppRoutes.atmV2Receipt,
    AtmV2Step.complete => AppRoutes.atmComplete,
  };

  void _sync(AtmWithdrawalProvider p) {
    if (!mounted) return;
    context.go(_route(p.step));
  }

  int get _progressStep => switch (widget.pageStep) {
    AtmV2Step.services || AtmV2Step.transaction => 1,
    AtmV2Step.card => 2,
    AtmV2Step.pin => 3,
    AtmV2Step.account => 4,
    AtmV2Step.amount => 5,
    AtmV2Step.review => 6,
    AtmV2Step.processing => 7,
    AtmV2Step.cardReturn => 8,
    AtmV2Step.cashReturn => 9,
    AtmV2Step.receipt || AtmV2Step.complete => 10,
  };

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AtmWithdrawalProvider>();
    return AtmKioskScaffold(
      modeLabel: practiceSessionLabel(
        isFreePractice: p.isFreePractice,
        isSolo: p.isSolo,
      ),
      onBack: () {
        if (widget.pageStep == AtmV2Step.services) {
          p.clearSensitiveState();
          if (p.isSolo) {
            context.read<DailyMissionProvider>().cancelActiveMission();
          }
          context.go(AppRoutes.atmStart);
        } else {
          p.previous();
          _sync(p);
        }
      },
      step: _progressStep,
      summary: p.summary,
      bottom: _bottom(context, p),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: [
          if (!p.isSolo && !p.isFreePractice) AtmInlineNotice(p.hint),
          if (!p.isSolo && !p.isFreePractice) const SizedBox(height: 14),
          ..._body(context, p),
          if (p.notice != null) ...[
            const SizedBox(height: 14),
            AtmInlineNotice(p.notice!, warning: true),
          ],
          if (p.isSolo && p.showHint) ...[
            const SizedBox(height: 14),
            AtmInlineNotice('힌트: ${p.hint}'),
          ],
          if (p.isSolo) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: p.revealHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(p.showHint ? '힌트 닫기' : '힌트 보기'),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context, AtmWithdrawalProvider p) =>
      switch (widget.pageStep) {
        AtmV2Step.services => _services(p),
        AtmV2Step.transaction => _transactions(p),
        AtmV2Step.card => _card(p),
        AtmV2Step.pin => _pin(p),
        AtmV2Step.account => _accounts(p),
        AtmV2Step.amount => _amounts(p),
        AtmV2Step.review => _review(p),
        AtmV2Step.processing => _processing(p),
        AtmV2Step.cardReturn => _returnCard(p),
        AtmV2Step.cashReturn => _returnCash(p),
        AtmV2Step.receipt => _receipt(p),
        AtmV2Step.complete => const [],
      };

  List<Widget> _services(AtmWithdrawalProvider p) => [
    const AtmQuestion(
      title: '원하는 업무를 선택해 주세요',
      description: '이 화면은 실제 금융 거래가 아닌 연습용 화면이에요.',
    ),
    const SizedBox(height: 18),
    for (final item in const [
      ('현금 출금', Icons.payments_outlined),
      ('잔액 조회', Icons.account_balance_wallet_outlined),
      ('계좌 이체', Icons.swap_horiz),
      ('입금', Icons.savings_outlined),
    ]) ...[
      AtmChoiceRow(
        label: item.$1,
        subtitle: item.$1 == '현금 출금' ? '현재 연습할 수 있어요' : '준비 중',
        icon: item.$2,
        emphasized: !p.isSolo && !p.isFreePractice && item.$1 == '현금 출금',
        onTap: () {
          p.chooseService(item.$1);
          _sync(p);
        },
      ),
      const SizedBox(height: 10),
    ],
  ];

  List<Widget> _transactions(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '어떤 거래를 하시겠어요?'),
    const SizedBox(height: 18),
    for (final item in const [
      ('현금 출금', Icons.payments_outlined),
      ('잔액 조회', Icons.receipt_long_outlined),
      ('계좌 이체', Icons.swap_horiz),
      ('입금', Icons.savings_outlined),
    ]) ...[
      AtmChoiceRow(
        label: item.$1,
        icon: item.$2,
        emphasized: !p.isSolo && !p.isFreePractice && item.$1 == '현금 출금',
        onTap: () {
          p.chooseTransaction(item.$1);
          _sync(p);
        },
      ),
      const SizedBox(height: 10),
    ],
  ];

  List<Widget> _card(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '연습용 카드를 넣어 주세요'),
    const SizedBox(height: 24),
    Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: atmBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_outlined, size: 68, color: atmNavy),
          SizedBox(height: 14),
          Text('연습용 카드 삽입구'),
        ],
      ),
    ),
    const SizedBox(height: 14),
    const AtmInlineNotice('실제 카드를 넣거나 촬영하지 않습니다.'),
  ];

  List<Widget> _pin(AtmWithdrawalProvider p) => [
    const AtmQuestion(
      title: '연습용 비밀번호를 입력해 주세요',
      description: '연습용 비밀번호는 1234예요. 실제 비밀번호는 입력하지 마세요.',
    ),
    const SizedBox(height: 16),
    AtmPinPad(
      length: p.pinLength,
      onDigit: p.addPinDigit,
      onRemove: p.removePinDigit,
      onClear: p.clearPin,
    ),
    const SizedBox(height: 12),
    OutlinedButton.icon(
      onPressed: p.requestHelp,
      icon: const Icon(Icons.support_agent_outlined),
      label: const Text('직원에게 도움 요청'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    ),
  ];

  List<Widget> _accounts(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '출금할 계좌를 선택해 주세요'),
    const SizedBox(height: 18),
    for (final a in atmPracticeAccounts) ...[
      AtmChoiceRow(
        label: a.name,
        subtitle: '${a.practiceName} · 가상 잔액 ${formatAtmWon(a.balance)}',
        icon: Icons.account_balance_wallet_outlined,
        emphasized:
            !p.isSolo && !p.isFreePractice && a.type == p.scenario.account,
        onTap: () {
          p.chooseAccount(a);
          _sync(p);
        },
      ),
      const SizedBox(height: 10),
    ],
  ];

  List<Widget> _amounts(AtmWithdrawalProvider p) => [
    const AtmQuestion(
      title: '얼마를 찾으시겠어요?',
      description: '1만 원 단위로 한 번에 최대 30만 원까지 연습할 수 있어요.',
    ),
    const SizedBox(height: 18),
    AtmAmountGrid(
      target: p.scenario.amount,
      guided: !p.isSolo && !p.isFreePractice,
      onSelect: (v) {
        p.chooseAmount(v);
        _sync(p);
      },
    ),
    const SizedBox(height: 12),
    TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        labelText: '직접 입력',
        hintText: '예: 50000',
        suffixText: '원',
      ),
      onChanged: (value) => _directAmount = value,
    ),
    const SizedBox(height: 10),
    OutlinedButton(
      onPressed: () {
        p.enterAmount(_directAmount);
        _sync(p);
      },
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      child: const Text('입력한 금액 선택'),
    ),
  ];

  List<Widget> _review(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '거래 내용을 확인해 주세요'),
    const SizedBox(height: 18),
    _receiptBox(context, [
      ('거래 종류', '현금 출금'),
      ('선택 계좌', p.account?.name ?? '-'),
      ('출금 금액', formatAtmWon(p.amount ?? 0)),
      ('가상 수수료', formatAtmWon(p.fee)),
      ('차감 예정 가상 금액', formatAtmWon(p.debitTotal)),
      ('카드 반환', '거래 후 먼저 반환'),
    ]),
    const SizedBox(height: 14),
    const AtmInlineNotice('실제 거래가 아니며 가상 계좌에서 돈이 빠져나가지 않아요.'),
  ];

  List<Widget> _processing(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '가상 출금 연습을 진행할게요'),
    const SizedBox(height: 28),
    Center(
      child: Icon(
        p.busy ? Icons.sync : Icons.account_balance_outlined,
        size: 80,
        color: atmNavy,
      ),
    ),
    const SizedBox(height: 20),
    const Text(
      '실제 계좌에서는 돈이 빠져나가지 않습니다.',
      textAlign: TextAlign.center,
      softWrap: true,
    ),
  ];

  List<Widget> _returnCard(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '카드를 먼저 챙겨 주세요'),
    const SizedBox(height: 28),
    const Center(
      child: Icon(Icons.credit_card_outlined, size: 82, color: atmNavy),
    ),
    const SizedBox(height: 18),
    const AtmInlineNotice('카드를 챙겨야 다음 단계로 갈 수 있어요.'),
  ];

  List<Widget> _returnCash(AtmWithdrawalProvider p) => [
    const AtmQuestion(title: '현금을 챙겨 주세요'),
    const SizedBox(height: 20),
    Center(
      child: Column(
        children: [
          const Icon(Icons.payments_outlined, size: 82, color: atmNavy),
          const SizedBox(height: 12),
          Text(
            formatAtmWon(p.amount ?? 0),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    ),
    const SizedBox(height: 18),
    const AtmInlineNotice('현금을 두고 가지 않도록 꼭 확인해 주세요.'),
  ];

  List<Widget> _receipt(AtmWithdrawalProvider p) => [
    const AtmQuestion(
      title: '명세표를 받으시겠어요?',
      description: '실제 출력이나 PDF 생성은 하지 않아요.',
    ),
    const SizedBox(height: 18),
    AtmChoiceRow(
      label: '명세표 받기',
      icon: Icons.receipt_long_outlined,
      emphasized:
          !p.isSolo &&
          !p.isFreePractice &&
          p.scenario.receipt == AtmReceiptChoice.receive,
      onTap: () {
        p.chooseReceipt(AtmReceiptChoice.receive);
        _sync(p);
      },
    ),
    const SizedBox(height: 10),
    AtmChoiceRow(
      label: '명세표 받지 않기',
      icon: Icons.do_not_disturb_alt_outlined,
      emphasized:
          !p.isSolo &&
          !p.isFreePractice &&
          p.scenario.receipt == AtmReceiptChoice.skip,
      onTap: () {
        p.chooseReceipt(AtmReceiptChoice.skip);
        _sync(p);
      },
    ),
  ];

  Widget? _bottom(BuildContext context, AtmWithdrawalProvider p) =>
      switch (widget.pageStep) {
        AtmV2Step.card => atmPrimaryButton('카드 넣기', () {
          p.insertCard();
          _sync(p);
        }),
        AtmV2Step.pin => atmPrimaryButton(
          '비밀번호 확인',
          p.pinLength == 4
              ? () {
                  p.verifyPin();
                  _sync(p);
                }
              : null,
        ),
        AtmV2Step.review => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            atmPrimaryButton('거래 진행', () {
              p.confirmTransaction();
              _sync(p);
            }),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    p.previous();
                    _sync(p);
                  },
                  child: const Text('금액 수정'),
                ),
                TextButton(
                  onPressed: () {
                    p.reset();
                    context.go(AppRoutes.atmV2Services);
                  },
                  child: const Text('계좌 수정'),
                ),
                TextButton(
                  onPressed: () {
                    p.reset();
                    context.go(AppRoutes.atmStart);
                  },
                  child: const Text('거래 취소'),
                ),
              ],
            ),
          ],
        ),
        AtmV2Step.processing => atmPrimaryButton(
          p.busy ? '진행 중이에요' : '가상 출금 진행하기',
          p.busy
              ? null
              : () async {
                  await p.processTransaction();
                  _sync(p);
                },
        ),
        AtmV2Step.cardReturn => atmPrimaryButton('카드 챙기기', () {
          p.retrieveCard();
          _sync(p);
        }),
        AtmV2Step.cashReturn => atmPrimaryButton('현금 챙기기', () {
          p.retrieveCash();
          _sync(p);
        }),
        _ => null,
      };

  Widget _receiptBox(BuildContext context, List<(String, String)> rows) =>
      Container(
        padding: const EdgeInsets.all(18),
        color: Colors.white,
        child: Column(
          children: [
            const Text('연습용 거래 확인'),
            const Divider(height: 26),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(row.$1)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        row.$2,
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class AtmV2CompletePage extends StatefulWidget {
  const AtmV2CompletePage({super.key});
  @override
  State<AtmV2CompletePage> createState() => _AtmV2CompletePageState();
}

class _AtmV2CompletePageState extends State<AtmV2CompletePage> {
  bool _started = false;
  bool _badge = false;
  bool _daily = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final session = context.read<AtmWithdrawalProvider>();
    if (!session.canComplete) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _award(session));
  }

  Future<void> _award(AtmWithdrawalProvider session) async {
    if (!mounted) return;
    if (session.isFreePractice) return;
    final progress = context.read<LearningProgressProvider>();
    if (session.isSolo) {
      final before = progress.atmSoloCompletionCount;
      final badge = await progress.completeAtmSoloLearning();
      var daily = false;
      if (progress.atmSoloCompletionCount > before && mounted) {
        daily = await context
            .read<DailyMissionProvider>()
            .completeActiveMission(MissionContentType.atm);
      }
      if (mounted) {
        setState(() {
          _badge = badge;
          _daily = daily;
        });
      }
    } else {
      await progress.completeAtmLearning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AtmWithdrawalProvider>();
    final progress = context.watch<LearningProgressProvider>();
    return AtmKioskScaffold(
      onBack: () => context.go(AppRoutes.atmStart),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          PracticeCompletionHeader(
            title: '출금 연습 완료',
            description: '실제 금융 거래가 진행된 것은 아니에요.',
            modeLabel: practiceSessionLabel(
              isFreePractice: p.isFreePractice,
              isSolo: p.isSolo,
              dailyMission: _daily,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            color: Colors.white,
            child: Column(
              children: [
                _row('선택 계좌', p.account?.name ?? '-'),
                _row('가상 출금 금액', formatAtmWon(p.amount ?? 0)),
                _row('가상 수수료', formatAtmWon(p.fee)),
                _row('차감 가상 금액', formatAtmWon(p.debitTotal)),
                _row('카드', p.cardRetrieved ? '챙김 완료' : '확인 필요'),
                _row('현금', p.cashRetrieved ? '챙김 완료' : '확인 필요'),
                _row(
                  '명세표',
                  p.receipt == AtmReceiptChoice.receive ? '받기' : '받지 않기',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AtmInlineNotice(
            p.isFreePractice
                ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                : p.isSolo
                ? '용기 포인트 +20점${_daily ? ' · 오늘의 미션 +10점' : ''}'
                : '한걸음 포인트 +10점',
          ),
          if (_badge) ...[
            const SizedBox(height: 10),
            const AtmInlineNotice('새 배지: 혼자 ATM 출금 첫걸음'),
          ],
          const SizedBox(height: 10),
          Text('현재 ${progress.totalPoints}점', textAlign: TextAlign.center),
          const SizedBox(height: 14),
          const Text(
            '실제 계좌에서는 돈이 빠져나가지 않았습니다. 실제 ATM에서는 카드와 현금을 반드시 확인해 주세요.',
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 24),
          atmPrimaryButton('다시 연습하기', () async {
            if (p.isFreePractice) {
              p.beginFreePractice();
              context.go(AppRoutes.atmV2Services);
              return;
            }
            await progress.startAtmLearning(p.mode);
            if (!context.mounted) return;
            p.begin(p.mode, completedCount: progress.atmSoloCompletionCount);
            context.go(
              p.isSolo ? AppRoutes.atmMission : AppRoutes.atmV2Services,
            );
          }),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.practice),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('다른 연습 보기'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
