// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/hamburger/hamburger_mission.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/hamburger_v2/burger_order_provider.dart';
import 'package:han_geoleum_digital/features/hamburger_v2/burger_scenario.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_models.dart';
import 'package:han_geoleum_digital/features/train_v2/train_booking_models.dart';

void main() {
  testWidgets('홈 화면을 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('한걸음 디지털'), findsOneWidget);
    expect(find.text('카페 키오스크 연습'), findsOneWidget);
  });

  testWidgets('카페 주문 선택값을 4단계 확인 화면에 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences)
      ..selectMode(CafeLearningMode.guided);
    appRouter.go(AppRoutes.cafeStepOne);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.tap(find.text('포장할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카페라떼'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('따뜻하게 먹을게요'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 4 단계'), findsOneWidget);
    expect(find.text('포장'), findsOneWidget);
    expect(find.text('카페라떼'), findsOneWidget);
    expect(find.text('따뜻하게'), findsOneWidget);
  });

  testWidgets('혼자 해보기 미션은 정답 선택과 첫 배지를 확인한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    appRouter.go(AppRoutes.cafeStart);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문 미션'), findsOneWidget);
    expect(find.text('포장 · 차가운 아메리카노 · 보통 크기 1잔'), findsOneWidget);

    await tester.tap(find.text('혼자 주문해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('디카페인 아메리카노'));
    await tester.pump();
    expect(find.text('1 / 7 · 메뉴 고르기'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 주문 내용을 다시 살펴볼까요?'), findsOneWidget);

    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.textContaining('힌트: 차가운 아메리카노'), findsOneWidget);

    await tester.tap(find.text('아메리카노'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('따뜻하게'));
    await tester.pump();
    expect(find.text('2 / 7 · 온도 고르기'), findsOneWidget);
    await tester.tap(find.text('차갑게'));
    await tester.pump();
    await tester.tap(find.text('다음으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보통'));
    await tester.pump();
    await tester.tap(find.text('다음으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('포장'));
    await tester.pump();
    await tester.tap(find.text('장바구니에 담기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('주문 확인하기'));
    await tester.tap(find.text('주문 확인하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('적립하지 않기'));
    await tester.pump();
    await tester.tap(find.text('다음으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('신용카드'));
    await tester.pump();
    await tester.tap(find.text('결제 연습 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('주문 연습을 완료했어요!'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('실제 주문이나 결제가 진행된 것은 아니에요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.textContaining('혼자 주문 첫걸음'), findsOneWidget);
  });

  test('카페 완료 횟수를 저장하고 다시 읽는다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.markCafeLearningCompleted();
    await progress.markCafeLearningCompleted();

    expect(progress.cafeCompletionCount, 2);
    final reloaded = await SharedPreferences.getInstance();
    expect(LearningProgressProvider(reloaded).cafeCompletionCount, 2);
  });

  test('학습 모드별 포인트를 한 번씩만 지급한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    progress.selectMode(CafeLearningMode.guided);
    await progress.completeCafeLearning();
    await progress.completeCafeLearning();

    expect(progress.totalPoints, 10);
    expect(progress.guidedCompletionCount, 1);
    expect(progress.soloCompletionCount, 0);

    progress.selectMode(CafeLearningMode.solo);
    final firstSoloBadge = await progress.completeCafeLearning();
    await progress.completeCafeLearning();

    expect(progress.totalPoints, 30);
    expect(progress.guidedCompletionCount, 1);
    expect(progress.soloCompletionCount, 1);
    expect(firstSoloBadge, isTrue);
    expect(progress.soloFirstBadgeEarned, isTrue);

    progress.resetCafeLearning();
    final secondSoloBadge = await progress.completeCafeLearning();

    expect(secondSoloBadge, isFalse);
    expect(progress.totalPoints, 50);
    expect(progress.soloCompletionCount, 2);
  });

  testWidgets('나의 디지털 걸음 화면에 기록과 배지를 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'digital_confidence_points': 70,
      'cafe_guided_completion_count': 3,
      'cafe_solo_completion_count': 3,
      'cafe_solo_first_badge_earned': true,
      'cafe_familiar_badge_earned': true,
    });
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.progress);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('내 정보'), findsWidgets);
    expect(find.text('70점'), findsOneWidget);
    expect(find.text('따라 해보기'), findsNWidgets(7));
    expect(find.text('3회'), findsNWidgets(2));
    expect(find.text('혼자 주문 첫걸음'), findsOneWidget);
    expect(find.text('카페 주문 익숙해졌어요'), findsOneWidget);
    expect(find.text('달성했어요'), findsOneWidget);
  });

  testWidgets('홈에서 병원 접수 V2를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpAndSettle();
    expect(find.text('병원 접수 연습'), findsOneWidget);

    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    for (final choice in ['접수 시작하기', '진료 접수', '전에 방문한 적 있어요']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('환자 확인하기'));
    await tester.pumpAndSettle();
    for (final choice in ['예약했어요', '내과', '감기 증상']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('접수 완료하기'));
    await tester.tap(find.text('접수 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('진료 접수 연습을 완료했어요!'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
    expect(find.text('A-023 (연습용)'), findsOneWidget);
  });
  test('병원 접수 완료 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.completeHospitalLearning();
    await progress.completeHospitalLearning();

    expect(progress.hospitalCompletionCount, 1);
    expect(progress.totalPoints, 10);
  });

  testWidgets('사진 보내기 V2 따라 해보기를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    appRouter.go(AppRoutes.photoStart);
    await tester.pumpAndSettle();
    expect(find.text('사진 보내기 연습'), findsWidgets);

    final progress = Provider.of<LearningProgressProvider>(
      tester.element(find.text('따라 해보기')),
      listen: false,
    );
    progress.selectPhotoMode(PhotoLearningMode.guided);
    photoSendProvider.begin(PhotoSendMode.guided);
    photoSendProvider
      ..chooseRecipient(contactById('daughter'))
      ..confirmChat()
      ..openAddPhoto()
      ..choosePermission(PhotoPermissionChoice.selectedOnly)
      ..chooseAlbum('꽃과 풍경')
      ..togglePhoto('red_flower')
      ..finishPhotoSelection()
      ..confirmPreview()
      ..confirmReview();
    final guidedSend = photoSendProvider.sendVirtually();
    await tester.pump(const Duration(milliseconds: 400));
    await guidedSend;
    photoSendProvider.confirmResult();
    appRouter.go(AppRoutes.photoComplete);
    await tester.pumpAndSettle();

    expect(find.text('사진 보내기 연습 완료'), findsWidgets);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
    expect(progress.photoCompletionCount, 1);
  });

  test('사진 보내기 완료 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.completePhotoLearning();
    await progress.completePhotoLearning();

    expect(progress.photoCompletionCount, 1);
    expect(progress.totalPoints, 10);
  });

  testWidgets('기차표 V2 따라 해보기 진입과 완료 보상을 확인한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );
    appRouter.go(AppRoutes.trainStart);
    await tester.pumpAndSettle();
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('어떤 표를 예매할까요?'), findsOneWidget);
    expect(find.textContaining('1 /'), findsOneWidget);

    trainBookingProvider.outbound = TrainSchedule(
      id: 'test',
      type: '한걸음 고속',
      number: 'H101',
      departure: trainStations.firstWhere((e) => e.id == 'seoul'),
      arrival: trainStations.firstWhere((e) => e.id == 'busan'),
      departureMinutes: 560,
      durationMinutes: 150,
      standardSeats: 10,
      premiumSeats: 4,
      standardFare: 42000,
      premiumFare: 59000,
    );
    trainBookingProvider.departure = trainStations.firstWhere(
      (e) => e.id == 'seoul',
    );
    trainBookingProvider.arrival = trainStations.firstWhere(
      (e) => e.id == 'busan',
    );
    trainBookingProvider.carType = TrainCarType.standard;
    trainBookingProvider.outboundSeats.add(const TrainSeat('1A'));
    appRouter.go(AppRoutes.trainV2Ticket);
    await tester.pumpAndSettle();

    expect(find.text('기차표 예매 연습을 완료했어요'), findsOneWidget);
    expect(find.text('연습용 승차권'), findsOneWidget);
    expect(find.textContaining('실제 탑승에는 사용할 수 없습니다'), findsOneWidget);
    final progress = tester
        .element(find.text('기차표 예매 연습을 완료했어요'))
        .read<LearningProgressProvider>();
    expect(progress.trainCompletionCount, 1);
    expect(progress.totalPoints, 10);
  });
  test('기차표 예매 완료 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.completeTrainLearning();
    await progress.completeTrainLearning();

    expect(progress.trainCompletionCount, 1);
    expect(progress.totalPoints, 10);
  });

  testWidgets('기차표 V2 혼자 해보기 목표와 인라인 힌트를 확인한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );
    appRouter.go(AppRoutes.trainStart);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 기차표 예매 목표'), findsOneWidget);
    expect(find.textContaining('서울에서 부산'), findsNWidgets(2));
    await tester.tap(find.text('혼자 예매해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('왕복'));
    await tester.pump();
    expect(find.textContaining('1 /'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 예매 목표를 다시 살펴볼까요?'), findsOneWidget);
    await tester.tap(find.text('힌트 보기'));
    await tester.pump();
    expect(find.textContaining('힌트: 편도를 골라보세요.'), findsOneWidget);
  });
  test('기차표 혼자 해보기 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectTrainMode(TrainLearningMode.solo);

    final firstBadge = await progress.completeTrainSoloLearning();
    await progress.completeTrainSoloLearning();

    expect(firstBadge, isTrue);
    expect(progress.trainSoloCompletionCount, 1);
    expect(progress.trainSoloFirstBadgeEarned, isTrue);
    expect(progress.totalPoints, 20);
  });

  testWidgets('병원 V2 혼자 해보기 미션과 첫 배지를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpAndSettle();
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 병원 접수 미션'), findsOneWidget);
    expect(find.text('처음 방문 접수'), findsOneWidget);
    await tester.tap(find.text('혼자 접수해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('접수 시작하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('진료 접수'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('전에 방문한 적 있어요'));
    await tester.pump();
    expect(find.textContaining('괜찮아요.'), findsOneWidget);
    await tester.tap(find.text('힌트 보기'));
    await tester.pump();
    expect(find.textContaining('처음 방문이에요'), findsWidgets);

    await tester.tap(find.text('처음 방문이에요'));
    await tester.pumpAndSettle();
    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('환자 확인하기'));
    await tester.pumpAndSettle();
    for (final choice in ['예약하지 않았어요', '내과', '배가 불편해요']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('접수 완료하기'));
    await tester.tap(find.text('접수 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.textContaining('용기 포인트 +20점'), findsOneWidget);
    expect(find.textContaining('혼자 병원 접수 첫걸음'), findsOneWidget);
  });
  test('병원 혼자 해보기 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectHospitalMode(HospitalLearningMode.solo);

    final firstBadge = await progress.completeHospitalSoloLearning();
    await progress.completeHospitalSoloLearning();

    expect(firstBadge, isTrue);
    expect(progress.hospitalSoloCompletionCount, 1);
    expect(progress.hospitalSoloFirstBadgeEarned, isTrue);
    expect(progress.totalPoints, 20);
  });

  testWidgets('사진 보내기 혼자 해보기 미션과 첫 배지를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    appRouter.go(AppRoutes.photoStart);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 사진 보내기 목표'), findsOneWidget);
    expect(find.textContaining('딸 김하늘에게 빨간 꽃'), findsOneWidget);
    final progress = Provider.of<LearningProgressProvider>(
      tester.element(find.text('혼자 사진 보내기')),
      listen: false,
    );
    photoSendProvider
      ..chooseRecipient(contactById('daughter'))
      ..confirmChat()
      ..openAddPhoto()
      ..choosePermission(PhotoPermissionChoice.selectedOnly)
      ..chooseAlbum('꽃과 풍경')
      ..togglePhoto('red_flower')
      ..finishPhotoSelection()
      ..confirmPreview()
      ..confirmReview();
    final soloSend = photoSendProvider.sendVirtually();
    await tester.pump(const Duration(milliseconds: 400));
    await soloSend;
    photoSendProvider.confirmResult();
    appRouter.go(AppRoutes.photoComplete);
    await tester.pumpAndSettle();

    expect(find.text('사진 보내기 연습 완료'), findsWidgets);
    expect(find.textContaining('용기 포인트 +20점'), findsOneWidget);
    expect(find.textContaining('혼자 사진 보내기 첫걸음'), findsOneWidget);
    expect(progress.photoSoloCompletionCount, 1);
  });

  test('사진 보내기 혼자 해보기 보상은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectPhotoMode(PhotoLearningMode.solo);

    final firstBadge = await progress.completePhotoSoloLearning();
    await progress.completePhotoSoloLearning();

    expect(firstBadge, isTrue);
    expect(progress.photoSoloCompletionCount, 1);
    expect(progress.photoSoloFirstBadgeEarned, isTrue);
    expect(progress.totalPoints, 20);
  });

  test('최근 연습 기록을 저장하고 20개로 유지한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectTrainMode(TrainLearningMode.guided);

    await progress.completeTrainLearning();
    await progress.completeTrainLearning();
    expect(progress.recentPracticeRecords.length, 1);

    for (var index = 0; index < 20; index++) {
      progress.resetTrainLearning();
      await progress.completeTrainLearning();
    }

    expect(progress.recentPracticeRecords.length, 20);
    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.recentPracticeRecords.length, 20);
  });

  test('햄버거 V2 따라 해보기는 권장 선택만 다음 단계로 진행한다', () {
    final order = BurgerOrderProvider()..begin(HamburgerLearningMode.guided);
    order.chooseDine('매장에서 먹기', correct: false);
    expect(order.step, BurgerOrderStep.dine);
    expect(order.inlineMessage, isNotNull);
    order.chooseDine('포장하기', correct: true);
    expect(order.step, BurgerOrderStep.menu);
  });
  test('햄버거 주문 완료 보상과 기록은 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.completeHamburgerLearning();
    await progress.completeHamburgerLearning();

    expect(progress.hamburgerCompletionCount, 1);
    expect(progress.totalPoints, 10);
    expect(progress.recentPracticeRecords, hasLength(1));
    expect(progress.recentPracticeRecords.single.learningName, '햄버거 주문');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.hamburgerCompletionCount, 1);
    expect(reloaded.totalPoints, 10);
  });

  testWidgets('햄버거 V2 혼자 해보기 미션과 힌트를 확인한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.hamburgerStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    final mission = progress.currentHamburgerMission;
    expect(find.text('오늘의 햄버거 주문 미션'), findsWidgets);
    expect(
      find.text(BurgerScenario.fromMissionId(mission.id).title),
      findsOneWidget,
    );
    await tester.tap(find.text('혼자 주문해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('힌트 보기'));
    await tester.pump();
    expect(find.textContaining('힌트:'), findsOneWidget);
    final targetDine = BurgerScenario.fromMissionId(mission.id).dine;
    final wrong = targetDine == '포장하기' ? '매장에서 먹기' : '포장하기';
    await tester.tap(find.text(wrong));
    await tester.pump();
    expect(find.text('1 / 9 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요'), findsOneWidget);
  });

  test('햄버거 혼자 해보기 보상과 첫 배지는 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    progress.selectHamburgerMode(HamburgerLearningMode.solo);

    final firstBadge = await progress.completeHamburgerSoloLearning();
    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    final duplicateBadge = await reentered.completeHamburgerSoloLearning();

    expect(firstBadge, isTrue);
    expect(duplicateBadge, isFalse);
    expect(progress.hamburgerSoloCompletionCount, 1);
    expect(progress.hamburgerSoloFirstBadgeEarned, isTrue);
    expect(progress.totalPoints, 20);
    expect(progress.recentPracticeRecords, hasLength(1));
    expect(progress.recentPracticeRecords.single.modeName, '혼자 해보기');
    expect(
      progress.recentPracticeRecords.single.detail,
      progress.currentHamburgerMission.title,
    );

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.hamburgerSoloCompletionCount, 1);
    expect(reloaded.hamburgerSoloFirstBadgeEarned, isTrue);
    expect(reloaded.totalPoints, 20);
  });

  test('햄버거 미션 3개를 관리하고 같은 미션을 연속 선택하지 않는다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    expect(HamburgerMission.missions, hasLength(3));
    expect(
      HamburgerMission.missions.map((mission) => mission.displayText),
      containsAll(['포장 · 치즈버거 세트 · 콜라', '매장 · 불고기버거 단품', '매장 · 새우버거 세트 · 사이다']),
    );

    await progress.startHamburgerSoloMission();
    final firstMissionId = progress.currentHamburgerMission.id;
    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.currentHamburgerMission.id, firstMissionId);
    expect(reloaded.isHamburgerSoloMode, isTrue);

    await reloaded.startHamburgerSoloMission();
    expect(reloaded.currentHamburgerMission.id, isNot(firstMissionId));
  });

  test('ATM 출금 완료 보상과 기록은 재진입해도 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.startAtmLearning();
    progress.selectAtmAmount('10만 원');
    await progress.completeAtmLearning();

    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await reentered.completeAtmLearning();

    expect(reentered.atmCompletionCount, 1);
    expect(reentered.totalPoints, 10);
    expect(reentered.recentPracticeRecords, hasLength(1));
    expect(reentered.recentPracticeRecords.single.learningName, 'ATM 출금');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.atmCompletionCount, 1);
    expect(reloaded.totalPoints, 10);
  });

  testWidgets('홈에서 무인민원발급기 V2 따라 해보기를 완료한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.civilDocumentStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('실제 증명서가 발급되지 않고'), findsOneWidget);
    await tester.tap(find.text('증명서 발급 시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('주민등록'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('주민등록표 등본'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('발급 안내를 확인했어요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('본인 확인 연습 시작'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('지문 인식 시도'));
    await tester.pump();
    await tester.tap(find.text('다시 인식하기'));
    await tester.pumpAndSettle();

    for (final option in [
      '주소 변동 사항: 포함 안 함',
      '세대 구성 사유: 포함 안 함',
      '주민등록번호 뒷자리: 표시 안 함',
      '세대원 정보: 전체',
      '발급 형태: 필요한 내용만',
    ]) {
      await tester.scrollUntilVisible(
        find.text(option),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(option));
      await tester.pump();
    }
    await tester.tap(find.text('옵션 선택 완료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1부'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('신청 내용 확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드'));
    await tester.pump();
    await tester.tap(find.text('가상 결제 연습'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.tap(find.text('카드를 챙겼어요'));
    await tester.pump();
    await tester.tap(find.text('증명서 출력으로'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가상 출력 시작'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('증명서 챙기기').last);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('증명서 챙기기').last);
    await tester.pump();
    await tester.tap(find.text('개인정보 안전 종료'));
    await tester.pump();
    await tester.tap(find.text('연습 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('증명서 발급 연습 완료'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
    expect(progress.civilDocumentCompletionCount, 1);
    expect(progress.totalPoints, 10);
    expect(tester.takeException(), isNull);
  });
  test('무인민원발급기 완료 보상과 기록은 재진입해도 한 번만 저장한다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);

    await progress.startCivilDocumentLearning();
    progress.selectCivilDocumentContent('기본 내용');
    progress.selectCivilDocumentCopies('한 부');
    await progress.completeCivilDocumentLearning();

    final reentered = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await reentered.completeCivilDocumentLearning();

    expect(reentered.civilDocumentCompletionCount, 1);
    expect(reentered.totalPoints, 10);
    expect(reentered.recentPracticeRecords, hasLength(1));
    expect(reentered.recentPracticeRecords.single.learningName, '무인민원발급기');

    final reloaded = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    expect(reloaded.civilDocumentCompletionCount, 1);
    expect(reloaded.totalPoints, 10);
  });

  testWidgets('최근 기록이 없을 때 시작 안내를 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.progress);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('아직 완료한 연습이 없어요.'), findsOneWidget);
    expect(find.text('홈에서 연습 시작하기'), findsOneWidget);
  });

  testWidgets('320dp 기본 글씨에서 삭제 키 문구를 온전히 한 줄로 표시한다', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (final choice in ['따라 해보기', '접수 시작하기', '진료 접수', '전에 방문한 적 있어요']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }

    expect(find.text('한 글자'), findsOneWidget);
    expect(find.text('전체'), findsOneWidget);
    for (final label in ['한 글자', '전체']) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
      expect(text.overflow, isNull);
    }
    expect(find.bySemanticsLabel('입력한 숫자 한 글자 지우기'), findsOneWidget);
    expect(find.bySemanticsLabel('입력한 숫자 전체 지우기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('320dp 아주 큰 글씨에서 병원 환자 확인 키패드가 넘치지 않는다', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    appRouter.go(AppRoutes.hospitalStart);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final choice in ['따라 해보기', '접수 시작하기', '진료 접수', '전에 방문한 적 있어요']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }

    expect(find.bySemanticsLabel('입력한 숫자 한 글자 지우기'), findsOneWidget);
    expect(find.bySemanticsLabel('입력한 숫자 전체 지우기'), findsOneWidget);
    expect(find.text('한 글자'), findsNothing);
    expect(find.text('전체'), findsNothing);
    final disabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '환자 확인하기'),
    );
    expect(disabled.onPressed, isNull);
    expect(tester.takeException(), isNull);

    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '환자 확인하기'),
    );
    expect(enabled.onPressed, isNotNull);
    expect(find.bySemanticsLabel('8자리 중 8자리 입력됨'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('병원 예약 확인 따라 해보기 전체 흐름을 완료한다', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final choice in ['따라 해보기', '접수 시작하기', '예약 확인', '예약 확인 시작하기']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    expect(find.text('2 / 5 단계'), findsOneWidget);
    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('환자 확인하기'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 5 단계'), findsOneWidget);
    expect(find.text('오늘 · 오전 10:30'), findsOneWidget);
    expect(find.text('내일 · 오후 2:00'), findsOneWidget);
    expect(find.text('다음 주 화요일 · 오전 11:00'), findsOneWidget);

    await tester.tap(find.text('내일 · 오후 2:00'));
    await tester.pump();
    expect(find.textContaining('다시 확인'), findsOneWidget);
    expect(find.text('3 / 5 단계'), findsOneWidget);

    await tester.tap(find.text('오늘 · 오전 10:30'));
    await tester.pumpAndSettle();
    expect(find.text('4 / 5 단계'), findsOneWidget);
    await tester.tap(find.text('이 예약 확인하기'));
    await tester.pumpAndSettle();
    expect(find.text('예약 확인 연습을 완료했어요'), findsOneWidget);
    expect(find.text('5 / 5 단계'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('병원 진료비 수납 카드 결제와 가상 영수증을 완료한다', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (final choice in ['따라 해보기', '접수 시작하기', '진료비 수납', '진료비 수납 시작하기']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    expect(find.text('2 / 7 단계'), findsOneWidget);
    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('환자 확인하기'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 7 단계'), findsOneWidget);
    expect(find.text('18,500원'), findsOneWidget);
    expect(find.text('32,000원'), findsOneWidget);
    expect(find.text('12,700원'), findsOneWidget);
    await tester.tap(find.text('지난주 · 이비인후과'));
    await tester.pump();
    expect(find.textContaining('납부가 완료'), findsOneWidget);
    await tester.tap(find.text('오늘 · 내과'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이 진료비 수납하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드'));
    await tester.pumpAndSettle();
    for (final action in ['카드를 넣었어요', '금액을 확인했어요', '결제 연습 진행', '카드를 챙겼어요']) {
      await tester.ensureVisible(find.textContaining(action));
      await tester.tap(find.textContaining(action));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('영수증 받기'));
    await tester.tap(find.text('영수증 받기'));
    await tester.pump();
    await tester.ensureVisible(find.text('수납 연습 완료하기'));
    await tester.tap(find.text('수납 연습 완료하기'));
    await tester.pumpAndSettle();
    expect(find.text('진료비 수납 연습을 완료했어요'), findsOneWidget);
    expect(find.text('연습용 가상 영수증'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('병원 서류 발급은 320dp에서 서류 목록과 신청 확인을 표시한다', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    appRouter.go(AppRoutes.hospitalStart);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    for (final choice in ['따라 해보기', '접수 시작하기', '서류 발급', '서류 발급 시작하기']) {
      await tester.ensureVisible(find.text(choice));
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
    }
    expect(find.text('2 / 8 단계'), findsOneWidget);
    for (final digit in '19580412'.split('')) {
      await tester.ensureVisible(find.text(digit));
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('환자 확인하기'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 8 단계'), findsOneWidget);
    expect(find.text('통원확인서'), findsOneWidget);
    expect(find.text('진단서'), findsOneWidget);
    await tester.ensureVisible(find.text('진단서'));
    await tester.tap(find.text('진단서'));
    await tester.pump();
    expect(find.textContaining('원무창구'), findsWidgets);
    await tester.ensureVisible(find.text('통원확인서'));
    await tester.tap(find.text('통원확인서'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보험회사 제출'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1부'));
    await tester.pumpAndSettle();
    expect(find.text('6 / 8 단계'), findsOneWidget);
    expect(find.text('총 가상 수수료'), findsOneWidget);
    expect(find.text('3,000원'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
