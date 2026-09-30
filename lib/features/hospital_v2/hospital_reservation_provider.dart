import 'package:flutter/foundation.dart';

enum HospitalReservationStep { service, patient, selection, detail, complete }

class PracticeHospitalReservation {
  const PracticeHospitalReservation({
    required this.id,
    required this.dateLabel,
    required this.timeLabel,
    required this.department,
    required this.room,
    required this.purpose,
    this.status = '예약됨',
    this.isPracticeData = true,
  });

  final String id;
  final String dateLabel;
  final String timeLabel;
  final String department;
  final String room;
  final String purpose;
  final String status;
  final bool isPracticeData;

  String get targetSummary => '$dateLabel $timeLabel · $department · $room';
}

const hospitalPracticeReservations = <PracticeHospitalReservation>[
  PracticeHospitalReservation(
    id: 'reservation-today-internal',
    dateLabel: '오늘',
    timeLabel: '오전 10:30',
    department: '내과',
    room: '2진료실',
    purpose: '정기 진료',
  ),
  PracticeHospitalReservation(
    id: 'reservation-tomorrow-orthopedics',
    dateLabel: '내일',
    timeLabel: '오후 2:00',
    department: '정형외과',
    room: '1진료실',
    purpose: '무릎 진료',
  ),
  PracticeHospitalReservation(
    id: 'reservation-next-tuesday-ent',
    dateLabel: '다음 주 화요일',
    timeLabel: '오전 11:00',
    department: '이비인후과',
    room: '3진료실',
    purpose: '귀·코·목 진료',
  ),
];

class HospitalReservationProvider extends ChangeNotifier {
  HospitalReservationStep step = HospitalReservationStep.service;
  bool isSolo = false;
  int scenarioIndex = 0;
  String patientNumber = '';
  PracticeHospitalReservation? selectedReservation;
  String? notice;
  bool showHint = false;

  int get stepNumber => step.index + 1;
  int get totalSteps => HospitalReservationStep.values.length;
  bool get patientNumberComplete => patientNumber == '19580412';
  PracticeHospitalReservation get targetReservation =>
      hospitalPracticeReservations[isSolo ? scenarioIndex : 0];

  void begin({required bool solo, int completedCount = 0}) {
    isSolo = solo;
    scenarioIndex = solo
        ? completedCount % hospitalPracticeReservations.length
        : 0;
    step = HospitalReservationStep.service;
    patientNumber = '';
    selectedReservation = null;
    notice = null;
    showHint = false;
    notifyListeners();
  }

  void enterPatientCheck() {
    patientNumber = '';
    step = HospitalReservationStep.patient;
    notice = null;
    showHint = false;
    notifyListeners();
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
      notice = '괜찮아요. 연습용 생년월일 1958년 4월 12일을 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    patientNumber = '';
    step = HospitalReservationStep.selection;
    notice = null;
    notifyListeners();
    return true;
  }

  bool selectReservation(PracticeHospitalReservation reservation) {
    if (reservation.id != targetReservation.id) {
      notice = '괜찮아요. 날짜와 진료과를 다시 확인해 볼까요?';
      notifyListeners();
      return false;
    }
    selectedReservation = reservation;
    step = HospitalReservationStep.detail;
    notice = null;
    showHint = false;
    notifyListeners();
    return true;
  }

  void chooseAnotherReservation() {
    selectedReservation = null;
    step = HospitalReservationStep.selection;
    notice = null;
    showHint = false;
    notifyListeners();
  }

  void complete() {
    if (selectedReservation == null) return;
    patientNumber = '';
    step = HospitalReservationStep.complete;
    notice = null;
    notifyListeners();
  }

  void toggleHint() {
    showHint = !showHint;
    notifyListeners();
  }

  void requestHelp() {
    notice = '연습 화면입니다. 실제 병원에서는 주변 직원이나 안내 데스크에 도움을 요청하세요.';
    notifyListeners();
  }

  void previous() {
    switch (step) {
      case HospitalReservationStep.service:
        break;
      case HospitalReservationStep.patient:
        patientNumber = '';
        step = HospitalReservationStep.service;
      case HospitalReservationStep.selection:
        patientNumber = '';
        step = HospitalReservationStep.patient;
      case HospitalReservationStep.detail:
        chooseAnotherReservation();
        return;
      case HospitalReservationStep.complete:
        break;
    }
    notice = null;
    showHint = false;
    notifyListeners();
  }

  void reset() {
    step = HospitalReservationStep.service;
    patientNumber = '';
    selectedReservation = null;
    notice = null;
    showHint = false;
    notifyListeners();
  }
}
