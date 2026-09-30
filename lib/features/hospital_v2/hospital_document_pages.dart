import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import 'hospital_document_provider.dart';
import 'hospital_kiosk_widgets.dart';
import 'hospital_patient_verification.dart';
import 'hospital_payment_provider.dart';

class HospitalDocumentPracticePage extends StatelessWidget {
  const HospitalDocumentPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalDocumentProvider>();
    void back() {
      if (provider.step == HospitalDocumentStep.service) {
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
        bottom: provider.step == HospitalDocumentStep.service
            ? hospitalPrimaryButton(
                context,
                '서류 발급 시작하기',
                provider.enterPatientCheck,
              )
            : null,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.isSolo &&
                  provider.step == HospitalDocumentStep.service) ...[
                const HospitalInlineNotice('오늘의 서류 발급 목표'),
                const SizedBox(height: 10),
                Text(
                  '${provider.targetDocument.name} · ${provider.scenario.purpose} · ${provider.scenario.copies}부 · ${hospitalDocumentPaymentLabel(provider.scenario.paymentMethod)}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.showHint) ...[
                HospitalInlineNotice(_hint(provider)),
                const SizedBox(height: 12),
              ],
              if (provider.notice != null) ...[
                HospitalInlineNotice(provider.notice!),
                const SizedBox(height: 12),
              ],
              _body(context, provider),
              if (provider.isSolo && _canHint(provider.step)) ...[
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

  bool _canHint(HospitalDocumentStep step) =>
      step == HospitalDocumentStep.document ||
      step == HospitalDocumentStep.purpose ||
      step == HospitalDocumentStep.copies ||
      step == HospitalDocumentStep.practice;

  String _hint(HospitalDocumentProvider provider) => switch (provider.step) {
    HospitalDocumentStep.document =>
      '힌트: ${provider.targetDocument.name}를 선택해 보세요.',
    HospitalDocumentStep.purpose =>
      '힌트: ${provider.scenario.purpose}을 선택해 보세요.',
    HospitalDocumentStep.copies => '힌트: ${provider.scenario.copies}부를 선택해 보세요.',
    HospitalDocumentStep.practice =>
      '힌트: ${hospitalDocumentPaymentLabel(provider.scenario.paymentMethod)} 순서를 연습하고 출력된 서류를 챙겨 보세요.',
    _ => '필요한 내용을 천천히 다시 확인해 보세요.',
  };

  Widget _body(BuildContext context, HospitalDocumentProvider provider) =>
      switch (provider.step) {
        HospitalDocumentStep.service => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HospitalQuestion(
              title: '서류 발급',
              description: '필요한 가상 병원 서류를 선택하고 발급하는 연습이에요.',
            ),
            SizedBox(height: 16),
            HospitalInlineNotice('실제 개인정보를 입력하지 않으며 실제 서류가 발급되지 않습니다.'),
          ],
        ),
        HospitalDocumentStep.patient => HospitalPatientVerification(
          inputLength: provider.patientNumber.length,
          onDigit: provider.addDigit,
          onRemoveDigit: provider.removeDigit,
          onClear: provider.clearPatientNumber,
          onVerify: provider.patientNumber.length == 8
              ? provider.verifyPatient
              : null,
          onHelp: provider.requestHelp,
        ),
        HospitalDocumentStep.document => _documents(context, provider),
        HospitalDocumentStep.purpose => _purposes(provider),
        HospitalDocumentStep.copies => _copies(context, provider),
        HospitalDocumentStep.review => _review(context, provider),
        HospitalDocumentStep.practice => _practice(context, provider),
        HospitalDocumentStep.complete => const SizedBox.shrink(),
      };

  Widget _documents(
    BuildContext context,
    HospitalDocumentProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(
        title: '발급할 연습용 서류를 선택해 주세요.',
        description: '병원마다 발급 가능한 서류와 수수료가 다를 수 있습니다.',
      ),
      if (!provider.isSolo) ...[
        const SizedBox(height: 12),
        const HospitalInlineNotice('통원확인서를 선택해 보세요.'),
      ],
      const SizedBox(height: 12),
      for (final document in hospitalPracticeDocuments) ...[
        Semantics(
          button: true,
          label:
              '${document.name}, ${document.description}, ${document.kioskAvailable ? '${formatPracticeWon(document.fee)}, 발급 가능' : '창구 발급 필요'}',
          child: InkWell(
            onTap: () => provider.selectDocument(document),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    document.kioskAvailable
                        ? Icons.description_outlined
                        : Icons.support_agent_outlined,
                    color: hospitalGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(document.description, softWrap: true),
                        const SizedBox(height: 4),
                        Text(
                          document.kioskAvailable
                              ? '${formatPracticeWon(document.fee)} · 발급 가능'
                              : '창구 발급 필요',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
      const SizedBox(height: 14),
      _help(provider),
    ],
  );

  Widget _purposes(HospitalDocumentProvider provider) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(
        title: '어디에 제출할 서류인가요?',
        description: '개인정보나 자세한 사유는 입력하지 않아요.',
      ),
      const SizedBox(height: 14),
      for (final purpose in hospitalDocumentPurposes) ...[
        HospitalChoice(
          label: purpose,
          icon: Icons.outbox_outlined,
          onTap: () => provider.selectPurpose(purpose),
        ),
        const SizedBox(height: 10),
      ],
    ],
  );

  Widget _copies(
    BuildContext context,
    HospitalDocumentProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(title: '몇 부를 발급할까요?'),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final count in const [1, 2, 3])
            SizedBox(
              width: 92,
              child: OutlinedButton(
                onPressed: () => provider.selectCopies(count),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                ),
                child: Text('$count부'),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      HospitalInlineNotice(
        '1부 수수료 ${formatPracticeWon(provider.selectedDocument!.fee)} · 선택한 부수에 따라 총액이 계산돼요.',
      ),
    ],
  );

  Widget _review(
    BuildContext context,
    HospitalDocumentProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(title: '신청 내용을 확인해 주세요.'),
      const SizedBox(height: 14),
      _row('서류', provider.selectedDocument!.name),
      _row('제출 용도', provider.purpose!),
      _row('발급 부수', '${provider.copies}부'),
      _row('1부 수수료', formatPracticeWon(provider.selectedDocument!.fee)),
      _row('총 가상 수수료', formatPracticeWon(provider.totalFee)),
      _row('환자 확인', '연습용 확인 완료'),
      const SizedBox(height: 12),
      const HospitalInlineNotice('실제 개인정보가 없고 실제 서류가 발급되지 않는 연습 화면입니다.'),
      const SizedBox(height: 14),
      OutlinedButton(
        onPressed: provider.editApplication,
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: const Text('신청 내용 수정하기'),
      ),
      const SizedBox(height: 10),
      hospitalPrimaryButton(context, '결제 연습으로 가기', provider.continueToPayment),
    ],
  );

  Widget _practice(BuildContext context, HospitalDocumentProvider provider) {
    if (provider.paymentMethod == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HospitalQuestion(
            title: '결제 방법을 선택해 주세요.',
            description: '실제 결제 정보는 입력하거나 저장하지 않습니다.',
          ),
          const SizedBox(height: 14),
          for (final method in HospitalPaymentMethod.values) ...[
            HospitalChoice(
              label: hospitalDocumentPaymentLabel(method),
              subtitle: method == HospitalPaymentMethod.cash
                  ? '실제 병원에서는 원무창구에 문의해요.'
                  : '가상 결제 순서를 연습해요.',
              icon: switch (method) {
                HospitalPaymentMethod.card => Icons.credit_card,
                HospitalPaymentMethod.mobile => Icons.phone_android,
                HospitalPaymentMethod.cash => Icons.payments_outlined,
              },
              onTap: () => provider.choosePaymentMethod(method),
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HospitalQuestion(
          title: provider.paymentComplete ? '서류를 출력해 볼까요?' : '가상 결제 순서를 연습해요.',
          description: provider.paymentMethod == HospitalPaymentMethod.cash
              ? '실제 병원에서는 직원에게 현금 발급 가능 여부를 문의하세요.'
              : '실제 카드나 결제 정보는 사용하지 않아요.',
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < provider.paymentActions.length; i++) ...[
          _action(
            i,
            provider.paymentActions[i],
            i < provider.paymentActionIndex,
            i == provider.paymentActionIndex,
            provider.advancePayment,
          ),
          const SizedBox(height: 8),
        ],
        if (provider.paymentComplete && !provider.printingComplete)
          hospitalPrimaryButton(context, '출력이 끝났어요', provider.completePrinting),
        if (provider.printingComplete && !provider.documentTaken) ...[
          const HospitalInlineNotice('실제 키오스크에서는 출력된 서류와 카드를 모두 챙겨 주세요.'),
          const SizedBox(height: 12),
          hospitalPrimaryButton(context, '서류를 챙겼어요', provider.takeDocument),
        ],
        if (provider.documentTaken) ...[
          const HospitalInlineNotice('서류를 챙겼어요. 이제 연습을 마칠 수 있어요.'),
          const SizedBox(height: 12),
          hospitalPrimaryButton(context, '발급 연습 완료하기', () {
            if (provider.finish()) {
              context.go(AppRoutes.hospitalDocumentComplete);
            }
          }),
        ],
      ],
    );
  }

  Widget _action(
    int index,
    String label,
    bool done,
    bool enabled,
    VoidCallback tap,
  ) => OutlinedButton.icon(
    onPressed: enabled ? tap : null,
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(58)),
    icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
    label: Align(
      alignment: Alignment.centerLeft,
      child: Text('${index + 1}. $label'),
    ),
  );

  Widget _help(HospitalDocumentProvider provider) => OutlinedButton.icon(
    onPressed: provider.requestHelp,
    icon: const Icon(Icons.support_agent_outlined),
    label: const Text('직원에게 도움 요청'),
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, softWrap: true),
        ),
      ],
    ),
  );
}

class HospitalDocumentCompletePage extends StatefulWidget {
  const HospitalDocumentCompletePage({super.key});

  @override
  State<HospitalDocumentCompletePage> createState() =>
      _HospitalDocumentCompletePageState();
}

class _HospitalDocumentCompletePageState
    extends State<HospitalDocumentCompletePage> {
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saving) {
      _saving = true;
      final document = context.read<HospitalDocumentProvider>();
      context.read<LearningProgressProvider>().completeHospitalDocumentLearning(
        solo: document.isSolo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalDocumentProvider>();
    final progress = context.watch<LearningProgressProvider>();
    return HospitalKioskScaffold(
      onBack: () => context.go(AppRoutes.hospitalStepOne),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.task_alt, size: 62, color: hospitalGreen),
            const SizedBox(height: 14),
            Text(
              '서류 발급 연습이 완료되었어요!',
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _summary('서류', provider.selectedDocument?.name ?? '-'),
            _summary('제출 용도', provider.purpose ?? '-'),
            _summary('발급 부수', '${provider.copies}부'),
            _summary('총 가상 수수료', formatPracticeWon(provider.totalFee)),
            _summary(
              '결제 방식',
              provider.paymentMethod == null
                  ? '-'
                  : hospitalDocumentPaymentLabel(provider.paymentMethod!),
            ),
            _summary('발급 상태', '연습 완료'),
            const SizedBox(height: 14),
            HospitalInlineNotice(
              provider.isSolo ? '용기 포인트 +20점' : '한걸음 포인트 +10점',
            ),
            const SizedBox(height: 14),
            const Text(
              '실제 입력이 없는 연습용 서류입니다. 실제 병원마다 발급 방법과 수수료가 다를 수 있어요.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            const SizedBox(height: 8),
            const Text(
              '실제 키오스크에서는 카드와 출력된 서류를 꼭 챙겨 주세요.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            const SizedBox(height: 24),
            hospitalPrimaryButton(context, '한 번 더 연습하기', () {
              progress.startHospitalDocumentLearning(solo: provider.isSolo);
              provider.begin(
                solo: provider.isSolo,
                completedCount: provider.isSolo
                    ? progress.hospitalDocumentSoloCompletionCount
                    : progress.hospitalDocumentCompletionCount,
              );
              context.go(AppRoutes.hospitalDocumentPractice);
            }),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                provider.reset();
                context.go(AppRoutes.hospitalStepOne);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
              ),
              child: const Text('업무 선택으로 가기'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_outlined),
              label: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, softWrap: true),
        ),
      ],
    ),
  );
}
