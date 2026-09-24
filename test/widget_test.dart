// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/hamburger/hamburger_mission.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

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
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.tap(find.text('카페 키오스크 연습'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
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

    await tester.tap(find.text('카페 키오스크 연습'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문 미션'), findsOneWidget);
    expect(find.text('포장 · 아이스 아메리카노'), findsOneWidget);

    await tester.tap(find.text('혼자 주문해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('매장에서 먹을게요'));
    await tester.pump();
    expect(find.text('1 / 4 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘의 주문을 다시 확인해볼까요?'), findsOneWidget);

    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문'), findsOneWidget);
    expect(find.text('포장 · 아이스 아메리카노'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('포장할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('아메리카노'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('차갑게 먹을게요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('주문 완료하기'));
    await tester.tap(find.text('주문 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('잘하셨어요!'), findsOneWidget);
    expect(find.text('카페 주문 순서를 한 걸음 더 익혔어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 주문 첫걸음'), findsOneWidget);
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

  testWidgets('홈에서 병원 접수 4단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('병원 접수'));
    await tester.tap(find.text('병원 접수'));
    await tester.pumpAndSettle();
    expect(find.text('병원 접수 연습'), findsNWidgets(2));

    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('진료를 받으러 왔어요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('처음 방문이에요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('속이 불편해요'));
    await tester.pumpAndSettle();

    expect(find.text('내과'), findsOneWidget);
    await tester.ensureVisible(find.text('접수 완료하기'));
    await tester.tap(find.text('접수 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('잘하셨어요!'), findsOneWidget);
    expect(find.text('병원 접수 순서를 천천히 잘 따라오셨어요.'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
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

  testWidgets('사진 보내기 4단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('사진 보내기'));
    await tester.tap(find.text('사진 보내기'));
    await tester.pumpAndSettle();
    expect(find.text('사진 보내기 연습'), findsWidgets);

    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가족에게 보낼게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('꽃 사진'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('사진 보세요!'));
    await tester.pumpAndSettle();

    expect(find.text('가족'), findsOneWidget);
    expect(find.text('꽃 사진'), findsOneWidget);
    expect(find.text('사진 보세요!'), findsOneWidget);
    await tester.ensureVisible(find.text('사진 보내기'));
    await tester.tap(find.text('사진 보내기'));
    await tester.pumpAndSettle();

    expect(find.text('사진을 보내는 순서를 천천히 잘 따라오셨어요.'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
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

  testWidgets('기차표 예매 5단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('기차표 예매'));
    await tester.tap(find.text('기차표 예매'));
    await tester.pumpAndSettle();
    expect(find.text('기차표 예매 연습'), findsWidgets);

    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서울역'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서울역'));
    await tester.pump();
    expect(find.text('2 / 5 단계'), findsOneWidget);
    expect(find.text('출발역과 다른 도착역을 골라볼까요?'), findsOneWidget);

    await tester.tap(find.text('부산역'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('오늘 오전'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('창가 자리'));
    await tester.pumpAndSettle();

    expect(find.text('5 / 5 단계'), findsOneWidget);
    expect(find.text('서울역'), findsOneWidget);
    expect(find.text('부산역'), findsOneWidget);
    expect(find.text('오늘 오전'), findsOneWidget);
    expect(find.text('창가 자리'), findsOneWidget);
    await tester.ensureVisible(find.text('예매 완료하기'));
    await tester.tap(find.text('예매 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('기차표 예매 순서를 천천히 잘 따라오셨어요.'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
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

  testWidgets('기차표 혼자 해보기 미션과 첫 배지를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('기차표 예매'));
    await tester.tap(find.text('기차표 예매'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 기차표 예매 미션'), findsOneWidget);
    expect(find.text('서울역에서 부산역까지'), findsOneWidget);
    await tester.tap(find.text('혼자 예매해보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('부산역'));
    await tester.pump();
    expect(find.text('1 / 5 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘의 예매 내용을 다시 확인해볼까요?'), findsOneWidget);
    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 예매 내용'), findsOneWidget);
    expect(find.textContaining('서울역 → 부산역'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('서울역'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('부산역'));
    await tester.tap(find.text('부산역'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('내일 오전'));
    await tester.tap(find.text('내일 오전'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('창가 자리'));
    await tester.tap(find.text('창가 자리'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('예매 완료하기'));
    await tester.tap(find.text('예매 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 기차표 예매 미션을 완성했어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('기차표 예매 첫걸음'), findsOneWidget);
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

  testWidgets('병원 혼자 해보기 미션과 첫 배지를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('병원 접수'));
    await tester.tap(find.text('병원 접수'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 병원 접수 미션'), findsOneWidget);
    expect(find.text('진료 접수 · 다시 방문'), findsOneWidget);
    await tester.tap(find.text('혼자 접수해보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('예약을 확인하고 싶어요'));
    await tester.pump();
    expect(find.text('1 / 4 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘의 접수 내용을 다시 확인해볼까요?'), findsOneWidget);
    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 접수 내용'), findsOneWidget);
    expect(find.textContaining('진료를 받으러 왔어요'), findsNWidgets(2));
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('진료를 받으러 왔어요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다시 방문했어요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('무릎이나 허리가 불편해요'));
    await tester.tap(find.text('무릎이나 허리가 불편해요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('접수 완료하기'));
    await tester.tap(find.text('접수 완료하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 병원 접수 미션을 완성했어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 병원 접수 첫걸음'), findsOneWidget);
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

    await tester.ensureVisible(find.text('사진 보내기'));
    await tester.tap(find.text('사진 보내기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 사진 보내기 미션'), findsOneWidget);
    expect(find.text('가족에게 꽃 사진 보내기'), findsOneWidget);
    await tester.tap(find.text('혼자 보내보기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('친구에게 보낼게요'));
    await tester.pump();
    expect(find.text('1 / 4 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘 보낼 내용을 다시 확인해볼까요?'), findsOneWidget);
    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘 보낼 내용'), findsOneWidget);
    expect(find.textContaining('가족에게 보내기'), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('가족에게 보낼게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('꽃 사진'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('사진 보세요!'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('사진 보내기'));
    await tester.tap(find.text('사진 보내기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 사진 보내기 미션을 완성했어요.'), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 사진 보내기 첫걸음'), findsOneWidget);
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

  testWidgets('홈에서 햄버거 주문 4단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('햄버거 주문'));
    await tester.tap(find.text('햄버거 주문'));
    await tester.pumpAndSettle();
    expect(find.text('햄버거 주문 연습'), findsNWidgets(2));

    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('포장할게요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('새우버거'));
    await tester.tap(find.text('새우버거'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('세트로 주문할게요'));
    await tester.pumpAndSettle();
    expect(find.text('음료를 골라주세요'), findsOneWidget);
    await tester.tap(find.text('물'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 4 단계'), findsOneWidget);
    expect(find.text('포장'), findsWidgets);
    expect(find.text('새우버거'), findsWidgets);
    expect(find.text('세트'), findsWidgets);
    expect(find.text('물'), findsWidgets);
    await tester.ensureVisible(find.text('결제하기'));
    await tester.tap(find.text('결제하기'));
    await tester.pumpAndSettle();

    expect(find.text('잘하셨어요!'), findsOneWidget);
    expect(find.text('햄버거 주문 순서를 천천히 잘 따라오셨어요.'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
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

  testWidgets('햄버거 혼자 해보기 미션과 첫 배지를 완료한다', (WidgetTester tester) async {
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

    await tester.ensureVisible(find.text('햄버거 주문'));
    await tester.tap(find.text('햄버거 주문'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('혼자 해보기'));
    await tester.tap(find.text('혼자 해보기'));
    await tester.pumpAndSettle();

    final mission = progress.currentHamburgerMission;
    expect(find.text('오늘의 햄버거 주문 미션'), findsOneWidget);
    expect(find.text(mission.title), findsOneWidget);
    expect(find.text(mission.displayText), findsOneWidget);
    await tester.tap(find.text('혼자 주문해보기'));
    await tester.pumpAndSettle();

    final wrongDineOption = mission.dineOption == '포장' ? '매장에서 먹을게요' : '포장할게요';
    await tester.tap(find.text(wrongDineOption));
    await tester.pump();
    expect(find.text('1 / 4 단계'), findsOneWidget);
    expect(find.textContaining('괜찮아요. 오늘의 주문 내용을 다시 확인해볼까요?'), findsOneWidget);
    await tester.ensureVisible(find.text('힌트 보기'));
    await tester.tap(find.text('힌트 보기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 주문 내용'), findsOneWidget);
    expect(find.textContaining(mission.menu), findsOneWidget);
    await tester.tap(find.text('다시 해볼게요'));
    await tester.pumpAndSettle();

    final dineChoice = mission.dineOption == '포장' ? '포장할게요' : '매장에서 먹을게요';
    await tester.tap(find.text(dineChoice));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(mission.menu));
    await tester.tap(find.text(mission.menu));
    await tester.pumpAndSettle();
    final orderChoice = mission.isSet ? '세트로 주문할게요' : '햄버거만 주문할게요';
    await tester.tap(find.text(orderChoice));
    await tester.pumpAndSettle();
    if (mission.isSet) {
      await tester.tap(find.text(mission.drink!));
      await tester.pumpAndSettle();
    }

    expect(find.text('4 / 4 단계'), findsOneWidget);
    expect(find.text(mission.menu), findsWidgets);
    expect(find.text(mission.drink ?? '선택하지 않음'), findsWidgets);
    await tester.ensureVisible(find.text('결제하기'));
    await tester.tap(find.text('결제하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 햄버거 주문 미션을 완성했어요.'), findsOneWidget);
    expect(find.text(mission.title), findsOneWidget);
    expect(find.text('용기 포인트 +20점'), findsOneWidget);
    expect(find.text('혼자 햄버거 주문 첫걸음'), findsOneWidget);
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

  testWidgets('홈에서 ATM 출금 5단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('ATM 출금'));
    await tester.tap(find.text('ATM 출금'));
    await tester.pumpAndSettle();
    expect(find.text('ATM 출금 연습'), findsNWidgets(2));
    expect(find.text('실제 돈이 나가지 않는 연습 화면이에요.'), findsOneWidget);

    await tester.ensureVisible(find.text('따라 해보기'));
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('도움이 필요해요'));
    await tester.tap(find.text('도움이 필요해요'));
    await tester.pump();
    expect(find.text('1 / 5 단계'), findsOneWidget);
    expect(find.text('괜찮아요. 카드를 넣는 것부터 천천히 해볼까요?'), findsOneWidget);
    await tester.tap(find.text('카드를 넣을게요'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('잔액을 확인할게요'));
    await tester.pump();
    expect(find.text('2 / 5 단계'), findsOneWidget);
    expect(find.text('이번에는 돈을 찾는 연습을 해볼까요?'), findsOneWidget);
    await tester.tap(find.text('돈을 찾을게요'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('5만 원'));
    await tester.tap(find.text('5만 원'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 5 단계'), findsOneWidget);
    expect(find.text('출금 금액'), findsOneWidget);
    expect(find.text('수수료'), findsOneWidget);
    expect(find.text('없음'), findsOneWidget);
    expect(find.text('받을 금액'), findsOneWidget);
    expect(find.text('5만 원'), findsNWidgets(2));
    await tester.tap(find.text('맞아요, 출금할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('카드만 챙겼어요'));
    await tester.pump();
    expect(find.text('5 / 5 단계'), findsOneWidget);
    expect(find.text('돈도 함께 챙기면 더 안전해요.'), findsOneWidget);
    await tester.tap(find.text('카드와 돈을 챙겼어요'));
    await tester.pumpAndSettle();

    expect(find.text('잘하셨어요! ATM 출금 연습을 마쳤어요.'), findsOneWidget);
    expect(find.text('실제 ATM에서도 카드와 돈을 함께 챙겨보세요.'), findsOneWidget);
    expect(find.text('+10점'), findsOneWidget);
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

  testWidgets('홈에서 무인민원발급기 5단계를 완료한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    await tester.ensureVisible(find.text('서류 발급'));
    await tester.tap(find.text('서류 발급'));
    await tester.pumpAndSettle();
    expect(find.text('무인민원발급기 연습'), findsNWidgets(2));
    expect(find.text('이 화면은 실제 서류를 발급하지 않는 연습용 화면이에요.'), findsOneWidget);

    await tester.ensureVisible(find.text('따라 해보기'));
    await tester.tap(find.text('따라 해보기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('가족관계증명서'));
    await tester.tap(find.text('가족관계증명서'));
    await tester.pump();
    expect(find.text('1 / 5 단계'), findsOneWidget);
    expect(find.text('이번 연습에서는 주민등록등본을 발급해볼게요.'), findsOneWidget);

    await tester.ensureVisible(find.text('주민등록등본'));
    await tester.tap(find.text('주민등록등본'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기본 내용으로 발급할게요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한 부'));
    await tester.pumpAndSettle();

    expect(find.text('4 / 5 단계'), findsOneWidget);
    expect(find.text('주민등록등본'), findsOneWidget);
    expect(find.text('기본 내용'), findsOneWidget);
    expect(find.text('한 부'), findsOneWidget);
    await tester.tap(find.text('발급 확인'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서류를 챙길게요'));
    await tester.pumpAndSettle();

    expect(find.text('잘하셨어요!'), findsOneWidget);
    expect(find.text('무인민원발급기에서 서류를 발급하는 순서를 천천히 잘 따라오셨어요.'), findsOneWidget);
    expect(find.text('한걸음 포인트 +10점'), findsOneWidget);
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
}
