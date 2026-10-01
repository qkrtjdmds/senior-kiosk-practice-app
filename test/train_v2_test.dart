import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/train_v2/train_booking_models.dart';
import 'package:han_geoleum_digital/features/train_v2/train_booking_provider.dart';

void main() {
  late TrainBookingProvider booking;
  final base = DateTime.utc(2026, 9, 30, 3);

  setUp(() {
    booking = TrainBookingProvider(clock: () => base);
    booking.begin(TrainLearningMode.guided);
  });

  test('한국 날짜 기준 오늘부터 30일만 선택한다', () {
    expect(booking.today, DateTime(2026, 9, 30));
    expect(booking.isDateAllowed(DateTime(2026, 9, 29)), isFalse);
    expect(booking.isDateAllowed(DateTime(2026, 10, 30)), isTrue);
    expect(booking.isDateAllowed(DateTime(2026, 10, 31)), isFalse);
  });

  test('편도와 왕복 변경 시 오는 여정 상태를 정리한다', () {
    booking.begin(TrainLearningMode.solo, completedCount: 2);
    expect(booking.chooseTripType(TrainTripType.roundTrip), isTrue);
    booking.returnDate = DateTime(2026, 10, 4);
    booking.inboundSeats.add(const TrainSeat('1A'));
    booking.begin(TrainLearningMode.guided);
    booking.tripType = TrainTripType.roundTrip;
    booking.returnDate = DateTime(2026, 10, 4);
    booking.inboundSeats.add(const TrainSeat('1A'));
    expect(booking.chooseTripType(TrainTripType.oneWay), isTrue);
    expect(booking.returnDate, isNull);
    expect(booking.inboundSeats, isEmpty);
  });

  test('출발역과 도착역은 같을 수 없고 검색을 지원한다', () {
    const seoul = TrainStation('seoul', '서울', '수도권', true, ['서울', 'ㅅㅇ']);
    booking.departure = seoul;
    expect(booking.chooseStation(seoul, forDeparture: false), isFalse);
    expect(booking.searchStations('광주').single.name, '광주송정');
    expect(booking.searchStations('없는역'), isEmpty);
  });

  test('가는 날짜 이후의 오는 날짜만 허용한다', () {
    booking.departureDate = DateTime(2026, 10, 3);
    expect(booking.chooseReturnDate(DateTime(2026, 10, 2)), isFalse);
    booking.begin(TrainLearningMode.solo, completedCount: 2);
    booking.departureDate = DateTime(2026, 10, 3);
    expect(booking.chooseReturnDate(DateTime(2026, 10, 4)), isTrue);
  });

  test('승객은 최소 1명, 최대 4명이다', () {
    booking.changePassengers('성인', -1);
    expect(booking.passengerCount, 1);
    booking.changePassengers('어린이', 1);
    booking.changePassengers('경로', 1);
    booking.changePassengers('성인', 1);
    expect(booking.passengerCount, 4);
    booking.changePassengers('성인', 1);
    expect(booking.passengerCount, 4);
  });

  test('가상 열차는 출발 시간순이며 매진 열차를 고를 수 없다', () {
    _prepareSearch(booking);
    expect(booking.search(), isTrue);
    expect(booking.schedules.first.number, 'H101');
    expect(booking.schedules.last.soldOut, isTrue);
    expect(booking.chooseSchedule(booking.schedules.last), isFalse);
  });

  test('성인 어린이 경로 운임을 정수 원으로 계산한다', () {
    booking.adults = 1;
    booking.children = 1;
    booking.seniors = 1;
    booking.carType = TrainCarType.standard;
    booking.outbound = _schedule(42000);
    expect(booking.totalFare, 92400);
    booking.inbound = _schedule(42000);
    expect(booking.totalFare, 184800);
  });

  test('예약 좌석과 승객 수 초과 좌석을 차단한다', () {
    booking.adults = 2;
    expect(booking.toggleSeat(const TrainSeat('2B', reserved: true)), isFalse);
    expect(booking.toggleSeat(const TrainSeat('1A')), isTrue);
    expect(booking.toggleSeat(const TrainSeat('1B')), isTrue);
    expect(booking.toggleSeat(const TrainSeat('1C')), isFalse);
    expect(booking.outboundSeats.length, 2);
  });

  test('객차를 바꾸면 선택 좌석을 정리하고 객차 번호를 유지한다', () {
    booking.outboundSeats.add(const TrainSeat('1A'));

    booking.chooseCarNumber(3);

    expect(booking.carNumber, 3);
    expect(booking.outboundSeats, isEmpty);
  });
  test('카드 결제는 카드를 챙기기 전 완료할 수 없다', () {
    booking.payment = TrainPaymentMethod.card;
    expect(booking.finishPayment(), isFalse);
    expect(booking.retrieveCard(), isTrue);
    expect(booking.finishPayment(), isTrue);
    expect(booking.step, TrainBookingStep.ticket);
  });

  test('왕복은 가는 좌석 다음에 돌아오는 열차를 다시 고른다', () {
    booking.tripType = TrainTripType.roundTrip;
    booking.departure = trainStations.firstWhere((e) => e.id == 'seoul');
    booking.arrival = trainStations.firstWhere((e) => e.id == 'gangneung');
    booking.returnTimeBand = TrainTimeBand.evening;
    booking.outboundSeats.add(const TrainSeat('1A'));

    expect(booking.continueSeats(), isTrue);
    expect(booking.step, TrainBookingStep.schedules);
    expect(booking.selectingReturnSchedule, isTrue);
    expect(booking.schedules.first.departure.name, '강릉');
    expect(booking.schedules.first.arrival.name, '서울');
  });
  test('왕복의 돌아오는 열차와 객실 선택은 가는 좌석을 보존한다', () {
    booking.tripType = TrainTripType.roundTrip;
    booking.departure = trainStations.firstWhere((e) => e.id == 'seoul');
    booking.arrival = trainStations.firstWhere((e) => e.id == 'gangneung');
    booking.returnTimeBand = TrainTimeBand.evening;
    booking.outboundSeats.add(const TrainSeat('1A'));

    expect(booking.continueSeats(), isTrue);
    final returnSchedule = booking.schedules.first;
    expect(booking.chooseSchedule(returnSchedule, returning: true), isTrue);
    expect(booking.outboundSeats.map((e) => e.number), contains('1A'));

    expect(booking.chooseCarType(booking.scenario.carType), isTrue);
    expect(booking.outboundSeats.map((e) => e.number), contains('1A'));
    expect(booking.selectingReturnSchedule, isTrue);

    booking.inboundSeats.add(const TrainSeat('1A'));
    expect(booking.continueSeats(returning: true), isTrue);
    expect(booking.step, TrainBookingStep.bookingReview);
  });
  test('세 가지 혼자 해보기 시나리오가 제공된다', () {
    expect(soloTrainScenarios, hasLength(3));
    expect(soloTrainScenarios.last.tripType, TrainTripType.roundTrip);
    expect(soloTrainScenarios[1].seniors, 1);
  });
}

void _prepareSearch(TrainBookingProvider booking) {
  booking.tripType = TrainTripType.oneWay;
  booking.departure = trainStations.firstWhere((e) => e.id == 'seoul');
  booking.arrival = trainStations.firstWhere((e) => e.id == 'busan');
  booking.departureDate = DateTime(2026, 10, 1);
  booking.timeBand = TrainTimeBand.morning;
}

TrainSchedule _schedule(int fare) => TrainSchedule(
  id: 'test',
  type: '한걸음 고속',
  number: 'H101',
  departure: trainStations.first,
  arrival: trainStations.last,
  departureMinutes: 540,
  durationMinutes: 120,
  standardSeats: 10,
  premiumSeats: 5,
  standardFare: fare,
  premiumFare: fare + 10000,
);
