import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'train_booking_models.dart';
import 'train_booking_provider.dart';
import 'train_booking_widgets.dart';

class TrainV2StartPage extends StatelessWidget {
  const TrainV2StartPage({super.key});
  @override
  Widget build(BuildContext context) => TrainBookingScaffold(
    onBack: () => context.go(AppRoutes.home),
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const TrainQuestion(
          '기차표 예매 연습',
          description: '가상 예매 화면에서 기차표를 고르는 순서를 연습해요.',
        ),
        const SizedBox(height: 18),
        const TrainInlineNotice('모든 열차·시간·좌석·운임은 연습용이며 실제 예약은 진행되지 않아요.'),
        const SizedBox(height: 24),
        TrainChoiceTile(
          label: '따라 해보기',
          subtitle: '화면의 안내를 보며 하나씩 예매해요.',
          icon: Icons.menu_book_outlined,
          onTap: () {
            context.read<LearningProgressProvider>().selectTrainMode(
              TrainLearningMode.guided,
            );
            context.read<TrainBookingProvider>().begin(
              TrainLearningMode.guided,
            );
            context.go(AppRoutes.trainV2TripType);
          },
        ),
        const SizedBox(height: 14),
        TrainChoiceTile(
          label: '혼자 해보기',
          subtitle: '예매 목표를 기억하고 직접 골라봐요.',
          icon: Icons.self_improvement_outlined,
          onTap: () {
            final progress = context.read<LearningProgressProvider>();
            progress.selectTrainMode(TrainLearningMode.solo);
            context.go(AppRoutes.trainMission);
          },
        ),
      ],
    ),
  );
}

class TrainV2MissionPage extends StatefulWidget {
  const TrainV2MissionPage({super.key});

  @override
  State<TrainV2MissionPage> createState() => _TrainV2MissionPageState();
}

class _TrainV2MissionPageState extends State<TrainV2MissionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final progress = context.read<LearningProgressProvider>();
      context.read<TrainBookingProvider>().begin(
        TrainLearningMode.solo,
        completedCount: progress.trainSoloCompletionCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TrainBookingProvider>();
    return TrainBookingScaffold(
      onBack: () {
        context.read<DailyMissionProvider>().cancelActiveMission();
        context.go(AppRoutes.trainStart);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const TrainQuestion(
            '오늘의 기차표 예매 목표',
            description: '목표를 기억하고 모든 예매 단계를 직접 완료해보세요.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: trainSage,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 54,
                  color: trainGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  p.scenario.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(p.scenario.summary, textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 24),
          trainPrimaryButton(
            context,
            '혼자 해보기',
            () => context.go(AppRoutes.trainV2TripType),
          ),
        ],
      ),
    );
  }
}

class TrainV2FlowPage extends StatelessWidget {
  const TrainV2FlowPage({super.key, required this.pageStep});
  final TrainBookingStep pageStep;
  @override
  Widget build(BuildContext context) {
    final p = context.watch<TrainBookingProvider>();
    return TrainBookingScaffold(
      step: pageStep.index + 1,
      total: p.totalSteps,
      modeLabel: practiceSessionLabel(
        isFreePractice: p.isFreePractice,
        isSolo: p.isSolo,
      ),
      summary: p.summary,
      onBack: () => _back(context, p),
      bottom: _bottom(context, p),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          if (p.isSolo)
            TextButton.icon(
              onPressed: p.revealHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('힌트 보기'),
            ),
          if (p.showHint) ...[
            TrainInlineNotice('힌트: ${p.hint}'),
            const SizedBox(height: 14),
          ],
          if (p.notice != null) ...[
            TrainInlineNotice(p.notice!, warning: true),
            const SizedBox(height: 14),
          ],
          ..._content(context, p),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, TrainBookingProvider p) =>
      switch (pageStep) {
        TrainBookingStep.tripType => [
          const TrainQuestion(
            '어떤 표를 예매할까요?',
            description: '편도는 가는 표만, 왕복은 돌아오는 표까지 함께 예매해요.',
          ),
          const SizedBox(height: 18),
          TrainSegmentControl<TrainTripType>(
            options: const [
              TrainSegmentOption(
                value: TrainTripType.oneWay,
                label: '편도',
                icon: Icons.arrow_forward,
              ),
              TrainSegmentOption(
                value: TrainTripType.roundTrip,
                label: '왕복',
                icon: Icons.swap_horiz,
              ),
            ],
            selected: p.tripType,
            onSelected: (value) {
              if (p.chooseTripType(value)) {
                context.go(AppRoutes.trainV2Stations);
              }
            },
          ),
        ],
        TrainBookingStep.stations => _stationContent(context, p),
        TrainBookingStep.date => _dateContent(context, p),
        TrainBookingStep.timeBand => _timeContent(context, p),
        TrainBookingStep.passengers => _passengerContent(context, p),
        TrainBookingStep.searchReview => _reviewContent(context, p),
        TrainBookingStep.schedules => _scheduleContent(context, p),
        TrainBookingStep.carType => _carContent(context, p),
        TrainBookingStep.seats => _seatContent(context, p),
        TrainBookingStep.bookingReview => _bookingContent(context, p),
        TrainBookingStep.payment => _paymentContent(context, p),
        TrainBookingStep.ticket => const [],
      };

  List<Widget> _stationContent(BuildContext context, TrainBookingProvider p) =>
      [
        const TrainQuestion('출발역과 도착역을 골라주세요.'),
        const SizedBox(height: 16),
        _stationBox(
          context,
          '출발역',
          p.departure,
          () => _showStations(context, p, true),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: p.departure == null && p.arrival == null
              ? null
              : p.swapStations,
          icon: const Icon(Icons.swap_vert),
          label: const Text('서로 바꾸기'),
        ),
        const SizedBox(height: 10),
        _stationBox(
          context,
          '도착역',
          p.arrival,
          () => _showStations(context, p, false),
        ),
      ];
  Widget _stationBox(
    BuildContext context,
    String label,
    TrainStation? station,
    VoidCallback tap,
  ) => TrainChoiceTile(
    label: station?.name ?? label,
    subtitle: station == null ? '역 선택하기' : label,
    icon: label == '출발역' ? Icons.trip_origin : Icons.location_on_outlined,
    onTap: tap,
    selected: station != null,
  );
  Future<void> _showStations(
    BuildContext context,
    TrainBookingProvider p,
    bool departure,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setState) {
          final results = p.searchStations(controller.text);
          return SafeArea(
            child: FractionallySizedBox(
              heightFactor: .88,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(
                          departure ? '출발역 선택' : '도착역 선택',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: '역 이름 검색',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (results.isEmpty)
                    const Expanded(
                      child: Center(child: Text('입력한 이름과 일치하는 역이 없어요.')),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final station = results[index];
                          return ListTile(
                            minTileHeight: 60,
                            title: Text(station.name),
                            subtitle: Text(station.region),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              if (p.chooseStation(
                                station,
                                forDeparture: departure,
                              )) {
                                Navigator.pop(sheet);
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _dateContent(BuildContext context, TrainBookingProvider p) => [
    const TrainQuestion(
      '예매할 날짜를 골라주세요.',
      description: '오늘부터 30일 안의 날짜만 선택할 수 있어요.',
    ),
    const SizedBox(height: 14),
    CalendarDatePicker(
      initialDate: p.departureDate ?? p.today.add(const Duration(days: 1)),
      firstDate: p.today,
      lastDate: p.lastSelectableDate,
      onDateChanged: p.chooseDepartureDate,
    ),
    if (p.isRoundTrip) ...[
      const Divider(height: 28),
      Text('돌아오는 날짜', style: Theme.of(context).textTheme.titleLarge),
      CalendarDatePicker(
        initialDate:
            p.returnDate ??
            (p.departureDate ?? p.today).add(const Duration(days: 1)),
        firstDate: p.departureDate ?? p.today,
        lastDate: p.lastSelectableDate,
        onDateChanged: p.chooseReturnDate,
      ),
    ],
  ];
  List<Widget> _timeContent(BuildContext context, TrainBookingProvider p) => [
    TrainQuestion(p.isRoundTrip ? '가는 시간대를 골라주세요.' : '출발 시간대를 골라주세요.'),
    const SizedBox(height: 14),
    for (final band in TrainTimeBand.values) ...[
      TrainChoiceTile(
        label: band.label,
        subtitle: band.range,
        icon: Icons.schedule,
        onTap: () => p.chooseTimeBand(band),
        selected: p.timeBand == band,
      ),
      const SizedBox(height: 10),
    ],
    if (p.isRoundTrip) ...[
      const Divider(height: 30),
      Text('돌아오는 시간대', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      for (final band in TrainTimeBand.values) ...[
        TrainChoiceTile(
          label: band.label,
          subtitle: band.range,
          icon: Icons.schedule,
          onTap: () => p.chooseTimeBand(band, returning: true),
          selected: p.returnTimeBand == band,
        ),
        const SizedBox(height: 10),
      ],
    ],
  ];
  List<Widget> _passengerContent(
    BuildContext context,
    TrainBookingProvider p,
  ) => [
    TrainQuestion(
      '승객 수를 골라주세요.',
      description: '현재 모두 ${p.passengerCount}명이에요. 최대 4명까지 선택할 수 있어요.',
    ),
    const SizedBox(height: 18),
    _counter(context, p, '성인', p.adults, Icons.person_outline),
    const Divider(),
    _counter(context, p, '어린이', p.children, Icons.child_care),
    const Divider(),
    _counter(context, p, '경로', p.seniors, Icons.elderly_outlined),
    const SizedBox(height: 14),
    const TrainInlineNotice('경로 구분과 할인은 연습용이며 실제 자격을 확인하지 않아요.'),
  ];
  Widget _counter(
    BuildContext context,
    TrainBookingProvider p,
    String label,
    int count,
    IconData icon,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icon, size: 30, color: trainGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          tooltip: '$label 한 명 줄이기',
          onPressed: () => p.changePassengers(label, -1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Semantics(
          label: '$label $count명',
          child: Text('$count', style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          tooltip: '$label 한 명 늘리기',
          onPressed: () => p.changePassengers(label, 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );
  List<Widget> _reviewContent(BuildContext context, TrainBookingProvider p) => [
    const TrainQuestion('조회 조건을 확인해볼까요?'),
    const SizedBox(height: 18),
    _summary(context, p),
    const SizedBox(height: 14),
    const TrainInlineNotice('실제 시간표가 아닌 연습용 가상 열차를 조회해요.'),
  ];
  Widget _summary(BuildContext context, TrainBookingProvider p) => Column(
    children: [
      _row(context, '여행', p.isRoundTrip ? '왕복' : '편도'),
      _row(context, '구간', '${p.departure?.name} → ${p.arrival?.name}'),
      _row(context, '가는 날짜', _date(p.departureDate)),
      if (p.isRoundTrip) _row(context, '오는 날짜', _date(p.returnDate)),
      _row(context, '시간대', p.timeBand?.label ?? ''),
      _row(context, '승객', p.passengerSummary),
    ],
  );
  List<Widget> _scheduleContent(BuildContext context, TrainBookingProvider p) =>
      [
        TrainQuestion(
          p.selectingReturnSchedule ? '돌아오는 열차를 골라주세요.' : '이용할 열차를 골라주세요.',
          description: '출발 시각이 빠른 순서로 보여드려요.',
        ),
        const SizedBox(height: 16),
        for (final item in p.schedules) ...[
          _scheduleTile(context, p, item),
          const SizedBox(height: 10),
        ],
      ];
  Widget _scheduleTile(
    BuildContext context,
    TrainBookingProvider p,
    TrainSchedule s,
  ) => Material(
    color: s.soldOut ? const Color(0xFFF0F0ED) : Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: s.soldOut
          ? null
          : () {
              if (p.chooseSchedule(s, returning: p.selectingReturnSchedule)) {
                context.go(AppRoutes.trainV2CarType);
              }
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: trainLine),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${s.departureTime}  →  ${s.arrivalTime}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: trainGreen,
                    ),
                  ),
                ),
                if (s.soldOut)
                  const Text(
                    '매진',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  )
                else
                  const Icon(Icons.chevron_right, color: trainGreen),
              ],
            ),
            const SizedBox(height: 4),
            Text('${s.type} ${s.number} · ${s.durationLabel}'),
            const Divider(height: 20),
            Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                Text('일반실 ${trainMoney(s.standardFare)}'),
                Text('우등실 ${trainMoney(s.premiumFare)}'),
                Text(
                  s.soldOut
                      ? '예매할 수 없어요'
                      : '일반 ${s.standardSeats}석 · 우등 ${s.premiumSeats}석',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  List<Widget> _carContent(BuildContext context, TrainBookingProvider p) {
    final s = p.inbound ?? p.outbound;
    return [
      const TrainQuestion('객실을 골라주세요.', description: '운임과 남은 좌석을 확인해보세요.'),
      const SizedBox(height: 16),
      for (final type in TrainCarType.values) ...[
        TrainChoiceTile(
          label: type == TrainCarType.standard ? '일반실' : '우등실',
          subtitle:
              '1인 기준 ${trainMoney(s?.fareFor(type) ?? 0)} · 예상 ${trainMoney(_expected(p, s, type))}\n남은 좌석 ${s?.seatsFor(type) ?? 0}석',
          icon: type == TrainCarType.standard
              ? Icons.event_seat_outlined
              : Icons.airline_seat_recline_extra,
          onTap: () {
            if (p.chooseCarType(type)) context.go(AppRoutes.trainV2Seats);
          },
          selected: p.carType == type,
          enabled: (s?.seatsFor(type) ?? 0) >= p.passengerCount,
        ),
        const SizedBox(height: 12),
      ],
      const TrainInlineNotice('어린이 50%, 경로 70%는 연습용 할인율이에요.'),
    ];
  }

  int _expected(TrainBookingProvider p, TrainSchedule? s, TrainCarType type) {
    if (s == null) return 0;
    final base = s.fareFor(type);
    return p.adults * base +
        p.children * (base ~/ 2) +
        p.seniors * ((base * 7) ~/ 10);
  }

  List<Widget> _seatContent(BuildContext context, TrainBookingProvider p) {
    final returning = p.isRoundTrip && p.selectingReturnSchedule;
    final selected = returning ? p.inboundSeats : p.outboundSeats;
    return [
      TrainQuestion(
        returning ? '돌아오는 열차 좌석을 골라주세요.' : '좌석을 골라주세요.',
        description:
            '${p.passengerCount}명 중 ${selected.length}석 선택 · A/D 창가 · B/C 통로',
      ),
      const SizedBox(height: 16),
      Text('객차 선택', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      TrainSegmentControl<int>(
        options: const [
          TrainSegmentOption(value: 1, label: '1호차'),
          TrainSegmentOption(value: 2, label: '2호차'),
          TrainSegmentOption(value: 3, label: '3호차'),
          TrainSegmentOption(value: 4, label: '4호차'),
        ],
        selected: p.carNumber,
        onSelected: (value) => p.chooseCarNumber(value, returning: returning),
      ),
      const SizedBox(height: 16),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.window),
          Text(' 창가   '),
          Icon(Icons.directions_walk),
          Text(' 통로'),
        ],
      ),
      const SizedBox(height: 12),
      Semantics(
        label: '${p.passengerCount}명 중 ${selected.length}석 선택',
        child: LayoutBuilder(
          builder: (context, c) {
            final width = (c.maxWidth - 42) / 4;
            return Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                for (final seat in p.seatMap)
                  SizedBox(
                    width: width.clamp(54, 90),
                    height: 62,
                    child: Semantics(
                      button: true,
                      label:
                          '${seat.number} ${seat.window ? '창가' : '통로'} ${seat.reserved
                              ? '이미 예약됨'
                              : selected.any((x) => x.number == seat.number)
                              ? '선택됨'
                              : '선택 가능'}',
                      child: OutlinedButton(
                        onPressed: seat.reserved
                            ? null
                            : () => p.toggleSeat(seat, returning: returning),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              selected.any((x) => x.number == seat.number)
                              ? trainSage
                              : Colors.white,
                          side: BorderSide(
                            color: selected.any((x) => x.number == seat.number)
                                ? trainGreen
                                : trainLine,
                          ),
                        ),
                        child: Text(seat.number),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _bookingContent(
    BuildContext context,
    TrainBookingProvider p,
  ) => [
    const TrainQuestion('예매 내용을 확인해볼까요?'),
    const SizedBox(height: 16),
    _summary(context, p),
    _row(
      context,
      '가는 열차',
      '${p.outbound?.type} ${p.outbound?.number} · ${p.outbound?.departureTime}',
    ),
    _row(
      context,
      '객실·객차',
      '${p.carType == TrainCarType.standard ? '일반실' : '우등실'} · ${p.carNumber}호차',
    ),
    _row(context, '가는 좌석', p.outboundSeats.map((e) => e.number).join(', ')),
    if (p.isRoundTrip) ...[
      _row(context, '오는 열차', '${p.inbound?.type} ${p.inbound?.number}'),
      _row(context, '오는 좌석', p.inboundSeats.map((e) => e.number).join(', ')),
    ],
    _row(context, '가상 총 운임', trainMoney(p.totalFare)),
    const SizedBox(height: 14),
    const TrainInlineNotice('연습용 예매이며 실제 기차표가 예약되지 않습니다.'),
  ];
  List<Widget> _paymentContent(BuildContext context, TrainBookingProvider p) =>
      [
        const TrainQuestion(
          '어떤 방법으로 결제하시겠어요?',
          description: '연습 화면이며 실제 결제는 진행되지 않습니다.',
        ),
        const SizedBox(height: 12),
        TrainInlineNotice('결제 연습 금액: ${trainMoney(p.totalFare)}'),
        const SizedBox(height: 16),
        TrainChoiceTile(
          label: '카드',
          subtitle: '카드 준비 → 금액 확인 → 카드 챙기기',
          icon: Icons.credit_card,
          onTap: () => p.choosePayment(TrainPaymentMethod.card),
          selected: p.payment == TrainPaymentMethod.card,
        ),
        const SizedBox(height: 12),
        TrainChoiceTile(
          label: '간편결제',
          subtitle: '휴대전화 준비 → 금액 확인 → 가상 결제',
          icon: Icons.phone_android,
          onTap: () => p.choosePayment(TrainPaymentMethod.easyPay),
          selected: p.payment == TrainPaymentMethod.easyPay,
        ),
        if (p.payment == TrainPaymentMethod.card && !p.cardRetrieved) ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: p.retrieveCard,
            icon: const Icon(Icons.credit_card_off_outlined),
            label: const Text('연습용 카드 챙기기'),
          ),
        ],
      ];
  Widget _row(BuildContext context, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: trainLine)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  String _date(DateTime? d) => d == null ? '선택 안 함' : '${d.month}월 ${d.day}일';

  Widget? _bottom(BuildContext context, TrainBookingProvider p) {
    final (label, action) = switch (pageStep) {
      TrainBookingStep.tripType => ('여행 종류를 선택해주세요', null),
      TrainBookingStep.stations => (
        '날짜 고르기',
        () {
          if (p.continueStations()) context.go(AppRoutes.trainV2Date);
        },
      ),
      TrainBookingStep.date => (
        '시간대 고르기',
        () {
          if (p.continueDates()) context.go(AppRoutes.trainV2Time);
        },
      ),
      TrainBookingStep.timeBand => (
        '승객 수 고르기',
        () {
          if (p.continueTimeBand()) context.go(AppRoutes.trainV2Passengers);
        },
      ),
      TrainBookingStep.passengers => (
        '조회 조건 확인하기',
        () {
          if (p.continuePassengers()) context.go(AppRoutes.trainV2SearchReview);
        },
      ),
      TrainBookingStep.searchReview => (
        '열차 조회하기',
        () {
          if (p.search()) context.go(AppRoutes.trainV2Schedules);
        },
      ),
      TrainBookingStep.schedules => ('열차를 선택해주세요', null),
      TrainBookingStep.carType => ('객실을 선택해주세요', null),
      TrainBookingStep.seats => (
        '선택한 좌석 확인하기',
        () {
          final returning = p.isRoundTrip && p.selectingReturnSchedule;
          if (p.continueSeats(returning: returning)) {
            context.go(
              p.step == TrainBookingStep.bookingReview
                  ? AppRoutes.trainV2BookingReview
                  : AppRoutes.trainV2Seats,
            );
          }
        },
      ),
      TrainBookingStep.bookingReview => (
        '결제 연습으로 가기',
        () {
          if (p.continueToPayment()) context.go(AppRoutes.trainV2Payment);
        },
      ),
      TrainBookingStep.payment => (
        '결제 연습 완료하기',
        () {
          if (p.finishPayment()) context.go(AppRoutes.trainV2Ticket);
        },
      ),
      TrainBookingStep.ticket => ('', null),
    };
    return trainPrimaryButton(context, label, action);
  }

  void _back(BuildContext context, TrainBookingProvider p) {
    if (pageStep == TrainBookingStep.tripType) {
      context.read<DailyMissionProvider>().cancelActiveMission();
      context.go(AppRoutes.trainStart);
    } else {
      p.previous();
      context.go(_route(p.step));
    }
  }
}

class TrainV2TicketPage extends StatefulWidget {
  const TrainV2TicketPage({super.key});
  @override
  State<TrainV2TicketPage> createState() => _TrainV2TicketPageState();
}

class _TrainV2TicketPageState extends State<TrainV2TicketPage> {
  bool _saving = false;
  bool _badge = false;
  bool _daily = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    final progress = context.read<LearningProgressProvider>();
    final dailyMissions = context.read<DailyMissionProvider>();
    if (context.read<TrainBookingProvider>().isFreePractice) {
      if (mounted) setState(() {});
      return;
    }
    final before = progress.trainSoloCompletionCount;
    if (progress.isTrainSoloMode) {
      _badge = await progress.completeTrainSoloLearning();
      if (progress.trainSoloCompletionCount > before) {
        _daily = await dailyMissions.completeActiveMission(
          MissionContentType.train,
        );
      }
    } else {
      await progress.completeTrainLearning();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TrainBookingProvider>();
    return TrainBookingScaffold(
      onBack: () => context.go(AppRoutes.trainV2BookingReview),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PracticeCompletionHeader(
            title: p.isFreePractice ? '자유 연습을 마쳤어요' : '기차표 예매 연습을 완료했어요',
            description: '연습용 승차권은 실제 탑승에 사용할 수 없어요.',
            modeLabel: practiceSessionLabel(
              isFreePractice: p.isFreePractice,
              isSolo: p.isSolo,
              dailyMission: _daily,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: trainLine),
            ),
            child: Column(
              children: [
                const Text(
                  '연습용 승차권',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Divider(),
                Text(
                  '${p.departure?.name} → ${p.arrival?.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '${p.outbound?.type} ${p.outbound?.number} · ${p.outbound?.departureTime} → ${p.outbound?.arrivalTime}',
                ),
                Text(
                  '${p.carType == TrainCarType.standard ? '일반실' : '우등실'} · ${p.carNumber}호차 · ${p.outboundSeats.map((e) => e.number).join(', ')}',
                  textAlign: TextAlign.center,
                ),
                if (p.isRoundTrip) ...[
                  const Divider(),
                  Text(
                    '${p.arrival?.name} → ${p.departure?.name}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${p.inbound?.type} ${p.inbound?.number} · ${p.inbound?.departureTime} → ${p.inbound?.arrivalTime}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${p.carType == TrainCarType.standard ? '일반실' : '우등실'} · ${p.carNumber}호차 · ${p.inboundSeats.map((e) => e.number).join(', ')}',
                    textAlign: TextAlign.center,
                  ),
                ],
                const Divider(),
                Text('${p.passengerCount}명 · ${trainMoney(p.totalFare)}'),
                Text(
                  '결제 방법 · ${p.payment == TrainPaymentMethod.card ? '카드' : '간편결제'}',
                ),
                const SizedBox(height: 14),
                const Icon(Icons.qr_code_2, size: 70, color: Colors.grey),
                const Text('연습용 · 실제로 인식되지 않아요'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TrainInlineNotice(
            p.isFreePractice
                ? '자유 연습을 마쳤어요. 보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                : '실제 탑승에는 사용할 수 없습니다.${_daily ? ' 오늘의 미션 추가 포인트 10점을 받았어요.' : ''}${_badge ? ' 새 배지를 받았어요.' : ''}',
          ),
          const SizedBox(height: 18),
          trainPrimaryButton(context, '한 번 더 연습하기', () {
            context.read<LearningProgressProvider>().resetTrainLearning();
            if (p.isFreePractice) {
              p.beginFreePractice();
            } else {
              p.begin(
                p.mode,
                completedCount: context
                    .read<LearningProgressProvider>()
                    .trainSoloCompletionCount,
              );
            }
            context.go(
              !p.isFreePractice && p.isSolo
                  ? AppRoutes.trainMission
                  : AppRoutes.trainV2TripType,
            );
          }),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
            ),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }
}

String _route(TrainBookingStep step) => switch (step) {
  TrainBookingStep.tripType => AppRoutes.trainV2TripType,
  TrainBookingStep.stations => AppRoutes.trainV2Stations,
  TrainBookingStep.date => AppRoutes.trainV2Date,
  TrainBookingStep.timeBand => AppRoutes.trainV2Time,
  TrainBookingStep.passengers => AppRoutes.trainV2Passengers,
  TrainBookingStep.searchReview => AppRoutes.trainV2SearchReview,
  TrainBookingStep.schedules => AppRoutes.trainV2Schedules,
  TrainBookingStep.carType => AppRoutes.trainV2CarType,
  TrainBookingStep.seats => AppRoutes.trainV2Seats,
  TrainBookingStep.bookingReview => AppRoutes.trainV2BookingReview,
  TrainBookingStep.payment => AppRoutes.trainV2Payment,
  TrainBookingStep.ticket => AppRoutes.trainV2Ticket,
};
