import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import 'hospital_kiosk_widgets.dart';
import 'hospital_patient_verification.dart';
import 'hospital_reservation_provider.dart';

class HospitalReservationPracticePage extends StatelessWidget {
  const HospitalReservationPracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalReservationProvider>();

    void back() {
      if (provider.step == HospitalReservationStep.service) {
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
        bottom: _bottom(context, provider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.isSolo &&
                  provider.step == HospitalReservationStep.service) ...[
                const HospitalInlineNotice('오늘의 예약 확인 목표'),
                const SizedBox(height: 10),
                Text(
                  provider.targetReservation.targetSummary,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.showHint) ...[
                HospitalInlineNotice(
                  '힌트: ${provider.targetReservation.targetSummary} 예약을 찾아보세요.',
                ),
                const SizedBox(height: 12),
              ],
              if (provider.notice != null) ...[
                HospitalInlineNotice(provider.notice!),
                const SizedBox(height: 12),
              ],
              _body(context, provider),
              if (provider.isSolo &&
                  provider.step == HospitalReservationStep.selection) ...[
                const SizedBox(height: 12),
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

  Widget? _bottom(BuildContext context, HospitalReservationProvider provider) {
    if (provider.step == HospitalReservationStep.service) {
      return hospitalPrimaryButton(
        context,
        '예약 확인 시작하기',
        provider.enterPatientCheck,
      );
    }
    return null;
  }

  Widget _body(BuildContext context, HospitalReservationProvider provider) {
    switch (provider.step) {
      case HospitalReservationStep.service:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HospitalQuestion(
              title: '예약 확인',
              description: '미리 잡은 가상 진료 예약을 확인하는 연습이에요.',
            ),
            SizedBox(height: 16),
            HospitalInlineNotice('실제 병원 예약 정보와 연결되지 않는 연습 화면입니다.'),
          ],
        );
      case HospitalReservationStep.patient:
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
      case HospitalReservationStep.selection:
        return _reservationList(context, provider);
      case HospitalReservationStep.detail:
        return _reservationDetail(context, provider);
      case HospitalReservationStep.complete:
        return const SizedBox.shrink();
    }
  }

  Widget _reservationList(
    BuildContext context,
    HospitalReservationProvider provider,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const HospitalQuestion(
        title: '확인할 연습용 예약을 선택해 주세요.',
        description: '실제 병원 예약 정보가 아닙니다.',
      ),
      if (!provider.isSolo) ...[
        const SizedBox(height: 12),
        const HospitalInlineNotice('오늘 오전 10시 30분 내과 예약을 찾아보세요.'),
      ],
      const SizedBox(height: 18),
      for (final reservation in hospitalPracticeReservations) ...[
        Semantics(
          button: true,
          label:
              '${reservation.dateLabel} ${reservation.timeLabel}, ${reservation.department}, ${reservation.room}, ${reservation.purpose}, ${reservation.status}',
          child: InkWell(
            onTap: () => provider.selectReservation(reservation),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.event_available_outlined,
                    color: hospitalGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reservation.dateLabel} · ${reservation.timeLabel}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text('${reservation.department} · ${reservation.room}'),
                        Text(reservation.purpose),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 6),
                            Flexible(child: Text(reservation.status)),
                          ],
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
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: provider.requestHelp,
        icon: const Icon(Icons.support_agent_outlined),
        label: const Text('직원에게 도움 요청'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      ),
    ],
  );

  Widget _reservationDetail(
    BuildContext context,
    HospitalReservationProvider provider,
  ) {
    final reservation = provider.selectedReservation!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HospitalQuestion(title: '예약 상세 내용을 확인해 주세요.'),
        const SizedBox(height: 16),
        _DetailRow('예약 날짜', reservation.dateLabel),
        _DetailRow('예약 시간', reservation.timeLabel),
        _DetailRow('진료과', reservation.department),
        _DetailRow('진료실', reservation.room),
        _DetailRow('방문 목적', reservation.purpose),
        _DetailRow('예약 상태', reservation.status, checked: true),
        const _DetailRow('환자 확인', '가상 환자 확인 완료', checked: true),
        const SizedBox(height: 14),
        const HospitalInlineNotice('연습용 예약입니다. 실제 병원 예약과 연결되지 않습니다.'),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: provider.chooseAnotherReservation,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('다른 예약 선택하기'),
        ),
        const SizedBox(height: 10),
        hospitalPrimaryButton(context, '이 예약 확인하기', () {
          provider.complete();
          context.go(AppRoutes.hospitalReservationComplete);
        }),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: provider.requestHelp,
          icon: const Icon(Icons.support_agent_outlined),
          label: const Text('직원에게 도움 요청'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.checked = false});
  final String label;
  final String value;
  final bool checked;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
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
          const SizedBox(width: 6),
        ],
        Expanded(child: Text(value, softWrap: true)),
      ],
    ),
  );
}

class HospitalReservationCompletePage extends StatefulWidget {
  const HospitalReservationCompletePage({super.key});

  @override
  State<HospitalReservationCompletePage> createState() =>
      _HospitalReservationCompletePageState();
}

class _HospitalReservationCompletePageState
    extends State<HospitalReservationCompletePage> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveReward());
  }

  Future<void> _saveReward() async {
    if (_saving) return;
    _saving = true;
    final reservation = context.read<HospitalReservationProvider>();
    if (reservation.isFreePractice) return;
    await context
        .read<LearningProgressProvider>()
        .completeHospitalReservationLearning(solo: reservation.isSolo);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HospitalReservationProvider>();
    final reservation = provider.selectedReservation;
    if (reservation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.hospitalStepOne);
      });
      return const SizedBox.shrink();
    }
    return HospitalKioskScaffold(
      onBack: () {
        provider.reset();
        context.go(AppRoutes.hospitalStepOne);
      },
      step: 5,
      totalSteps: 5,
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
            const SizedBox(height: 12),
            Text(
              '예약 확인 연습을 완료했어요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _DetailRow('날짜', reservation.dateLabel),
            _DetailRow('시간', reservation.timeLabel),
            _DetailRow('진료과', reservation.department),
            _DetailRow('진료실', reservation.room),
            _DetailRow('방문 목적', reservation.purpose),
            _DetailRow('예약 상태', reservation.status, checked: true),
            const SizedBox(height: 14),
            HospitalInlineNotice(
              provider.isFreePractice
                  ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                  : provider.isSolo
                  ? '용기 포인트 +20점'
                  : '한걸음 포인트 +10점',
            ),
            const SizedBox(height: 12),
            const Text(
              '실제 병원 예약이 변경되거나 확인된 것은 아니에요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            const HospitalInlineNotice(
              '예약 시간보다 조금 일찍 도착하고 병원 안내에 따라 접수해 주세요. 변경이 필요하면 병원이나 직원에게 문의하세요. 병원마다 운영 방식이 다를 수 있어요.',
            ),
            const SizedBox(height: 22),
            hospitalPrimaryButton(context, '한 번 더 연습하기', () {
              if (provider.isFreePractice) {
                provider.beginFreePractice();
                context.go(AppRoutes.hospitalReservationPractice);
                return;
              }
              final progress = context.read<LearningProgressProvider>();
              progress.startHospitalReservationLearning(solo: provider.isSolo);
              provider.begin(
                solo: provider.isSolo,
                completedCount: provider.isSolo
                    ? progress.hospitalReservationSoloCompletionCount
                    : progress.hospitalReservationCompletionCount,
              );
              context.go(AppRoutes.hospitalReservationPractice);
            }),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                provider.reset();
                context.go(AppRoutes.hospitalStepOne);
              },
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
}
