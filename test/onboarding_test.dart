import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  Future<LearningProgressProvider> pumpOnboarding(
    WidgetTester tester, {
    Map<String, Object> values = const {},
  }) async {
    SharedPreferences.setMockInitialValues(values);
    final provider = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const HanGeoleumDigitalApp(enableOnboarding: true),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('최초 실행에서 시작 안내를 마치면 홈을 표시하고 상태를 저장한다', (tester) async {
    final provider = await pumpOnboarding(tester);
    expect(find.text('천천히, 한 걸음씩 연습해요'), findsOneWidget);
    await tester.tap(find.text('연습 시작하기'));
    await tester.pumpAndSettle();
    expect(provider.onboardingCompleted, isTrue);
    expect(find.text('오늘도 한 걸음씩 연습해요'), findsOneWidget);
  });

  testWidgets('글자 크기를 고르고 시작 안내를 다시 볼 수 있다', (tester) async {
    final provider = await pumpOnboarding(tester);
    await tester.tap(find.text('글자 크기 먼저 맞추기'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('아주 크게').last);
    await tester.tap(find.text('아주 크게').last);
    await tester.pumpAndSettle();
    expect(provider.accessibilityTextSize, AccessibilityTextSize.extraLarge);
    await provider.completeOnboarding();
    await provider.showOnboardingAgain();
    await tester.pumpAndSettle();
    expect(find.text('천천히, 한 걸음씩 연습해요'), findsOneWidget);
  });

  test('연습 기록 초기화 후에도 시작 안내 완료와 화면 설정은 유지된다', () async {
    SharedPreferences.setMockInitialValues({
      LearningProgressProvider.onboardingCompletedKey: true,
      'accessibility_text_size': 'large',
      'screen_contrast': 'vivid',
      'digital_confidence_points': 30,
    });
    final provider = LearningProgressProvider(
      await SharedPreferences.getInstance(),
    );
    await provider.resetPracticeRecords();
    expect(provider.onboardingCompleted, isTrue);
    expect(provider.accessibilityTextSize, AccessibilityTextSize.large);
    expect(provider.screenContrast, ScreenContrast.vivid);
    expect(provider.totalPoints, 0);
  });

  testWidgets('320dp 아주 큰 글씨에서도 시작 안내가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpOnboarding(
      tester,
      values: {'accessibility_text_size': 'extraLarge'},
    );

    expect(find.text('연습 시작하기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
