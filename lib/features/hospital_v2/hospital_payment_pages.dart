import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import 'hospital_kiosk_widgets.dart';
import 'hospital_patient_verification.dart';
import 'hospital_payment_provider.dart';

class HospitalPaymentPracticePage extends StatelessWidget {
  const HospitalPaymentPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalPaymentProvider>();
    void back() {
      if (provider.step == HospitalPaymentStep.service) {
        provider.reset();
        context.go(AppRoutes.hospitalStepOne);
      } else {
        provider.previous();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: HospitalKioskScaffold(
        onBack: back,
        step: provider.stepNumber,
        totalSteps: provider.totalSteps,
        modeLabel: practiceSessionLabel(
          isFreePractice: provider.isFreePractice,
          isSolo: provider.isSolo,
        ),
        bottom: provider.step == HospitalPaymentStep.service
            ? hospitalPrimaryButton(
                context,
                '진료비 수납 시작하기',
                provider.enterPatientCheck,
              )
            : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.isSolo &&
                  provider.step == HospitalPaymentStep.service) ...[
                const HospitalInlineNotice('오늘의 진료비 수납 목표'),
                const SizedBox(height: 10),
                Text(
                  '${provider.targetBill.dateLabel} ${provider.targetBill.department} · ${formatPracticeWon(provider.targetBill.amount)} · ${hospitalPaymentMethodLabel(provider.targetMethod)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.showHint) ...[
                HospitalInlineNotice(
                  '힌트: ${provider.targetBill.dateLabel} ${provider.targetBill.department} ${formatPracticeWon(provider.targetBill.amount)}, ${hospitalPaymentMethodLabel(provider.targetMethod)}를 선택해 보세요.',
                ),
                const SizedBox(height: 12),
              ],
              if (provider.notice != null) ...[
                HospitalInlineNotice(provider.notice!),
                const SizedBox(height: 12),
              ],
              _body(context, provider),
              if (provider.isSolo &&
                  (provider.step == HospitalPaymentStep.selection ||
                      provider.step == HospitalPaymentStep.method)) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: provider.toggleHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('힌트 보기'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, HospitalPaymentProvider provider) {
    switch (provider.step) {
      case HospitalPaymentStep.service:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HospitalQuestion(
              title: '진료비 수납',
              description: '진료 후 가상 진료비를 확인하고 결제하는 연습이에요.',
            ),
            SizedBox(height: 16),
            HospitalInlineNotice('모든 금액과 결제는 연습용이며 실제 돈이 결제되지 않습니다.'),
          ],
        );
      case HospitalPaymentStep.patient:
        return HospitalPatientVerification(
          inputLength: provider.patientNumber.length,
          onDigit: provider.addDigit,
          onRemoveDigit: provider.removeDigit,
          onClear: provider.clearPatientNumber,
          onVerify: provider.patientNumber.length == 8
              ? provider.verifyPatient
              : null,
          onHelp: provider.requestHelp,
        );
      case HospitalPaymentStep.selection:
        return _billList(context, provider);
      case HospitalPaymentStep.detail:
        return _billDetail(context, provider);
      case HospitalPaymentStep.method:
        return _methodSelection(context, provider);
      case HospitalPaymentStep.practice:
        return _paymentPractice(context, provider);
      case HospitalPaymentStep.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _billList(
    BuildContext context,
    HospitalPaymentProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(
        title: '수납할 연습용 진료비를 선택해 주세요.',
        description: '실제 병원 진료비가 아니며 실제 결제도 이루어지지 않습니다.',
      ),
      if (!provider.isSolo) ...[
        const SizedBox(height: 12),
        const HospitalInlineNotice('오늘 내과 진찰료 18,500원을 찾아보세요.'),
      ],
      const SizedBox(height: 16),
      for (final bill in hospitalPracticeBills) ...[
        Semantics(
          button: bill.canPay,
          enabled: bill.canPay,
          label:
              '${bill.dateLabel}, ${bill.department}, ${bill.description}, ${formatPracticeWon(bill.amount)}, ${bill.status}, 연습용 가상 금액',
          child: InkWell(
            onTap: () => provider.selectBill(bill),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    bill.canPay
                        ? Icons.receipt_long_outlined
                        : Icons.check_circle_outline,
                    color: hospitalGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bill.dateLabel} · ${bill.department}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(bill.description),
                        const SizedBox(height: 5),
                        Text(
                          formatPracticeWon(bill.amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${bill.status} · 연습용 가상 금액'),
                      ],
                    ),
                  ),
                  Icon(bill.canPay ? Icons.chevron_right : Icons.lock_outline),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
      const SizedBox(height: 14),
      _helpButton(provider),
    ],
  );

  Widget _billDetail(BuildContext context, HospitalPaymentProvider provider) {
    final bill = provider.selectedBill!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HospitalQuestion(title: '진료비 상세 내용을 확인해 주세요.'),
        const SizedBox(height: 14),
        _PaymentRow('날짜', bill.dateLabel),
        _PaymentRow('진료과', bill.department),
        _PaymentRow('진료 내역', bill.description),
        _PaymentRow('가상 진료비', formatPracticeWon(bill.amount)),
        _PaymentRow('납부 상태', bill.status, checked: true),
        const SizedBox(height: 12),
        const HospitalInlineNotice('연습용 가상 진료비이며 실제 병원 청구와 연결되지 않습니다.'),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: provider.chooseAnotherBill,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('다른 내역 선택하기'),
        ),
        const SizedBox(height: 10),
        hospitalPrimaryButton(context, '이 진료비 수납하기', provider.continueToMethod),
      ],
    );
  }

  Widget _methodSelection(
    BuildContext context,
    HospitalPaymentProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(
        title: '결제 방법을 선택해 주세요.',
        description: '연습 화면이며 실제 결제는 진행되지 않습니다.',
      ),
      const SizedBox(height: 16),
      _methodTile(
        provider,
        HospitalPaymentMethod.card,
        Icons.credit_card,
        '카드 사용 순서를 연습해요.',
      ),
      _methodTile(
        provider,
        HospitalPaymentMethod.mobile,
        Icons.phone_android,
        '휴대전화 인식 순서를 연습해요.',
      ),
      _methodTile(
        provider,
        HospitalPaymentMethod.cash,
        Icons.payments_outlined,
        '실제 병원에서는 원무창구 직원에게 문의해요.',
      ),
      const SizedBox(height: 10),
      _helpButton(provider),
    ],
  );

  Widget _methodTile(
    HospitalPaymentProvider provider,
    HospitalPaymentMethod method,
    IconData icon,
    String description,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: HospitalChoice(
      label: hospitalPaymentMethodLabel(method),
      subtitle: description,
      icon: icon,
      onTap: () => provider.chooseMethod(method),
    ),
  );

  Widget _paymentPractice(
    BuildContext context,
    HospitalPaymentProvider provider,
  ) {
    final method = provider.paymentMethod!;
    final cash = method == HospitalPaymentMethod.cash;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HospitalQuestion(
          title: cash
              ? '현금 수납 위치를 확인해요.'
              : '${hospitalPaymentMethodLabel(method)} 순서를 연습해요.',
          description: cash
              ? '실제 병원에서는 원무창구 직원에게 현금 수납을 요청하세요.'
              : '실제 카드번호나 비밀번호를 입력하지 않습니다.',
        ),
        const SizedBox(height: 14),
        if (cash)
          const HospitalInlineNotice(
            '원무창구로 이동해 직원에게 문의하세요. 병원마다 현금 수납 위치가 다를 수 있으며 이 연습에서는 실제 돈을 사용하지 않아요.',
          ),
        for (
          var index = 0;
          index < provider.practiceActions.length;
          index++
        ) ...[
          _ActionRow(
            index: index,
            label: provider.practiceActions[index],
            completed: index < provider.practiceActionIndex,
            enabled: index == provider.practiceActionIndex,
            onTap: provider.advancePractice,
          ),
          const SizedBox(height: 8),
        ],
        if (provider.practiceComplete && !cash) ...[
          const SizedBox(height: 10),
          const HospitalInlineNotice('실제 병원에서는 진료비 내역 확인을 위해 영수증을 보관할 수 있어요.'),
          const SizedBox(height: 10),
          HospitalChoice(
            label: '영수증 받기',
            icon: Icons.receipt_long_outlined,
            selected: provider.wantsReceipt == true,
            onTap: () => provider.chooseReceipt(true),
          ),
          const SizedBox(height: 10),
          HospitalChoice(
            label: '영수증 받지 않기',
            icon: Icons.receipt_outlined,
            selected: provider.wantsReceipt == false,
            onTap: () => provider.chooseReceipt(false),
          ),
        ],
        if (provider.practiceComplete &&
            (cash || provider.wantsReceipt != null)) ...[
          const SizedBox(height: 14),
          hospitalPrimaryButton(
            context,
            cash ? '창구 안내 확인 완료' : '수납 연습 완료하기',
            () {
              provider.finish();
              context.go(AppRoutes.hospitalPaymentComplete);
            },
          ),
        ],
      ],
    );
  }

  Widget _helpButton(HospitalPaymentProvider provider) => OutlinedButton.icon(
    onPressed: provider.requestHelp,
    icon: const Icon(Icons.support_agent_outlined),
    label: const Text('직원에게 도움 요청'),
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.index,
    required this.label,
    required this.completed,
    required this.enabled,
    required this.onTap,
  });
  final int index;
  final String label;
  final bool completed;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: enabled,
    label: '${index + 1}단계 $label${completed ? ', 완료' : ''}',
    child: OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text('${index + 1}. $label'),
      ),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(58)),
    ),
  );
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow(this.label, this.value, {this.checked = false});
  final String label;
  final String value;
  final bool checked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        if (checked) ...[
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: hospitalGreen,
          ),
          const SizedBox(width: 5),
        ],
        Expanded(child: Text(value, softWrap: true)),
      ],
    ),
  );
}

class HospitalPaymentCompletePage extends StatefulWidget {
  const HospitalPaymentCompletePage({super.key});
  @override
  State<HospitalPaymentCompletePage> createState() =>
      _HospitalPaymentCompletePageState();
}

class _HospitalPaymentCompletePageState
    extends State<HospitalPaymentCompletePage> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_saving) return;
      _saving = true;
      final provider = context.read<HospitalPaymentProvider>();
      if (provider.isFreePractice) return;
      await context
          .read<LearningProgressProvider>()
          .completeHospitalPaymentLearning(solo: provider.isSolo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalPaymentProvider>();
    final bill = provider.selectedBill;
    if (bill == null || provider.paymentMethod == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.hospitalStepOne);
      });
      return const SizedBox.shrink();
    }
    final cash = provider.paymentMethod == HospitalPaymentMethod.cash;
    return HospitalKioskScaffold(
      onBack: () => _toService(context, provider),
      step: 7,
      totalSteps: 7,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 68,
              color: hospitalGreen,
            ),
            const SizedBox(height: 10),
            Text(
              cash ? '현금 수납 위치를 확인했어요' : '진료비 수납 연습을 완료했어요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            _PaymentRow('날짜', bill.dateLabel),
            _PaymentRow('진료과', bill.department),
            _PaymentRow('진료 내역', bill.description),
            _PaymentRow('가상 금액', formatPracticeWon(bill.amount)),
            _PaymentRow(
              '결제 방법',
              hospitalPaymentMethodLabel(provider.paymentMethod!),
            ),
            _PaymentRow(
              '영수증',
              cash ? '원무창구에서 확인' : (provider.wantsReceipt! ? '받기' : '받지 않기'),
            ),
            if (provider.wantsReceipt == true) ...[
              const Divider(height: 30),
              const Text(
                '연습용 가상 영수증',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _PaymentRow('진료과', bill.department),
              _PaymentRow('내역', bill.description),
              _PaymentRow('금액', formatPracticeWon(bill.amount)),
              _PaymentRow(
                '결제 방법',
                hospitalPaymentMethodLabel(provider.paymentMethod!),
              ),
              const Text('실제 영수증이 아닙니다.', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 12),
            HospitalInlineNotice(
              provider.isFreePractice
                  ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                  : provider.isSolo
                  ? '용기 포인트 +20점'
                  : '한걸음 포인트 +10점',
            ),
            const SizedBox(height: 12),
            HospitalInlineNotice(
              cash
                  ? '실제 병원에서는 원무창구 직원에게 현금 수납을 요청하세요. 이 연습에서는 실제 돈을 사용하지 않았어요.'
                  : provider.paymentMethod == HospitalPaymentMethod.card
                  ? '실제 키오스크에서는 결제 후 카드를 꼭 챙겨 주세요. 실제 결제가 진행된 것은 아니에요.'
                  : '실제 결제가 진행된 것은 아니에요.',
            ),
            const SizedBox(height: 20),
            hospitalPrimaryButton(context, '한 번 더 연습하기', () {
              if (provider.isFreePractice) {
                provider.beginFreePractice();
                context.go(AppRoutes.hospitalPaymentPractice);
                return;
              }
              final progress = context.read<LearningProgressProvider>();
              progress.startHospitalPaymentLearning(solo: provider.isSolo);
              provider.begin(
                solo: provider.isSolo,
                completedCount: provider.isSolo
                    ? progress.hospitalPaymentSoloCompletionCount
                    : progress.hospitalPaymentCompletionCount,
              );
              context.go(AppRoutes.hospitalPaymentPractice);
            }),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => _toService(context, provider),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('업무 선택으로 가기'),
            ),
            TextButton(
              onPressed: () {
                provider.reset();
                context.go(AppRoutes.home);
              },
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }

  void _toService(BuildContext context, HospitalPaymentProvider provider) {
    provider.reset();
    context.go(AppRoutes.hospitalStepOne);
  }
}
