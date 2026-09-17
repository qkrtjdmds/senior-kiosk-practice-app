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
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('홈 화면을 표시한다', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LearningProgressProvider(preferences),
        child: const HanGeoleumDigitalApp(),
      ),
    );

    expect(find.text('한걸음 디지털'), findsOneWidget);
    expect(find.text('카페 키오스크 연습하기'), findsOneWidget);
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

    await tester.tap(find.text('카페 키오스크 연습하기'));
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

    await tester.tap(find.text('카페 키오스크 연습하기'));
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
    await tester.ensureVisible(find.text('결제하기'));
    await tester.tap(find.text('결제하기'));
    await tester.pumpAndSettle();

    expect(find.text('혼자서도 잘하셨어요!'), findsOneWidget);
    expect(find.text('오늘의 주문 미션을 완성했어요.'), findsOneWidget);
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

    expect(find.text('나의 디지털 걸음'), findsOneWidget);
    expect(find.text('70점'), findsOneWidget);
    expect(find.text('따라 해보기'), findsNWidgets(4));
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

    await tester.ensureVisible(find.text('병원 접수 연습하기'));
    await tester.tap(find.text('병원 접수 연습하기'));
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

    await tester.ensureVisible(find.text('사진 보내기 연습하기'));
    await tester.tap(find.text('사진 보내기 연습하기'));
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

    await tester.ensureVisible(find.text('기차표 예매 연습하기'));
    await tester.tap(find.text('기차표 예매 연습하기'));
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

    await tester.ensureVisible(find.text('기차표 예매 연습하기'));
    await tester.tap(find.text('기차표 예매 연습하기'));
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

    await tester.ensureVisible(find.text('병원 접수 연습하기'));
    await tester.tap(find.text('병원 접수 연습하기'));
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

    await tester.ensureVisible(find.text('사진 보내기 연습하기'));
    await tester.tap(find.text('사진 보내기 연습하기'));
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
