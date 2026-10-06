import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'hospital_kiosk_widgets.dart';
import 'hospital_patient_verification.dart';
import 'hospital_reception_provider.dart';
import 'hospital_reservation_provider.dart';
import 'hospital_payment_provider.dart';
import 'hospital_document_provider.dart';

class HospitalV2StartPage extends StatelessWidget {
  const HospitalV2StartPage({super.key});

  @override
  Widget build(BuildContext context) => HospitalKioskScaffold(
    onBack: () => context.go(AppRoutes.home),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HospitalQuestion(
            title: '병원 접수 연습',
            description: '가상 무인 접수기로 접수 순서를 천천히 연습해요.',
          ),
          const SizedBox(height: 20),
          const HospitalInlineNotice(
            '연습용 화면이에요. 실제 개인정보를 입력하거나 병원으로 전송하지 않아요.',
          ),
          const SizedBox(height: 24),
          HospitalChoice(
            label: '따라 해보기',
            subtitle: '화면의 안내를 보며 하나씩 접수해요.',
            icon: Icons.assistant_outlined,
            emphasized: true,
            onTap: () {
              context.read<LearningProgressProvider>().selectHospitalMode(
                HospitalLearningMode.guided,
              );
              context.read<HospitalReceptionProvider>().beginGuided();
              context.go(AppRoutes.hospitalStepOne);
            },
          ),
          const SizedBox(height: 14),
          HospitalChoice(
            label: '혼자 해보기',
            subtitle: '오늘의 접수 미션을 기억하고 직접 해봐요.',
            icon: Icons.assignment_outlined,
            onTap: () {
              final progress = context.read<LearningProgressProvider>();
              progress.selectHospitalMode(HospitalLearningMode.solo);
              context.read<HospitalReceptionProvider>().beginSolo(
                progress.hospitalSoloCompletionCount,
              );
              context.go(AppRoutes.hospitalMission);
            },
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
            label: const Text('홈으로 돌아가기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
            ),
          ),
        ],
      ),
    ),
  );
}

class HospitalV2MissionPage extends StatelessWidget {
  const HospitalV2MissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reception = context.watch<HospitalReceptionProvider>();
    void leave() {
      reception.clearSensitiveData();
      context.read<DailyMissionProvider>().cancelActiveMission();
      context.go(AppRoutes.hospitalStart);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: HospitalKioskScaffold(
        onBack: leave,
        bottom: hospitalPrimaryButton(
          context,
          '혼자 접수해보기',
          () => context.go(AppRoutes.hospitalStepOne),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HospitalQuestion(
                title: '오늘의 병원 접수 미션',
                description: '접수 내용을 기억하고 직접 선택해 보세요.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      reception.scenario.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 28),
                    _summaryRow('업무', '진료 접수'),
                    _summaryRow('방문', reception.scenario.visit),
                    _summaryRow('예약', reception.scenario.reservation),
                    _summaryRow('진료과', reception.scenario.department),
                    _summaryRow('불편한 곳', reception.scenario.symptom),
                    _summaryRow('연습용 생년월일', '1958년 4월 12일'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const HospitalInlineNotice('힌트가 필요하면 각 단계에서 언제든지 확인할 수 있어요.'),
            ],
          ),
        ),
      ),
    );
  }
}

class HospitalV2OrderPage extends StatelessWidget {
  const HospitalV2OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reception = context.watch<HospitalReceptionProvider>();
    void back() {
      if (reception.step == HospitalReceptionStep.welcome) {
        reception.clearSensitiveData();
        if (reception.isSolo) {
          context.read<DailyMissionProvider>().cancelActiveMission();
        }
        context.go(
          reception.isSolo
              ? AppRoutes.hospitalMission
              : AppRoutes.hospitalStart,
        );
      } else {
        reception.previous();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: HospitalKioskScaffold(
        onBack: back,
        step: reception.stepNumber,
        totalSteps: reception.totalSteps,
        modeLabel: practiceSessionLabel(
          isFreePractice: reception.isFreePractice,
          isSolo: reception.isSolo,
        ),
        bottom: _bottom(context, reception),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (reception.isSolo)
                TextButton.icon(
                  onPressed: reception.toggleHint,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('힌트 보기'),
                ),
              if (reception.showHint) ...[
                HospitalInlineNotice('힌트: ${reception.scenario.summary}'),
                const SizedBox(height: 14),
              ],
              if (reception.notice != null) ...[
                HospitalInlineNotice(reception.notice!),
                const SizedBox(height: 14),
              ],
              _stepBody(context, reception),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  reception.restart();
                  context
                      .read<LearningProgressProvider>()
                      .resetHospitalLearning();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('처음부터 다시 하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _bottom(BuildContext context, HospitalReceptionProvider p) {
    switch (p.step) {
      case HospitalReceptionStep.welcome:
        return hospitalPrimaryButton(context, '접수 시작하기', p.next);
      case HospitalReceptionStep.patient:
        return null;
      case HospitalReceptionStep.review:
        return hospitalPrimaryButton(context, '접수 완료하기', () {
          final progress = context.read<LearningProgressProvider>();
          progress.selectHospitalVisitPurpose('진료 접수');
          progress.selectHospitalRegistrationMethod(p.visit ?? '');
          progress.selectHospitalDepartment(p.department ?? '');
          context.go(AppRoutes.hospitalComplete);
        });
      default:
        return null;
    }
  }

  Widget _stepBody(BuildContext context, HospitalReceptionProvider p) {
    switch (p.step) {
      case HospitalReceptionStep.welcome:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HospitalQuestion(
              title: '무인 접수를 시작할까요?',
              description: '화면을 천천히 읽고 필요한 항목을 선택해 주세요.',
            ),
            const SizedBox(height: 20),
            const HospitalInlineNotice(
              '호흡이 매우 어렵거나 위급한 상황이라면 접수보다 먼저 가까운 직원이나 119에 도움을 요청하세요.',
              urgent: true,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: p.requestHelp,
              icon: const Icon(Icons.support_agent),
              label: const Text('도움이 필요해요'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
              ),
            ),
          ],
        );
      case HospitalReceptionStep.service:
        return _choices(context, '원하는 업무를 선택해 주세요.', [
          _choice(
            p,
            '진료 접수',
            Icons.medical_services_outlined,
            p.next,
            true,
            subtitle: '진료를 받기 위한 접수를 연습해요.',
          ),
          _choice(
            p,
            '예약 확인',
            Icons.event_note_outlined,
            () {
              final progress = context.read<LearningProgressProvider>();
              p.clearSensitiveData();
              final provider = context.read<HospitalReservationProvider>();
              if (p.isFreePractice) {
                provider.beginFreePractice();
              } else {
                progress.startHospitalReservationLearning(solo: p.isSolo);
                provider.begin(
                  solo: p.isSolo,
                  completedCount: p.isSolo
                      ? progress.hospitalReservationSoloCompletionCount
                      : progress.hospitalReservationCompletionCount,
                );
              }
              context.go(AppRoutes.hospitalReservationPractice);
            },
            false,
            subtitle: '미리 잡은 가상 진료 예약을 확인하는 연습이에요.',
          ),
          _choice(
            p,
            '진료비 수납',
            Icons.payments_outlined,
            () {
              final progress = context.read<LearningProgressProvider>();
              p.clearSensitiveData();
              context.read<HospitalReservationProvider>().reset();
              final provider = context.read<HospitalPaymentProvider>();
              if (p.isFreePractice) {
                provider.beginFreePractice();
              } else {
                progress.startHospitalPaymentLearning(solo: p.isSolo);
                provider.begin(
                  solo: p.isSolo,
                  completedCount: p.isSolo
                      ? progress.hospitalPaymentSoloCompletionCount
                      : progress.hospitalPaymentCompletionCount,
                );
              }
              context.go(AppRoutes.hospitalPaymentPractice);
            },
            false,
            subtitle: '진료 후 가상 진료비를 확인하고 결제하는 연습이에요.',
          ),
          _choice(
            p,
            '서류 발급',
            Icons.description_outlined,
            () {
              final progress = context.read<LearningProgressProvider>();
              p.clearSensitiveData();
              context.read<HospitalReservationProvider>().reset();
              context.read<HospitalPaymentProvider>().reset();
              final provider = context.read<HospitalDocumentProvider>();
              if (p.isFreePractice) {
                provider.beginFreePractice();
              } else {
                progress.startHospitalDocumentLearning(solo: p.isSolo);
                provider.begin(
                  solo: p.isSolo,
                  completedCount: p.isSolo
                      ? progress.hospitalDocumentSoloCompletionCount
                      : progress.hospitalDocumentCompletionCount,
                );
              }
              context.go(AppRoutes.hospitalDocumentPractice);
            },
            false,
            subtitle: '필요한 가상 병원 서류를 선택하고 발급하는 연습이에요.',
          ),
        ]);
      case HospitalReceptionStep.visit:
        return _choices(context, '병원에 방문한 적이 있나요?', [
          _choice(
            p,
            '처음 방문이에요',
            Icons.person_add_alt_1,
            () => p.chooseVisit('처음 방문이에요'),
            !p.isFreePractice && !p.isSolo && p.scenario.visit == '처음 방문이에요',
          ),
          _choice(
            p,
            '전에 방문한 적 있어요',
            Icons.history,
            () => p.chooseVisit('전에 방문한 적 있어요'),
            !p.isFreePractice &&
                !p.isSolo &&
                p.scenario.visit == '전에 방문한 적 있어요',
          ),
        ]);
      case HospitalReceptionStep.patient:
        return _patient(context, p);
      case HospitalReceptionStep.reservation:
        return _choices(context, '진료 예약을 하셨나요?', [
          _choice(
            p,
            '예약했어요',
            Icons.event_available,
            () => p.chooseReservation('예약했어요'),
            !p.isFreePractice && !p.isSolo && p.scenario.reservation == '예약했어요',
          ),
          _choice(
            p,
            '예약하지 않았어요',
            Icons.event_busy,
            () => p.chooseReservation('예약하지 않았어요'),
            !p.isFreePractice &&
                !p.isSolo &&
                p.scenario.reservation == '예약하지 않았어요',
          ),
        ]);
      case HospitalReceptionStep.department:
        return _choices(context, '진료받을 곳을 선택해 주세요.', [
          for (final item in const [
            ('내과', '감기나 배가 불편할 때 살펴보는 곳'),
            ('정형외과', '뼈나 관절이 불편할 때 살펴보는 곳'),
            ('이비인후과', '귀·코·목이 불편할 때 살펴보는 곳'),
            ('안과', '눈이 불편할 때 살펴보는 곳'),
            ('피부과', '피부가 불편할 때 살펴보는 곳'),
            ('신경과', '두통이나 어지럼 같은 불편함을 살펴보는 곳'),
          ])
            _choice(
              p,
              item.$1,
              Icons.local_hospital_outlined,
              () => p.chooseDepartment(item.$1),
              !p.isFreePractice &&
                  !p.isSolo &&
                  p.scenario.department == item.$1,
              subtitle: item.$2,
            ),
          _choice(
            p,
            '잘 모르겠어요',
            Icons.help_outline,
            p.requestHelp,
            false,
            subtitle: '가까운 직원에게 문의해도 괜찮아요.',
          ),
        ]);
      case HospitalReceptionStep.symptom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HospitalInlineNotice(
              '갑자기 매우 아프거나 위급하다면 가까운 직원이나 119에 도움을 요청하세요.',
              urgent: true,
            ),
            const SizedBox(height: 16),
            _choices(context, '어떤 불편함으로 방문하셨나요?', [
              for (final value in _symptomsFor(p.department))
                _choice(
                  p,
                  value,
                  Icons.health_and_safety_outlined,
                  () => p.chooseSymptom(value),
                  !p.isFreePractice && !p.isSolo && p.scenario.symptom == value,
                ),
            ]),
          ],
        );
      case HospitalReceptionStep.review:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HospitalQuestion(title: '접수 내용을 확인해 주세요.'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                children: [
                  _summaryRow('업무', p.service),
                  _summaryRow('방문', p.visit ?? '-'),
                  _summaryRow('환자', '김한걸음 (연습용)'),
                  _summaryRow('예약', p.reservation ?? '-'),
                  _summaryRow('진료과', p.department ?? '-'),
                  _summaryRow('방문 이유', p.symptom ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const HospitalInlineNotice('이 화면은 연습용이며 실제 병원에 접수되지 않아요.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: p.requestHelp,
              icon: const Icon(Icons.support_agent),
              label: const Text('직원 도움 안내'),
            ),
          ],
        );
    }
  }

  Widget _patient(BuildContext context, HospitalReceptionProvider p) =>
      HospitalPatientVerification(
        inputLength: p.patientNumber.length,
        onDigit: p.addDigit,
        onRemoveDigit: p.removeDigit,
        onClear: p.clearPatientNumber,
        onVerify: p.patientNumber.length == 8 ? p.verifyPatient : null,
        onHelp: p.requestHelp,
      );
  Widget _choices(
    BuildContext context,
    String question,
    List<Widget> choices,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HospitalQuestion(title: question),
      const SizedBox(height: 20),
      for (var i = 0; i < choices.length; i++) ...[
        choices[i],
        if (i != choices.length - 1) const SizedBox(height: 12),
      ],
    ],
  );

  Widget _choice(
    HospitalReceptionProvider p,
    String label,
    IconData icon,
    VoidCallback onTap,
    bool guide, {
    String? subtitle,
  }) => HospitalChoice(
    label: label,
    subtitle: subtitle,
    icon: icon,
    onTap: onTap,
    emphasized: guide,
  );

  List<String> _symptomsFor(String? department) => switch (department) {
    '내과' => ['감기 증상', '배가 불편해요', '기타·잘 모르겠어요'],
    '정형외과' => ['무릎이 아파요', '허리나 관절이 불편해요', '기타·잘 모르겠어요'],
    '이비인후과' => ['귀·코·목 관련 불편함', '목이 불편해요', '기타·잘 모르겠어요'],
    '안과' => ['눈이 불편해요', '시야가 불편해요', '기타·잘 모르겠어요'],
    '피부과' => ['피부가 불편해요', '가려움이 있어요', '기타·잘 모르겠어요'],
    '신경과' => ['두통이 있어요', '어지럼이 있어요', '기타·잘 모르겠어요'],
    _ => ['기타·잘 모르겠어요'],
  };
}

class HospitalV2CompletePage extends StatefulWidget {
  const HospitalV2CompletePage({super.key});
  @override
  State<HospitalV2CompletePage> createState() => _HospitalV2CompletePageState();
}

class _HospitalV2CompletePageState extends State<HospitalV2CompletePage> {
  bool firstBadge = false;
  bool dailyReward = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final progress = context.read<LearningProgressProvider>();
      final dailyMissions = context.read<DailyMissionProvider>();
      final reception = context.read<HospitalReceptionProvider>();
      if (reception.isFreePractice) {
        // 자유 연습은 보상과 완료 기록을 저장하지 않는다.
      } else if (progress.isHospitalSoloMode) {
        final before = progress.hospitalSoloCompletionCount;
        final badge = await progress.completeHospitalSoloLearning();
        var daily = false;
        if (progress.hospitalSoloCompletionCount > before) {
          daily = await dailyMissions.completeActiveMission(
            MissionContentType.hospital,
          );
        }
        if (mounted) {
          setState(() {
            firstBadge = badge;
            dailyReward = daily;
          });
        }
      } else {
        await progress.completeHospitalLearning();
      }
      if (mounted) {
        reception.clearSensitiveData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HospitalReceptionProvider>();
    final progress = context.watch<LearningProgressProvider>();
    return HospitalKioskScaffold(
      onBack: () => context.go(AppRoutes.home),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PracticeCompletionHeader(
              title: p.isFreePractice
                  ? '자유 연습을 마쳤어요'
                  : progress.isHospitalSoloMode
                  ? '혼자서도 잘하셨어요!'
                  : '진료 접수 연습을 완료했어요!',
              description: '실제 접수가 진행된 것은 아니에요.',
              modeLabel: practiceSessionLabel(
                isFreePractice: p.isFreePractice,
                isSolo: progress.isHospitalSoloMode,
                dailyMission: dailyReward,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _summaryRow('접수 번호', 'A-023 (연습용)'),
                  _summaryRow('방문', p.visit ?? '-'),
                  _summaryRow('진료과', p.department ?? '-'),
                  _summaryRow('방문 이유', p.symptom ?? '-'),
                  _summaryRow('예약', p.reservation ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            HospitalInlineNotice(
              p.isFreePractice
                  ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                  : progress.isHospitalSoloMode
                  ? '용기 포인트 +20점${dailyReward ? ' · 오늘의 미션 +10점' : ''}'
                  : '한걸음 포인트 +10점',
            ),
            if (firstBadge) ...[
              const SizedBox(height: 10),
              const HospitalInlineNotice('새 배지: 혼자 병원 접수 첫걸음'),
            ],
            const SizedBox(height: 14),
            const Text(
              '실제 접수가 진행된 것은 아니에요. 실제 병원에서는 접수증과 호출 화면을 확인해 주세요.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            const SizedBox(height: 24),
            hospitalPrimaryButton(context, '한 번 더 연습하기', () {
              context.read<LearningProgressProvider>().resetHospitalLearning();
              if (p.isFreePractice) {
                p.beginFreePractice();
                context.go(AppRoutes.hospitalStepOne);
              } else if (p.isSolo) {
                p.beginSolo(progress.hospitalSoloCompletionCount);
                context.go(AppRoutes.hospitalMission);
              } else {
                p.beginGuided();
                context.go(AppRoutes.hospitalStepOne);
              }
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_outlined),
              label: const Text('홈으로 가기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 9),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 90,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(value, textAlign: TextAlign.right, softWrap: true)),
    ],
  ),
);
