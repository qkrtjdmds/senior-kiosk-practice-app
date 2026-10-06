import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:han_geoleum_digital/app/app_theme.dart';
import 'package:han_geoleum_digital/shared/widgets/practice_ui.dart';

void main() {
  Future<void> pumpPracticeUi(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    bool highContrast = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(highContrast: highContrast),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          appBar: PracticeAppBar(
            title: '무인민원발급기 연습',
            onBack: () {},
            step: 3,
            totalSteps: 11,
            stepName: '발급 내용을 선택해요',
          ),
          body: const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                PracticeModeBadge(label: '혼자 해보기'),
                SizedBox(height: AppSpacing.md),
                PracticeInlineNotice(message: '괜찮아요. 안내를 다시 살펴보고 천천히 선택해 보세요.'),
                SizedBox(height: AppSpacing.md),
                PracticeCompletionHeader(
                  title: '연습을 잘 마쳤어요!',
                  description: '오늘도 한 걸음 더 익혔어요.',
                ),
              ],
            ),
          ),
          bottomNavigationBar: PracticeBottomActions(
            child: FilledButton(onPressed: null, child: Text('다음 단계로 이동하기')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('320dp 아주 큰 글씨와 선명한 화면에서 공통 학습 UI가 넘치지 않는다', (tester) async {
    await pumpPracticeUi(
      tester,
      size: const Size(320, 780),
      textScale: 1.35,
      highContrast: true,
    );

    expect(find.text('무인민원발급기 연습'), findsOneWidget);
    expect(find.text('3 / 11 · 발급 내용을 선택해요'), findsOneWidget);
    expect(find.text('혼자 해보기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('공통 하단 동작 영역은 최소 버튼 높이와 안전 여백을 유지한다', (tester) async {
    await pumpPracticeUi(tester, size: const Size(360, 800), textScale: 1);

    final button = tester.getSize(find.byType(FilledButton));
    expect(button.height, greaterThanOrEqualTo(AppSizes.buttonHeight));
    expect(find.byTooltip('이전 화면으로 돌아가기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
