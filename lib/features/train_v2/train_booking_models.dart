import 'package:flutter/foundation.dart';

enum TrainBookingStep {
  tripType,
  stations,
  date,
  timeBand,
  passengers,
  searchReview,
  schedules,
  carType,
  seats,
  bookingReview,
  payment,
  ticket,
}

enum TrainTripType { oneWay, roundTrip }

enum TrainCarType { standard, premium }

enum TrainPaymentMethod { card, easyPay }

enum TrainTimeBand { earlyMorning, morning, daytime, evening, late }

extension TrainTimeBandLabel on TrainTimeBand {
  String get label => switch (this) {
    TrainTimeBand.earlyMorning => '이른 아침',
    TrainTimeBand.morning => '오전',
    TrainTimeBand.daytime => '낮',
    TrainTimeBand.evening => '저녁',
    TrainTimeBand.late => '늦은 시간',
  };
  String get range => switch (this) {
    TrainTimeBand.earlyMorning => '05:00~08:59',
    TrainTimeBand.morning => '09:00~11:59',
    TrainTimeBand.daytime => '12:00~16:59',
    TrainTimeBand.evening => '17:00~20:59',
    TrainTimeBand.late => '21:00 이후',
  };
  int get startHour => switch (this) {
    TrainTimeBand.earlyMorning => 5,
    TrainTimeBand.morning => 9,
    TrainTimeBand.daytime => 12,
    TrainTimeBand.evening => 17,
    TrainTimeBand.late => 21,
  };
  int get endHour => switch (this) {
    TrainTimeBand.earlyMorning => 8,
    TrainTimeBand.morning => 11,
    TrainTimeBand.daytime => 16,
    TrainTimeBand.evening => 20,
    TrainTimeBand.late => 23,
  };
}

@immutable
class TrainStation {
  const TrainStation(
    this.id,
    this.name,
    this.region,
    this.major,
    this.keywords,
  );
  final String id;
  final String name;
  final String region;
  final bool major;
  final List<String> keywords;
}

const trainStations = <TrainStation>[
  TrainStation('seoul', '서울', '수도권', true, ['서울', 'ㅅㅇ']),
  TrainStation('yongsan', '용산', '수도권', true, ['용산', 'ㅇㅅ']),
  TrainStation('gwangmyeong', '광명', '수도권', true, ['광명', 'ㄱㅁ']),
  TrainStation('suwon', '수원', '수도권', false, ['수원', 'ㅅㅇ']),
  TrainStation('cheonan', '천안아산', '충청권', true, ['천안', '아산', 'ㅊㅇㅇㅅ']),
  TrainStation('daejeon', '대전', '충청권', true, ['대전', 'ㄷㅈ']),
  TrainStation('dongdaegu', '동대구', '영남권', true, ['동대구', '대구', 'ㄷㄷㄱ']),
  TrainStation('busan', '부산', '영남권', true, ['부산', 'ㅂㅅ']),
  TrainStation('gwangju', '광주송정', '호남권', true, ['광주', '송정', 'ㄱㅈㅅㅈ']),
  TrainStation('mokpo', '목포', '호남권', false, ['목포', 'ㅁㅍ']),
  TrainStation('jeonju', '전주', '호남권', true, ['전주', 'ㅈㅈ']),
  TrainStation('yeosu', '여수엑스포', '호남권', false, ['여수', '엑스포', 'ㅇㅅ']),
  TrainStation('gangneung', '강릉', '강원권', true, ['강릉', 'ㄱㄹ']),
  TrainStation('cheongnyangni', '청량리', '수도권', true, ['청량리', 'ㅊㄹㄹ']),
];

@immutable
class TrainSchedule {
  const TrainSchedule({
    required this.id,
    required this.type,
    required this.number,
    required this.departure,
    required this.arrival,
    required this.departureMinutes,
    required this.durationMinutes,
    required this.standardSeats,
    required this.premiumSeats,
    required this.standardFare,
    required this.premiumFare,
    this.soldOut = false,
  });
  final String id;
  final String type;
  final String number;
  final TrainStation departure;
  final TrainStation arrival;
  final int departureMinutes;
  final int durationMinutes;
  final int standardSeats;
  final int premiumSeats;
  final int standardFare;
  final int premiumFare;
  final bool soldOut;
  int get arrivalMinutes => departureMinutes + durationMinutes;
  String get departureTime => _time(departureMinutes);
  String get arrivalTime => _time(arrivalMinutes);
  String get durationLabel =>
      '${durationMinutes ~/ 60}시간 ${durationMinutes % 60}분';
  int seatsFor(TrainCarType type) =>
      type == TrainCarType.standard ? standardSeats : premiumSeats;
  int fareFor(TrainCarType type) =>
      type == TrainCarType.standard ? standardFare : premiumFare;
  static String _time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
}

@immutable
class TrainSeat {
  const TrainSeat(this.number, {this.reserved = false});
  final String number;
  final bool reserved;
  bool get window => number.endsWith('A') || number.endsWith('D');
}

@immutable
class TrainBookingScenario {
  const TrainBookingScenario({
    required this.title,
    required this.tripType,
    required this.departureId,
    required this.arrivalId,
    required this.departureDayOffset,
    required this.timeBand,
    required this.adults,
    required this.children,
    required this.seniors,
    required this.carType,
    required this.payment,
    this.returnDayOffset,
    this.returnTimeBand,
    this.windowSeat = false,
  });
  final String title;
  final TrainTripType tripType;
  final String departureId;
  final String arrivalId;
  final int departureDayOffset;
  final int? returnDayOffset;
  final TrainTimeBand timeBand;
  final TrainTimeBand? returnTimeBand;
  final int adults;
  final int children;
  final int seniors;
  final TrainCarType carType;
  final TrainPaymentMethod payment;
  final bool windowSeat;
  String get summary =>
      '$title · ${tripType == TrainTripType.oneWay ? '편도' : '왕복'}';
}

const guidedTrainScenario = TrainBookingScenario(
  title: '서울에서 부산까지 내일 오전',
  tripType: TrainTripType.oneWay,
  departureId: 'seoul',
  arrivalId: 'busan',
  departureDayOffset: 1,
  timeBand: TrainTimeBand.morning,
  adults: 1,
  children: 0,
  seniors: 0,
  carType: TrainCarType.standard,
  payment: TrainPaymentMethod.card,
  windowSeat: true,
);

const soloTrainScenarios = <TrainBookingScenario>[
  guidedTrainScenario,
  TrainBookingScenario(
    title: '용산에서 광주송정까지 이틀 뒤 낮',
    tripType: TrainTripType.oneWay,
    departureId: 'yongsan',
    arrivalId: 'gwangju',
    departureDayOffset: 2,
    timeBand: TrainTimeBand.daytime,
    adults: 1,
    children: 0,
    seniors: 1,
    carType: TrainCarType.premium,
    payment: TrainPaymentMethod.easyPay,
  ),
  TrainBookingScenario(
    title: '서울과 강릉 왕복 예매',
    tripType: TrainTripType.roundTrip,
    departureId: 'seoul',
    arrivalId: 'gangneung',
    departureDayOffset: 3,
    returnDayOffset: 4,
    timeBand: TrainTimeBand.morning,
    returnTimeBand: TrainTimeBand.evening,
    adults: 1,
    children: 0,
    seniors: 0,
    carType: TrainCarType.standard,
    payment: TrainPaymentMethod.card,
  ),
];

@immutable
class VirtualTrainTicket {
  const VirtualTrainTicket({required this.outbound, this.inbound});
  final TrainSchedule outbound;
  final TrainSchedule? inbound;
}
