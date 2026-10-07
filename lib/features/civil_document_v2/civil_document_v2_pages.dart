import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'civil_document_models.dart';
import 'civil_document_provider.dart';
import 'civil_document_widgets.dart';

class CivilDocumentV2StartPage extends StatelessWidget {
  const CivilDocumentV2StartPage({super.key});

  Future<void> _start(BuildContext context, CivilDocumentV2Mode mode) async {
    final progress = context.read<LearningProgressProvider>();
    await progress.startCivilDocumentLearning(
      mode == CivilDocumentV2Mode.solo
          ? CivilDocumentLearningMode.solo
          : CivilDocumentLearningMode.guided,
    );
    if (!context.mounted) return;
    context.read<CivilDocumentV2Provider>().begin(
      mode,
      completedCount: progress.civilDocumentSoloCompletionCount,
    );
    context.go(AppRoutes.civilDocumentV2Categories);
  }

  @override
  Widget build(BuildContext context) => CivilKioskScaffold(
    onBack: () => context.go(AppRoutes.home),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      children: [
        const CivilQuestion(
          '무인민원발급기 연습',
          description: '실제 발급기의 공통 순서를 가상 화면으로 천천히 연습해요.',
        ),
        const SizedBox(height: 18),
        const CivilNotice(
          '연습 화면입니다. 실제 증명서가 발급되지 않고 개인정보를 입력하지 않아요.',
          warning: true,
        ),
        const SizedBox(height: 18),
        CivilChoiceRow(
          label: '따라 해보기',
          subtitle: '처음 이용하시나요? 안내를 보며 따라 해보세요.',
          icon: Icons.touch_app_outlined,
          emphasized: true,
          onTap: () => _start(context, CivilDocumentV2Mode.guided),
        ),
        const SizedBox(height: 10),
        CivilChoiceRow(
          label: '혼자 해보기',
          subtitle: '오늘의 발급 목표를 기억하고 직접 골라요.',
          icon: Icons.psychology_alt_outlined,
          onTap: () => context.go(AppRoutes.civilDocumentMission),
        ),
        const SizedBox(height: 18),
        CivilChoiceRow(
          label: '발급 가능한 서류 보기',
          subtitle: '기기마다 발급 항목과 수수료가 다를 수 있어요.',
          icon: Icons.list_alt_outlined,
          onTap: () => _start(context, CivilDocumentV2Mode.guided),
        ),
        const SizedBox(height: 10),
        CivilChoiceRow(
          label: '이용 방법',
          subtitle: '서류 선택, 본인 확인, 옵션, 결제, 출력 순서예요.',
          icon: Icons.info_outline,
          onTap: () => _showInfo(context),
        ),
        const SizedBox(height: 10),
        CivilChoiceRow(
          label: '직원에게 도움 요청',
          subtitle: '현장에서 어려우면 언제든지 도움을 요청해도 돼요.',
          icon: Icons.support_agent_outlined,
          onTap: () => _showInfo(context),
        ),
        const SizedBox(height: 16),
        const Text('현장 발급기는 개인정보 보호를 위해 일정 시간 조작이 없으면 처음 화면으로 돌아갈 수 있어요.'),
      ],
    ),
  );

  void _showInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('이용 안내'),
      content: const Text(
        '제출할 기관에 필요한 증명서와 공개 범위를 먼저 확인하세요. 잘 모르면 직원에게 물어보세요.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

class CivilDocumentV2MissionPage extends StatefulWidget {
  const CivilDocumentV2MissionPage({super.key});
  @override
  State<CivilDocumentV2MissionPage> createState() =>
      _CivilDocumentV2MissionPageState();
}

class _CivilDocumentV2MissionPageState
    extends State<CivilDocumentV2MissionPage> {
  bool _prepared = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    final progress = context.read<LearningProgressProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CivilDocumentV2Provider>().begin(
        CivilDocumentV2Mode.solo,
        completedCount: progress.civilDocumentSoloCompletionCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CivilDocumentV2Provider>();
    return CivilKioskScaffold(
      onBack: () {
        context.read<DailyMissionProvider>().cancelActiveMission();
        context.go(AppRoutes.civilDocumentStart);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CivilQuestion(
            '오늘의 서류 발급 미션',
            description: '발급 목표를 기억하고 직접 선택해 보세요.',
          ),
          const SizedBox(height: 18),
          CivilSummary(
            title: p.scenario.title,
            rows: [
              ('증명서', p.scenario.documentName),
              ...p.scenario.options.entries.map((e) => (e.key, e.value)),
              ('발급 부수', '${p.scenario.copies}부'),
              (
                '결제 연습',
                p.scenario.payment == CivilPaymentMethod.card ? '카드' : '현금',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const CivilNotice('힌트가 필요하면 각 화면에서 언제든지 확인할 수 있어요.'),
          const SizedBox(height: 22),
          civilPrimaryButton('혼자 해보기', () async {
            final progress = context.read<LearningProgressProvider>();
            final daily = context.read<DailyMissionProvider>();
            if (daily.activeMissionId != 'civil_document_solo_complete') {
              await progress.startCivilDocumentLearning(
                CivilDocumentLearningMode.solo,
              );
            }
            if (!context.mounted) return;
            p.begin(
              CivilDocumentV2Mode.solo,
              completedCount: progress.civilDocumentSoloCompletionCount,
            );
            context.go(AppRoutes.civilDocumentV2Categories);
          }),
        ],
      ),
    );
  }
}

class CivilDocumentV2FlowPage extends StatelessWidget {
  const CivilDocumentV2FlowPage({super.key, required this.pageStep});
  final CivilDocumentV2Step pageStep;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CivilDocumentV2Provider>();
    return CivilKioskScaffold(
      step: pageStep.index + 1,
      modeLabel: practiceSessionLabel(
        isFreePractice: p.isFreePractice,
        isSolo: p.isSolo,
      ),
      onBack: () => _back(context, p),
      bottom: _bottom(context, p),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
        children: [
          if (p.isSolo) ...[_hint(context, p), const SizedBox(height: 12)],
          if (p.notice != null) ...[
            CivilNotice(p.notice!),
            const SizedBox(height: 12),
          ],
          ..._content(context, p),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, CivilDocumentV2Provider p) =>
      switch (pageStep) {
        CivilDocumentV2Step.categories => _categories(context, p),
        CivilDocumentV2Step.documents => _documents(context, p),
        CivilDocumentV2Step.availability => [
          CivilQuestion('발급 안내를 확인해 볼까요?', description: p.document?.use),
          const SizedBox(height: 16),
          const CivilNotice(
            '실제 발급 가능 여부와 수수료는 기관·지역·기기에 따라 다를 수 있어요.',
            warning: true,
          ),
        ],
        CivilDocumentV2Step.identity => [
          const CivilQuestion('가상 본인 확인', description: '실제 개인정보를 입력하지 않아요.'),
          const SizedBox(height: 16),
          const CivilSummary(
            title: '연습용 가상 인물',
            rows: [('이름', '김한걸음 (연습용)'), ('주소', '한걸음시 디지털로 100 (연습용)')],
          ),
          const SizedBox(height: 12),
          const CivilNotice('주민등록번호, 주소, 신분증, 휴대전화 정보를 받지 않아요.'),
        ],
        CivilDocumentV2Step.fingerprint => [
          const CivilQuestion(
            '지문 인식을 연습해 볼까요?',
            description: '실제 지문을 수집하지 않는 상태 연습입니다.',
          ),
          const SizedBox(height: 26),
          const Center(
            child: Icon(Icons.fingerprint, size: 96, color: civilNavy),
          ),
          const SizedBox(height: 18),
          CivilNotice(
            p.fingerprintAttempts == 0
                ? '손가락을 센서 위에 편안히 올려두는 순서를 연습해요.'
                : '손가락 위치와 압력을 조정해 다시 인식해 보세요.',
          ),
        ],
        CivilDocumentV2Step.options => _options(context, p),
        CivilDocumentV2Step.copies => [
          CivilQuestion(
            '몇 부를 발급할까요?',
            description: '현재 ${p.copies}부 · 총 ${formatCivilWon(p.totalFee)}',
          ),
          const SizedBox(height: 18),
          for (final n in [1, 2, 3]) ...[
            CivilChoiceRow(
              label: '$n부',
              subtitle: '총 가상 수수료 ${formatCivilWon(p.feePerCopy * n)}',
              icon: Icons.copy_outlined,
              selected: p.copies == n,
              onTap: () {
                if (p.chooseCopies(n)) {
                  context.go(AppRoutes.civilDocumentV2Review);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
        CivilDocumentV2Step.review => _review(context, p),
        CivilDocumentV2Step.payment => _payment(context, p),
        CivilDocumentV2Step.printing => [
          CivilQuestion(
            p.printed ? '증명서 출력 연습을 완료했어요.' : '증명서를 출력해 볼까요?',
            description: '실제 프린터나 문서 파일을 사용하지 않아요.',
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.print_outlined, size: 110, color: civilNavy),
                Transform.rotate(
                  angle: -0.25,
                  child: const Text(
                    '연습용',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (p.printing) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
          ],
        ],
        CivilDocumentV2Step.collection => [
          const CivilQuestion('증명서를 챙기고 안전하게 종료해요.'),
          const SizedBox(height: 18),
          CivilChoiceRow(
            label: p.documentRetrieved ? '증명서를 챙겼어요' : '증명서 챙기기',
            subtitle: '출력물을 남기지 않도록 확인해요.',
            icon: Icons.description_outlined,
            selected: p.documentRetrieved,
            onTap: p.retrieveDocument,
          ),
          const SizedBox(height: 12),
          CivilChoiceRow(
            label: p.safelyFinished ? '안전 종료를 확인했어요' : '개인정보 안전 종료',
            subtitle: '화면에 남은 정보가 없는지 확인해요.',
            icon: Icons.lock_outline,
            selected: p.safelyFinished,
            onTap: p.finishSafely,
          ),
        ],
      };

  List<Widget> _categories(BuildContext context, CivilDocumentV2Provider p) {
    const labels = {
      CivilDocumentCategory.resident: ('주민등록', '등본·초본'),
      CivilDocumentCategory.family: ('가족관계', '가족관계증명서·기본증명서'),
      CivilDocumentCategory.land: ('토지·건축', '건축물대장'),
      CivilDocumentCategory.tax: ('지방세', '세목별 과세증명'),
      CivilDocumentCategory.health: ('건강보험', '자격확인서 · 연습 준비 중'),
      CivilDocumentCategory.education: ('교육', '졸업증명서 · 연습 준비 중'),
      CivilDocumentCategory.other: ('기타 증명', '연습 준비 중'),
    };
    return [
      const CivilQuestion('어떤 분야의 증명서가 필요한가요?'),
      const SizedBox(height: 12),
      const CivilNotice('실제 기기마다 발급 가능한 서류가 다를 수 있어요.', warning: true),
      const SizedBox(height: 12),
      for (final e in labels.entries) ...[
        CivilChoiceRow(
          label: e.value.$1,
          subtitle: e.value.$2,
          icon: civilCategoryIcon(e.key),
          onTap: () {
            if (p.chooseCategory(e.key)) {
              context.go(AppRoutes.civilDocumentV2Documents);
            }
          },
        ),
        const SizedBox(height: 8),
      ],
    ];
  }

  List<Widget> _documents(BuildContext context, CivilDocumentV2Provider p) => [
    const CivilQuestion('발급할 증명서를 골라 보세요.'),
    const SizedBox(height: 14),
    for (final d in civilPracticeDocuments.where(
      (d) => d.category == p.category,
    )) ...[
      CivilChoiceRow(
        label: d.name,
        subtitle: '${d.use} · 가상 수수료 ${formatCivilWon(d.fee)}/부',
        icon: Icons.description_outlined,
        onTap: () {
          if (p.chooseDocument(d)) {
            context.go(AppRoutes.civilDocumentV2Availability);
          }
        },
      ),
      const SizedBox(height: 10),
    ],
  ];
  List<Widget> _options(BuildContext context, CivilDocumentV2Provider p) {
    final entries = p.scenario.options.entries.toList();
    return [
      const CivilQuestion(
        '표시할 내용을 확인해 볼까요?',
        description: '제출 기관이 요구하는 항목을 먼저 확인하세요.',
      ),
      const SizedBox(height: 12),
      const CivilNotice('주민등록번호 뒷자리는 꼭 필요한 경우에만 표시하세요.', warning: true),
      const SizedBox(height: 14),
      for (final e in entries) ...[
        Text(e.key, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        CivilChoiceRow(
          label: '${e.key}: ${e.value}',
          icon: Icons.check_circle_outline,
          selected: p.options[e.key] == e.value,
          onTap: () => p.chooseOption(e.key, e.value),
        ),
        const SizedBox(height: 8),
        CivilChoiceRow(
          label: switch (e.value) {
            '표시 안 함' => '표시',
            '포함 안 함' => '포함',
            '일반' => '상세',
            _ => '다른 선택',
          },
          icon: Icons.radio_button_unchecked,
          onTap: () => p.chooseOption(e.key, '다른 선택'),
        ),
        const SizedBox(height: 14),
      ],
    ];
  }

  List<Widget> _review(BuildContext context, CivilDocumentV2Provider p) => [
    const CivilQuestion('신청 내용을 확인해 볼까요?'),
    const SizedBox(height: 14),
    CivilSummary(
      rows: [
        ('증명서', p.document?.name ?? '-'),
        ('발급 대상', '본인 (연습용)'),
        ...p.options.entries.map((e) => (e.key, e.value)),
        ('개인정보 표시', '******-*******'),
        ('발급 부수', '${p.copies}부'),
        ('1부당 가상 수수료', formatCivilWon(p.feePerCopy)),
        ('총 가상 수수료', formatCivilWon(p.totalFee)),
      ],
    ),
    const SizedBox(height: 12),
    const CivilNotice('실제 개인정보가 아니며 행정기관에 신청되지 않아요.'),
    const SizedBox(height: 14),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: () {
            p.goTo(CivilDocumentV2Step.documents);
            context.go(AppRoutes.civilDocumentV2Documents);
          },
          child: const Text('증명서 수정'),
        ),
        OutlinedButton(
          onPressed: () {
            p.goTo(CivilDocumentV2Step.options);
            context.go(AppRoutes.civilDocumentV2Options);
          },
          child: const Text('옵션 수정'),
        ),
        OutlinedButton(
          onPressed: () {
            p.goTo(CivilDocumentV2Step.copies);
            context.go(AppRoutes.civilDocumentV2Copies);
          },
          child: const Text('부수 수정'),
        ),
      ],
    ),
  ];
  List<Widget> _payment(BuildContext context, CivilDocumentV2Provider p) => [
    const CivilQuestion('어떤 방법으로 결제를 연습할까요?'),
    const SizedBox(height: 12),
    CivilNotice(
      '연습용 가상 수수료 ${formatCivilWon(p.totalFee)} · 실제 결제는 이루어지지 않아요.',
      warning: true,
    ),
    const SizedBox(height: 14),
    CivilChoiceRow(
      label: '카드',
      subtitle: p.cardRetrieved ? '카드 챙김 완료' : '카드 넣기 → 결제 연습 → 카드 챙기기',
      icon: Icons.credit_card_outlined,
      selected: p.payment == CivilPaymentMethod.card,
      onTap: () => p.choosePayment(CivilPaymentMethod.card),
    ),
    const SizedBox(height: 10),
    CivilChoiceRow(
      label: '현금',
      subtitle: p.changeRetrieved ? '잔돈 챙김 완료' : '가상 현금 넣기 → 잔돈 확인 → 잔돈 챙기기',
      icon: Icons.payments_outlined,
      selected: p.payment == CivilPaymentMethod.cash,
      onTap: () => p.choosePayment(CivilPaymentMethod.cash),
    ),
    if (p.paymentProcessed) ...[
      const SizedBox(height: 14),
      CivilChoiceRow(
        label: p.payment == CivilPaymentMethod.card ? '카드를 챙겼어요' : '잔돈을 챙겼어요',
        icon: p.payment == CivilPaymentMethod.card
            ? Icons.credit_card
            : Icons.account_balance_wallet_outlined,
        selected: p.payment == CivilPaymentMethod.card
            ? p.cardRetrieved
            : p.changeRetrieved,
        onTap: p.payment == CivilPaymentMethod.card
            ? p.retrieveCard
            : p.retrieveChange,
      ),
    ],
  ];

  Widget _hint(BuildContext context, CivilDocumentV2Provider p) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextButton.icon(
        onPressed: p.toggleHint,
        icon: Icon(
          p.hintVisible
              ? Icons.visibility_off_outlined
              : Icons.lightbulb_outline,
        ),
        label: Text(p.hintVisible ? '힌트 닫기' : '힌트 보기'),
      ),
      if (p.hintVisible)
        CivilNotice(
          '힌트: ${p.scenario.documentName}, ${p.scenario.copies}부, ${p.scenario.payment == CivilPaymentMethod.card ? '카드' : '현금'} 결제를 선택해 보세요.',
        ),
    ],
  );

  Widget? _bottom(BuildContext context, CivilDocumentV2Provider p) {
    VoidCallback? action;
    var label = '다음';
    switch (pageStep) {
      case CivilDocumentV2Step.categories:
      case CivilDocumentV2Step.documents:
        action = null;
        label = '항목을 선택해 주세요';
      case CivilDocumentV2Step.availability:
        action = () {
          p.confirmAvailability();
          context.go(AppRoutes.civilDocumentV2Identity);
        };
        label = '발급 안내를 확인했어요';
      case CivilDocumentV2Step.identity:
        action = () {
          p.confirmIdentity();
          context.go(AppRoutes.civilDocumentV2Fingerprint);
        };
        label = '본인 확인 연습 시작';
      case CivilDocumentV2Step.fingerprint:
        action = () {
          if (p.scanFingerprint()) context.go(AppRoutes.civilDocumentV2Options);
        };
        label = p.fingerprintAttempts == 0 ? '지문 인식 시도' : '다시 인식하기';
      case CivilDocumentV2Step.options:
        action = p.options.length == p.scenario.options.length
            ? () {
                p.finishOptions();
                context.go(AppRoutes.civilDocumentV2Copies);
              }
            : null;
        label = '옵션 선택 완료';
      case CivilDocumentV2Step.copies:
        action = null;
        label = '발급 부수를 선택해 주세요';
      case CivilDocumentV2Step.review:
        action = () {
          p.confirmReview();
          context.go(AppRoutes.civilDocumentV2Payment);
        };
        label = '신청 내용 확인';
      case CivilDocumentV2Step.payment:
        if (p.payment == null) {
          action = null;
          label = '결제 방법을 선택해 주세요';
        } else if (!p.paymentProcessed) {
          action = () async {
            await p.processPayment();
          };
          label = '가상 결제 연습';
        } else if (!p.canPrint) {
          action = null;
          label = p.payment == CivilPaymentMethod.card
              ? '카드를 먼저 챙겨 주세요'
              : '잔돈을 먼저 챙겨 주세요';
        } else {
          action = () => context.go(AppRoutes.civilDocumentV2Printing);
          label = '증명서 출력으로';
        }
      case CivilDocumentV2Step.printing:
        action = p.printed
            ? () => context.go(AppRoutes.civilDocumentV2Collection)
            : () async {
                await p.startPrinting();
              };
        label = p.printed ? '증명서 챙기기' : '가상 출력 시작';
      case CivilDocumentV2Step.collection:
        action = p.canComplete
            ? () => context.go(AppRoutes.civilDocumentComplete)
            : null;
        label = '연습 완료하기';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        civilPrimaryButton(label, action),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _back(context, p),
                child: const Text('이전'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  context.read<DailyMissionProvider>().cancelActiveMission();
                  if (p.isFreePractice) {
                    p.beginFreePractice();
                    context.go(AppRoutes.civilDocumentV2Categories);
                    return;
                  }
                  await context
                      .read<LearningProgressProvider>()
                      .startCivilDocumentLearning(
                        p.isSolo
                            ? CivilDocumentLearningMode.solo
                            : CivilDocumentLearningMode.guided,
                      );
                  if (!context.mounted) return;
                  p.begin(
                    p.mode,
                    completedCount: context
                        .read<LearningProgressProvider>()
                        .civilDocumentSoloCompletionCount,
                  );
                  context.go(AppRoutes.civilDocumentV2Categories);
                },
                child: const Text('처음으로'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _back(BuildContext context, CivilDocumentV2Provider p) {
    if (pageStep == CivilDocumentV2Step.categories) {
      context.read<DailyMissionProvider>().cancelActiveMission();
      p.begin(
        p.mode,
        completedCount: context
            .read<LearningProgressProvider>()
            .civilDocumentSoloCompletionCount,
      );
      context.go(
        p.isSolo
            ? AppRoutes.civilDocumentMission
            : AppRoutes.civilDocumentStart,
      );
      return;
    }
    final previous = CivilDocumentV2Step.values[pageStep.index - 1];
    if (pageStep.index >= CivilDocumentV2Step.printing.index) {
      p.showNotice('출력과 회수 중에는 안전을 위해 이전 화면으로 돌아갈 수 없어요.');
      return;
    }
    p.goTo(previous);
    context.go(_routeFor(previous));
  }
}

String _routeFor(CivilDocumentV2Step step) => switch (step) {
  CivilDocumentV2Step.categories => AppRoutes.civilDocumentV2Categories,
  CivilDocumentV2Step.documents => AppRoutes.civilDocumentV2Documents,
  CivilDocumentV2Step.availability => AppRoutes.civilDocumentV2Availability,
  CivilDocumentV2Step.identity => AppRoutes.civilDocumentV2Identity,
  CivilDocumentV2Step.fingerprint => AppRoutes.civilDocumentV2Fingerprint,
  CivilDocumentV2Step.options => AppRoutes.civilDocumentV2Options,
  CivilDocumentV2Step.copies => AppRoutes.civilDocumentV2Copies,
  CivilDocumentV2Step.review => AppRoutes.civilDocumentV2Review,
  CivilDocumentV2Step.payment => AppRoutes.civilDocumentV2Payment,
  CivilDocumentV2Step.printing => AppRoutes.civilDocumentV2Printing,
  CivilDocumentV2Step.collection => AppRoutes.civilDocumentV2Collection,
};

class CivilDocumentV2CompletePage extends StatefulWidget {
  const CivilDocumentV2CompletePage({super.key});
  @override
  State<CivilDocumentV2CompletePage> createState() =>
      _CivilDocumentV2CompletePageState();
}

class _CivilDocumentV2CompletePageState
    extends State<CivilDocumentV2CompletePage> {
  bool _started = false;
  bool _badge = false;
  bool _daily = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final p = context.read<CivilDocumentV2Provider>();
    if (!p.canComplete) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => (_award(p)));
  }

  Future<void> _award(CivilDocumentV2Provider p) async {
    if (p.isFreePractice) return;
    final progress = context.read<LearningProgressProvider>();
    if (p.isSolo) {
      final before = progress.civilDocumentSoloCompletionCount;
      final badge = await progress.completeCivilDocumentSoloLearning();
      var daily = false;
      if (progress.civilDocumentSoloCompletionCount > before && mounted) {
        daily = await context
            .read<DailyMissionProvider>()
            .completeActiveMission(MissionContentType.civilDocument);
      }
      if (mounted) {
        setState(() {
          _badge = badge;
          _daily = daily;
        });
      }
    } else {
      await progress.completeCivilDocumentLearning();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CivilDocumentV2Provider>();
    final progress = context.watch<LearningProgressProvider>();
    return CivilKioskScaffold(
      onBack: () => context.go(AppRoutes.civilDocumentStart),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PracticeCompletionHeader(
            title: '증명서 발급 연습 완료',
            description: '실제 증명서가 발급된 것은 아니에요.',
            modeLabel: practiceSessionLabel(
              isFreePractice: p.isFreePractice,
              isSolo: p.isSolo,
              dailyMission: _daily,
            ),
          ),
          const SizedBox(height: 18),
          CivilSummary(
            rows: [
              ('연습한 증명서', p.document?.name ?? '-'),
              ('개인정보 공개', p.options['주민등록번호 뒷자리'] ?? '표시 안 함'),
              ('발급 부수', '${p.copies}부'),
              ('총 가상 수수료', formatCivilWon(p.totalFee)),
              ('결제 연습', p.payment == CivilPaymentMethod.card ? '카드' : '현금'),
              (p.payment == CivilPaymentMethod.card ? '카드' : '잔돈', '챙김 완료'),
              ('증명서', '챙김 완료'),
            ],
          ),
          const SizedBox(height: 12),
          CivilNotice(
            p.isFreePractice
                ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                : p.isSolo
                ? '용기 포인트 +20점${_daily ? ' · 오늘의 미션 +10점' : ''}'
                : '한걸음 포인트 +10점',
          ),
          if (_badge) ...[
            const SizedBox(height: 8),
            const CivilNotice('새 배지: 혼자 서류 발급 첫걸음'),
          ],
          const SizedBox(height: 12),
          Text('현재 ${progress.totalPoints}점', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const CivilNotice(
            '실제 증명서가 발급되지 않았고 행정기관에 신청되지 않았습니다. 실제 기기는 화면과 수수료가 다를 수 있으며, 제출 기관이 요구하는 서류와 공개 범위를 먼저 확인하세요.',
            warning: true,
          ),
          const SizedBox(height: 20),
          civilPrimaryButton('다시 연습하기', () async {
            if (p.isFreePractice) {
              p.beginFreePractice();
              context.go(AppRoutes.civilDocumentV2Categories);
              return;
            }
            await progress.startCivilDocumentLearning(
              p.isSolo
                  ? CivilDocumentLearningMode.solo
                  : CivilDocumentLearningMode.guided,
            );
            if (!context.mounted) return;
            p.begin(
              p.mode,
              completedCount: progress.civilDocumentSoloCompletionCount,
            );
            context.go(
              p.isSolo
                  ? AppRoutes.civilDocumentMission
                  : AppRoutes.civilDocumentV2Categories,
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.civilDocumentStart),
            child: const Text('다른 증명서 연습'),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.practice),
            child: const Text('다른 학습 보기'),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }
}
