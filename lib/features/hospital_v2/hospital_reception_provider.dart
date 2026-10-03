import 'package:flutter/foundation.dart';

enum HospitalReceptionStep {
  welcome,
  service,
  visit,
  patient,
  reservation,
  department,
  symptom,
  review,
}

class HospitalScenario {
  const HospitalScenario({
    required this.title,
    required this.visit,
    required this.reservation,
    required this.department,
    required this.symptom,
  });

  final String title;
  final String visit;
  final String reservation;
  final String department;
  final String symptom;

  String get summary => '$visit · $reservation · $department · $symptom';
}

const hospitalSoloScenarios = <HospitalScenario>[
  HospitalScenario(
    title: '처음 방문 접수',
    visit: '처음 방문이에요',
    reservation: '예약하지 않았어요',
    department: '내과',
    symptom: '배가 불편해요',
  ),
  HospitalScenario(
    title: '예약한 정형외과 접수',
    visit: '전에 방문한 적 있어요',
    reservation: '예약했어요',
    department: '정형외과',
    symptom: '무릎이 아파요',
  ),
  HospitalScenario(
    title: '이비인후과 재진 접수',
    visit: '전에 방문한 적 있어요',
    reservation: '예약하지 않았어요',
    department: '이비인후과',
    symptom: '귀·코·목 관련 불편함',
  ),
];

const hospitalGuidedScenario = HospitalScenario(
  title: '안내를 따라 접수하기',
  visit: '전에 방문한 적 있어요',
  reservation: '예약했어요',
  department: '내과',
  symptom: '감기 증상',
);

class HospitalReceptionProvider extends ChangeNotifier {
  HospitalReceptionStep step = HospitalReceptionStep.welcome;
  bool isSolo = false;
  bool isFreePractice = false;
  HospitalScenario scenario = hospitalGuidedScenario;
  String service = '진료 접수';
  String? visit;
  String patientNumber = '';
  String? reservation;
  String? department;
  String? symptom;
  String? notice;
  bool showHint = false;

  int get stepNumber => step.index + 1;
  int get totalSteps => HospitalReceptionStep.values.length;
  bool get patientNumberComplete => patientNumber == '19580412';

  void beginGuided() {
    isSolo = false;
    isFreePractice = false;
    scenario = hospitalGuidedScenario;
    _reset();
  }

  void beginSolo(int completedCount) {
    isSolo = true;
    isFreePractice = false;
    scenario =
        hospitalSoloScenarios[completedCount % hospitalSoloScenarios.length];
    _reset();
  }

  void beginFreePractice() {
    isSolo = false;
    isFreePractice = true;
    scenario = hospitalGuidedScenario;
    _reset();
  }

  void _reset() {
    step = HospitalReceptionStep.welcome;
    service = '진료 접수';
    visit = null;
    patientNumber = '';
    reservation = null;
    department = null;
    symptom = null;
    notice = null;
    showHint = false;
    notifyListeners();
  }

  void restart() => _reset();

  void clearSensitiveData() {
    patientNumber = '';
    notifyListeners();
  }

  void requestHelp() {
    notice = '연습 화면입니다. 실제 병원에서는 주변 직원이나 안내 데스크에 도움을 요청하세요.';
    notifyListeners();
  }

  void showPreparedService(String serviceName) {
    notice = '$serviceName 기능은 준비 중이에요. 이번에는 진료 접수를 연습해 볼게요.';
    notifyListeners();
  }

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  void next() {
    if (step.index < HospitalReceptionStep.values.length - 1) {
      step = HospitalReceptionStep.values[step.index + 1];
      notice = null;
      showHint = false;
      notifyListeners();
    }
  }

  void previous() {
    if (step.index > 0) {
      step = HospitalReceptionStep.values[step.index - 1];
      notice = null;
      showHint = false;
      _clearAfter(step);
      notifyListeners();
    }
  }

  bool chooseVisit(String value) =>
      _choose(value == scenario.visit, () => visit = value);

  bool chooseReservation(String value) =>
      _choose(value == scenario.reservation, () => reservation = value);

  bool chooseDepartment(String value) =>
      _choose(value == scenario.department, () => department = value);

  bool chooseSymptom(String value) =>
      _choose(value == scenario.symptom, () => symptom = value);

  bool _choose(bool correct, VoidCallback setValue) {
    if (!isFreePractice && !correct) {
      notice = isSolo
          ? '괜찮아요. 오늘의 접수 내용을 다시 살펴볼까요?'
          : '이번 연습의 안내를 다시 확인하고 선택해 볼까요?';
      notifyListeners();
      return false;
    }
    setValue();
    notice = null;
    next();
    return true;
  }

  void addDigit(String digit) {
    if (patientNumber.length >= 8) return;
    patientNumber += digit;
    notice = null;
    notifyListeners();
  }

  void removeDigit() {
    if (patientNumber.isEmpty) return;
    patientNumber = patientNumber.substring(0, patientNumber.length - 1);
    notifyListeners();
  }

  void clearPatientNumber() {
    patientNumber = '';
    notice = null;
    notifyListeners();
  }

  bool verifyPatient() {
    if (!patientNumberComplete) {
      notice = isSolo
          ? '괜찮아요. 미션의 생년월일 숫자 8자리를 다시 확인해 보세요.'
          : '연습용 생년월일 1958년 4월 12일을 숫자 8자리로 눌러보세요.';
      notifyListeners();
      return false;
    }
    next();
    return true;
  }

  void _clearAfter(HospitalReceptionStep current) {
    if (current.index < HospitalReceptionStep.visit.index) visit = null;
    if (current.index < HospitalReceptionStep.patient.index) patientNumber = '';
    if (current.index < HospitalReceptionStep.reservation.index) {
      reservation = null;
    }
    if (current.index < HospitalReceptionStep.department.index) {
      department = null;
    }
    if (current.index < HospitalReceptionStep.symptom.index) symptom = null;
  }
}
