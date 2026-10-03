import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../learning/learning_progress_provider.dart';
import 'train_booking_models.dart';

typedef TrainClock = DateTime Function();

class TrainBookingProvider extends ChangeNotifier {
  TrainBookingProvider({TrainClock? clock}) : _clock = clock ?? DateTime.now;
  final TrainClock _clock;

  TrainLearningMode mode = TrainLearningMode.guided;
  bool isFreePractice = false;
  TrainBookingStep step = TrainBookingStep.tripType;
  TrainBookingScenario scenario = guidedTrainScenario;
  TrainTripType? tripType;
  TrainStation? departure;
  TrainStation? arrival;
  DateTime? departureDate;
  DateTime? returnDate;
  TrainTimeBand? timeBand;
  TrainTimeBand? returnTimeBand;
  int adults = 1;
  int children = 0;
  int seniors = 0;
  List<TrainSchedule> schedules = const [];
  TrainSchedule? outbound;
  TrainSchedule? inbound;
  bool selectingReturnSchedule = false;
  TrainCarType? carType;
  int carNumber = 1;
  final List<TrainSeat> outboundSeats = [];
  final List<TrainSeat> inboundSeats = [];
  TrainPaymentMethod? payment;
  bool cardRetrieved = false;
  String? notice;
  bool showHint = false;

  bool get isSolo => mode == TrainLearningMode.solo;
  int get passengerCount => adults + children + seniors;
  DateTime get today {
    final now = _clock().toUtc().add(const Duration(hours: 9));
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get lastSelectableDate => today.add(const Duration(days: 30));
  int get stepNumber => step.index + 1;
  int get totalSteps => TrainBookingStep.ticket.index;
  bool get isRoundTrip => tripType == TrainTripType.roundTrip;
  List<TrainStation> searchStations(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return trainStations;
    return trainStations
        .where(
          (station) =>
              station.name.toLowerCase().contains(normalized) ||
              station.keywords.any(
                (item) => item.toLowerCase().contains(normalized),
              ),
        )
        .toList();
  }

  void begin(TrainLearningMode value, {int completedCount = 0}) {
    mode = value;
    isFreePractice = false;
    scenario = value == TrainLearningMode.guided
        ? guidedTrainScenario
        : soloTrainScenarios[completedCount % soloTrainScenarios.length];
    reset();
  }

  void beginFreePractice() {
    mode = TrainLearningMode.guided;
    isFreePractice = true;
    scenario = guidedTrainScenario;
    reset();
  }

  void reset() {
    step = TrainBookingStep.tripType;
    tripType = null;
    departure = null;
    arrival = null;
    departureDate = null;
    returnDate = null;
    timeBand = null;
    returnTimeBand = null;
    adults = 1;
    children = 0;
    seniors = 0;
    schedules = const [];
    outbound = null;
    inbound = null;
    selectingReturnSchedule = false;
    carType = null;
    carNumber = 1;
    outboundSeats.clear();
    inboundSeats.clear();
    payment = null;
    cardRetrieved = false;
    notice = null;
    showHint = false;
    notifyListeners();
  }

  bool chooseTripType(TrainTripType value) =>
      _accept(value == scenario.tripType, () {
        if (value == TrainTripType.oneWay) {
          returnDate = null;
          inbound = null;
          inboundSeats.clear();
        }
        tripType = value;
        step = TrainBookingStep.stations;
      });

  bool chooseStation(TrainStation value, {required bool forDeparture}) {
    if ((forDeparture && value == arrival) ||
        (!forDeparture && value == departure)) {
      notice = '출발역과 도착역은 서로 다른 역으로 골라주세요.';
      notifyListeners();
      return false;
    }
    final expected = forDeparture ? scenario.departureId : scenario.arrivalId;
    return _accept(value.id == expected, () {
      if (forDeparture) {
        departure = value;
      } else {
        arrival = value;
      }
      _clearAfterStations();
    });
  }

  void swapStations() {
    final old = departure;
    departure = arrival;
    arrival = old;
    _clearAfterStations();
    notifyListeners();
  }

  bool continueStations() {
    if (departure == null || arrival == null) {
      notice = '출발역과 도착역을 모두 골라주세요.';
      notifyListeners();
      return false;
    }
    step = TrainBookingStep.date;
    notice = null;
    notifyListeners();
    return true;
  }

  bool isDateAllowed(DateTime value) {
    final date = DateTime(value.year, value.month, value.day);
    return !date.isBefore(today) && !date.isAfter(lastSelectableDate);
  }

  bool chooseDepartureDate(DateTime value) {
    if (!isDateAllowed(value)) {
      notice = '오늘부터 30일 안의 날짜를 골라주세요.';
      notifyListeners();
      return false;
    }
    if (!_accept(
      _sameDate(value, today.add(Duration(days: scenario.departureDayOffset))),
      () {
        departureDate = DateTime(value.year, value.month, value.day);
        if (returnDate?.isBefore(departureDate!) ?? false) returnDate = null;
        _clearAfterDate();
      },
    )) {
      return false;
    }
    return true;
  }

  bool chooseReturnDate(DateTime value) {
    if (!isDateAllowed(value) ||
        departureDate == null ||
        value.isBefore(departureDate!)) {
      notice = '돌아오는 날짜는 가는 날짜와 같거나 더 늦어야 해요.';
      notifyListeners();
      return false;
    }
    final offset = scenario.returnDayOffset;
    return _accept(
      offset == null || _sameDate(value, today.add(Duration(days: offset))),
      () {
        returnDate = DateTime(value.year, value.month, value.day);
        inbound = null;
        inboundSeats.clear();
        payment = null;
      },
    );
  }

  bool continueDates() {
    if (departureDate == null || (isRoundTrip && returnDate == null)) {
      notice = '예매할 날짜를 모두 골라주세요.';
      notifyListeners();
      return false;
    }
    step = TrainBookingStep.timeBand;
    notice = null;
    notifyListeners();
    return true;
  }

  bool chooseTimeBand(TrainTimeBand value, {bool returning = false}) {
    final expected = returning ? scenario.returnTimeBand : scenario.timeBand;
    return _accept(expected == null || value == expected, () {
      if (returning) {
        returnTimeBand = value;
      } else {
        timeBand = value;
      }
      _clearAfterTime();
    });
  }

  bool continueTimeBand() {
    if (timeBand == null || (isRoundTrip && returnTimeBand == null)) {
      notice = '시간대를 모두 골라주세요.';
      notifyListeners();
      return false;
    }
    step = TrainBookingStep.passengers;
    notice = null;
    notifyListeners();
    return true;
  }

  void changePassengers(String kind, int delta) {
    final current = switch (kind) {
      '성인' => adults,
      '어린이' => children,
      _ => seniors,
    };
    final total = passengerCount + delta;
    if (current + delta < 0 || total < 1 || total > 4) {
      notice = total > 4 ? '승객은 모두 합해 4명까지 선택할 수 있어요.' : '승객은 최소 1명이 필요해요.';
      notifyListeners();
      return;
    }
    if (kind == '성인') {
      adults += delta;
    } else if (kind == '어린이') {
      children += delta;
    } else {
      seniors += delta;
    }
    while (outboundSeats.length > passengerCount) {
      outboundSeats.removeLast();
    }
    while (inboundSeats.length > passengerCount) {
      inboundSeats.removeLast();
    }
    _clearAfterPassengers();
    notice = null;
    notifyListeners();
  }

  bool continuePassengers() {
    if (isSolo &&
        (adults != scenario.adults ||
            children != scenario.children ||
            seniors != scenario.seniors)) {
      return _wrong();
    }
    step = TrainBookingStep.searchReview;
    notice = null;
    notifyListeners();
    return true;
  }

  bool search() {
    if (tripType == null ||
        departure == null ||
        arrival == null ||
        departureDate == null ||
        timeBand == null ||
        passengerCount < 1) {
      notice = '편도·왕복, 역, 날짜, 시간대와 승객 수를 확인해주세요.';
      notifyListeners();
      return false;
    }
    schedules = _makeSchedules(departure!, arrival!, timeBand!);
    selectingReturnSchedule = false;
    step = TrainBookingStep.schedules;
    notice = null;
    notifyListeners();
    return true;
  }

  List<TrainSchedule> _makeSchedules(
    TrainStation from,
    TrainStation to,
    TrainTimeBand band,
  ) {
    final start = band.startHour * 60;
    return List.generate(
      4,
      (index) => TrainSchedule(
        id: '${from.id}-${to.id}-${band.name}-$index',
        type: index == 2 ? '한걸음 일반' : '한걸음 고속',
        number: index == 0
            ? 'H101'
            : index == 1
            ? 'H205'
            : index == 2
            ? 'G307'
            : 'H409',
        departure: from,
        arrival: to,
        departureMinutes: start + 20 + index * 55,
        durationMinutes: 125 + index * 18,
        standardSeats: index == 3 ? 0 : 12 - index * 2,
        premiumSeats: index == 3 ? 0 : 6 - index,
        standardFare: 42000 + index * 2500,
        premiumFare: 59000 + index * 3000,
        soldOut: index == 3,
      ),
    )..sort((a, b) => a.departureMinutes.compareTo(b.departureMinutes));
  }

  bool chooseSchedule(TrainSchedule value, {bool returning = false}) {
    if (value.soldOut) {
      notice = '매진된 열차는 선택할 수 없어요.';
      notifyListeners();
      return false;
    }
    if (!isFreePractice &&
        mode == TrainLearningMode.guided &&
        value.number != 'H101') {
      return _wrong();
    }
    if (returning) {
      inbound = value;
    } else {
      outbound = value;
    }
    selectingReturnSchedule = returning;
    carType = null;
    if (returning) {
      inboundSeats.clear();
    } else {
      outboundSeats.clear();
      inboundSeats.clear();
    }
    payment = null;
    step = TrainBookingStep.carType;
    notice = null;
    notifyListeners();
    return true;
  }

  bool chooseCarType(TrainCarType value) {
    final schedule = inbound ?? outbound;
    if (schedule == null || schedule.seatsFor(value) < passengerCount) {
      notice = '선택한 객실의 남은 좌석이 부족해요.';
      notifyListeners();
      return false;
    }
    return _accept(value == scenario.carType, () {
      carType = value;
      if (selectingReturnSchedule) {
        inboundSeats.clear();
      } else {
        outboundSeats.clear();
        inboundSeats.clear();
      }
      payment = null;
      step = TrainBookingStep.seats;
    });
  }

  void chooseCarNumber(int value, {bool returning = false}) {
    if (value < 1 || value > 4 || value == carNumber) return;
    carNumber = value;
    if (returning) {
      inboundSeats.clear();
    } else {
      outboundSeats.clear();
    }
    notice = null;
    notifyListeners();
  }

  List<TrainSeat> get seatMap => [
    for (var row = 1; row <= 5; row++)
      for (final letter in ['A', 'B', 'C', 'D'])
        TrainSeat(
          '$row$letter',
          reserved: (row == 2 && letter == 'B') || (row == 4 && letter == 'C'),
        ),
  ];
  bool toggleSeat(TrainSeat seat, {bool returning = false}) {
    if (seat.reserved) {
      notice = '이미 예약된 좌석이에요. 다른 좌석을 골라주세요.';
      notifyListeners();
      return false;
    }
    final selected = returning ? inboundSeats : outboundSeats;
    final existing = selected.indexWhere((item) => item.number == seat.number);
    if (existing >= 0) {
      selected.removeAt(existing);
    } else if (selected.length >= passengerCount) {
      notice = '승객 수만큼 좌석을 모두 골랐어요.';
      notifyListeners();
      return false;
    } else {
      selected.add(seat);
    }
    payment = null;
    notice = null;
    notifyListeners();
    return true;
  }

  bool continueSeats({bool returning = false}) {
    final selected = returning ? inboundSeats : outboundSeats;
    if (selected.length != passengerCount) {
      notice = '$passengerCount명과 같은 수의 좌석을 골라주세요.';
      notifyListeners();
      return false;
    }
    if (!isFreePractice &&
        mode == TrainLearningMode.guided &&
        !selected.any((seat) => seat.number == '1A')) {
      return _wrong();
    }
    if (isRoundTrip && !returning) {
      schedules = _makeSchedules(arrival!, departure!, returnTimeBand!);
      selectingReturnSchedule = true;
      step = TrainBookingStep.schedules;
      notice = '이제 돌아오는 열차를 골라주세요.';
      notifyListeners();
      return true;
    }
    step = TrainBookingStep.bookingReview;
    notice = null;
    notifyListeners();
    return true;
  }

  int fareFor(TrainSchedule? schedule) {
    if (schedule == null || carType == null) return 0;
    final base = schedule.fareFor(carType!);
    return adults * base +
        children * (base ~/ 2) +
        seniors * ((base * 7) ~/ 10);
  }

  int get totalFare => fareFor(outbound) + fareFor(inbound);
  bool continueToPayment() {
    step = TrainBookingStep.payment;
    notice = null;
    notifyListeners();
    return true;
  }

  bool choosePayment(TrainPaymentMethod value) {
    if (!_accept(value == scenario.payment, () {
      payment = value;
      cardRetrieved = value == TrainPaymentMethod.easyPay;
    })) {
      return false;
    }
    return true;
  }

  bool retrieveCard() {
    if (payment != TrainPaymentMethod.card) return false;
    cardRetrieved = true;
    notice = null;
    notifyListeners();
    return true;
  }

  bool finishPayment() {
    if (payment == null ||
        (payment == TrainPaymentMethod.card && !cardRetrieved)) {
      notice = payment == null ? '결제 방법을 골라주세요.' : '연습용 카드를 챙긴 뒤 완료할 수 있어요.';
      notifyListeners();
      return false;
    }
    step = TrainBookingStep.ticket;
    notice = null;
    notifyListeners();
    return true;
  }

  void revealHint() {
    showHint = true;
    notice = null;
    notifyListeners();
  }

  void previous() {
    if (step.index > 0) step = TrainBookingStep.values[step.index - 1];
    notice = null;
    showHint = false;
    notifyListeners();
  }

  String get summary => [
    if (tripType != null) isRoundTrip ? '왕복' : '편도',
    if (departure != null && arrival != null)
      '${departure!.name} → ${arrival!.name}',
    if (departureDate != null) '${departureDate!.month}/${departureDate!.day}',
    if (timeBand != null) timeBand!.label,
  ].join(' · ');
  String get passengerSummary => '성인 $adults명 · 어린이 $children명 · 경로 $seniors명';
  String get hint => switch (step) {
    TrainBookingStep.tripType =>
      scenario.tripType == TrainTripType.oneWay ? '편도를 골라보세요.' : '왕복을 골라보세요.',
    TrainBookingStep.stations =>
      '${_station(scenario.departureId).name}에서 ${_station(scenario.arrivalId).name}으로 가요.',
    TrainBookingStep.date =>
      '오늘부터 ${scenario.departureDayOffset}일 뒤 날짜를 골라보세요.',
    TrainBookingStep.timeBand => '${scenario.timeBand.label} 시간대를 골라보세요.',
    TrainBookingStep.passengers =>
      '성인 ${scenario.adults}명 · 어린이 ${scenario.children}명 · 경로 ${scenario.seniors}명이에요.',
    TrainBookingStep.schedules => '한걸음 고속 H101을 찾아보세요.',
    TrainBookingStep.carType =>
      scenario.carType == TrainCarType.standard ? '일반실을 골라보세요.' : '우등실을 골라보세요.',
    TrainBookingStep.seats =>
      scenario.windowSeat ? '창가 좌석을 골라보세요.' : '승객 수만큼 좌석을 골라보세요.',
    TrainBookingStep.payment =>
      scenario.payment == TrainPaymentMethod.card
          ? '카드 결제를 골라보세요.'
          : '간편결제를 골라보세요.',
    _ => '화면의 예매 정보를 천천히 확인해보세요.',
  };
  TrainStation _station(String id) =>
      trainStations.firstWhere((item) => item.id == id);
  bool _accept(bool correct, VoidCallback apply) {
    if (!isFreePractice && !correct) return _wrong();
    apply();
    notice = null;
    showHint = false;
    notifyListeners();
    return true;
  }

  bool _wrong() {
    notice = isSolo ? '괜찮아요. 예매 목표를 다시 살펴볼까요?' : '괜찮아요. 안내된 항목을 다시 확인해 볼까요?';
    notifyListeners();
    return false;
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  void _clearAfterStations() {
    schedules = const [];
    outbound = null;
    inbound = null;
    selectingReturnSchedule = false;
    carType = null;
    carNumber = 1;
    outboundSeats.clear();
    inboundSeats.clear();
    payment = null;
  }

  void _clearAfterDate() {
    _clearAfterStations();
  }

  void _clearAfterTime() {
    _clearAfterStations();
  }

  void _clearAfterPassengers() {
    schedules = const [];
    outbound = null;
    inbound = null;
    selectingReturnSchedule = false;
    carType = null;
    payment = null;
  }
}
