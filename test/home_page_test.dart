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

    expect(find.text('오늘도 천천히 연습해볼까요?'), findsOneWidget);
    expect(find.text('편한 항목부터 하나씩 시작해보세요.'), findsOneWidget);
    expect(find.text('현재 30점'), findsOneWidget);
    expect(find.byTooltip('화면 설정'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('나의 디지털 걸음'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈의 모든 카드가 기존 화면으로 이동한다', (tester) async {
    await pumpHome(tester);

    final destinations = <String, String>{
      '카페 키오스크 연습': AppRoutes.cafeStart,
      '햄버거 주문 연습': AppRoutes.hamburgerStart,
      '병원 접수 연습': AppRoutes.hospitalStart,
      '사진 보내기 연습': AppRoutes.photoStart,
      '기차표 예매 연습': AppRoutes.trainStart,
      'ATM 출금 연습': AppRoutes.atmStart,
      '무인민원발급기 연습': AppRoutes.civilDocumentStart,
      '나의 디지털 걸음': AppRoutes.progress,
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
}
