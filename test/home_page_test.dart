import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  Future<LearningProgressProvider> pumpHome(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'digital_confidence_points': 30,
      'accessibility_text_size': 'extraLarge',
      'screen_contrast': 'vivid',
    });
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    return progress;
  }

  testWidgets('좁은 화면과 아주 큰 글씨에서 홈 카드가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHome(tester);

    expect(find.text('원하는 연습을 바로 시작해 보세요'), findsOneWidget);
    expect(find.text('홈에서는 점수 없이 자유롭게 반복할 수 있어요.'), findsOneWidget);
    expect(find.text('최근 활동'), findsOneWidget);
    expect(find.byTooltip('화면 설정'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('병원'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('병원'), findsOneWidget);
    expect(find.text('사진 보내기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈의 모든 콘텐츠가 자유 연습 첫 단계로 이동한다', (tester) async {
    await pumpHome(tester);

    final destinations = <String, String>{
      '카페 주문': AppRoutes.cafeV2Menu,
      '병원': AppRoutes.hospitalStepOne,
      '사진 보내기': AppRoutes.photoStepOne,
      '기차표 예매': AppRoutes.trainV2TripType,
      '햄버거 주문': AppRoutes.hamburgerPractice,
      'ATM 출금': AppRoutes.atmV2Services,
      '무인민원발급기': AppRoutes.civilDocumentV2Categories,
    };

    for (final entry in destinations.entries) {
      appRouter.go(AppRoutes.home);
      await tester.pumpAndSettle();
      final card = find.text(entry.key);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(appRouter.state.uri.path, entry.value, reason: entry.key);
      expect(tester.takeException(), isNull, reason: entry.key);
    }

    appRouter.go(AppRoutes.home);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('화면 설정'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.accessibilitySettings);
  });

  testWidgets('기본 글씨의 넓은 화면에서도 연습을 읽기 쉬운 한 열로 표시한다', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final progress = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    final cafeCenter = tester.getCenter(find.text('카페 주문'));
    final burgerCenter = tester.getCenter(find.text('햄버거 주문'));
    expect(cafeCenter.dy, lessThan(burgerCenter.dy));
    expect(tester.takeException(), isNull);
  });
}
