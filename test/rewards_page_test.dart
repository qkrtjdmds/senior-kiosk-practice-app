import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/core/data_migration/preference_keys.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:han_geoleum_digital/features/rewards/reward_repository.dart';
import 'package:han_geoleum_digital/features/rewards/reward_unlock_service.dart';
import 'package:han_geoleum_digital/shared/widgets/han_geoleum_character.dart';

void main() {
  Future<SharedPreferences> pumpRewardsApp(
    WidgetTester tester, {
    required int points,
    String route = AppRoutes.home,
    Size size = const Size(360, 760),
    bool extraLarge = false,
    String? selectedTitleId,
    Set<String> selectedAccessoryIds = const {},
    String? selectedThemeId,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      V2PreferenceKeys.points: points,
      if (extraLarge) V2PreferenceKeys.accessibilityTextSize: 'extraLarge',
      if (extraLarge) V2PreferenceKeys.screenContrast: 'vivid',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = RewardRepository(preferences);
    await RewardUnlockService(repository).reconcile(points);
    if (selectedTitleId != null) {
      await repository.selectTitle(selectedTitleId);
    }
    if (selectedAccessoryIds.isNotEmpty) {
      await repository.selectAccessories(selectedAccessoryIds);
    }
    if (selectedThemeId != null) {
      await repository.selectTheme(selectedThemeId);
    }
    final progress = LearningProgressProvider(preferences);
    appRouter.go(route);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();
    return preferences;
  }

  testWidgets('홈은 160점 진행 요약을 표시하고 나의 보상으로 이동한다', (tester) async {
    final preferences = await pumpRewardsApp(tester, points: 160);

    expect(find.text('현재 연습 포인트'), findsOneWidget);
    expect(find.text('160점'), findsOneWidget);
    expect(find.text('다음 보상: 한걸음이 목도리'), findsOneWidget);
    expect(find.text('140점 더 모으면 받을 수 있어요.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('다음 보상 300점까지 160점.*140점 남음')),
      findsOneWidget,
    );

    final rewardsAction = find.text('나의 보상 보기');
    await tester.ensureVisible(rewardsAction);
    await tester.tap(rewardsAction);
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.rewards);
    expect(find.text('전체 보상 1 / 12'), findsOneWidget);
    expect(find.text('적용하기'), findsNothing);
    expect(
      (await RewardRepository(preferences).load()).celebratedRewardIds,
      isEmpty,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.home);
  });

  testWidgets('내 정보는 기존 배지와 구분된 보상 요약에서 전체 목록으로 이동한다', (tester) async {
    await pumpRewardsApp(tester, points: 100, route: AppRoutes.progress);

    expect(find.text('나의 보상'), findsOneWidget);
    expect(find.text('배지'), findsOneWidget);
    final action = find.text('전체 보상 보기');
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, AppRoutes.rewards);
    expect(find.text('전체 보상 1 / 12'), findsOneWidget);
  });

  testWidgets('보상 목록은 획득·미획득·적용 상태를 한 번씩 읽는다', (tester) async {
    await pumpRewardsApp(
      tester,
      points: 160,
      route: AppRoutes.rewards,
      selectedTitleId: 'title_first_step',
    );

    final applied = tester.getSemantics(
      find.bySemanticsLabel(RegExp('첫걸음 시작.*적용 중')),
    );
    expect(applied.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    // ignore: deprecated_member_use
    expect(applied.getSemanticsData().hasFlag(SemanticsFlag.isSelected), isTrue);
    expect(
      find.bySemanticsLabel(RegExp('한걸음이 목도리.*140점 더 필요')),
      findsOneWidget,
    );
    expect(find.text('적용 중'), findsOneWidget);
    expect(find.text('적용하기'), findsNothing);
    expect(find.text('구매'), findsNothing);
  });

  testWidgets('5000점은 전체 보상과 마지막 항목까지 표시한다', (tester) async {
    await pumpRewardsApp(tester, points: 5000, route: AppRoutes.rewards);

    expect(find.text('모든 성장 보상을 획득했어요'), findsOneWidget);
    expect(find.text('전체 보상 12 / 12'), findsOneWidget);
    final lastReward = find.text('특별 축하 표정');
    await tester.scrollUntilVisible(
      lastReward,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(lastReward, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320dp 아주 큰 글씨에서 보상 목록과 뒤로가기가 안전하다', (tester) async {
    await pumpRewardsApp(
      tester,
      points: 1600,
      route: AppRoutes.home,
      size: const Size(320, 700),
      extraLarge: true,
    );

    final action = find.text('나의 보상 보기');
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.rewards);
    expect(tester.takeException(), isNull);

    final lastReward = find.text('특별 축하 표정');
    await tester.scrollUntilVisible(
      lastReward,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(lastReward, findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('이전 화면으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, AppRoutes.home);
  });

  testWidgets('보상 화면에서 칭호 장식 테마를 선택하고 미리보기에 반영한다', (tester) async {
    await pumpRewardsApp(tester, points: 5000, route: AppRoutes.rewards);

    expect(find.byKey(const Key('reward-preview')), findsOneWidget);
    await tester.ensureVisible(find.text('첫걸음 시작').last);
    await tester.tap(find.text('첫걸음 시작').last);
    await tester.pumpAndSettle();
    expect(find.text('칭호를 바꿨어요'), findsOneWidget);

    await tester.ensureVisible(find.text('한걸음이 목도리').last);
    await tester.tap(find.text('한걸음이 목도리').last);
    await tester.pumpAndSettle();
    expect(find.text('목도리를 착용했어요'), findsOneWidget);

    await tester.ensureVisible(find.text('편안한 세이지').last);
    await tester.tap(find.text('편안한 세이지').last);
    await tester.pumpAndSettle();
    expect(find.text('홈 테마를 바꿨어요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('잠긴 보상과 특별 표현에는 탭 동작이 없다', (tester) async {
    await pumpRewardsApp(tester, points: 160, route: AppRoutes.rewards);

    final locked = tester.getSemantics(
      find.bySemanticsLabel(RegExp('한걸음이 목도리.*140점 더 필요')),
    );
    expect(locked.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    final expression = tester.getSemantics(
      find.bySemanticsLabel(RegExp('특별 축하 표정')),
    );
    expect(
      expression.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
  });

  testWidgets('홈은 선택한 칭호 장식 테마를 복원해 표시한다', (tester) async {
    await pumpRewardsApp(
      tester,
      points: 1600,
      selectedTitleId: 'title_steady_learner',
      selectedAccessoryIds: const {
        'accessory_scarf',
        'accessory_hat',
        'accessory_glasses',
      },
      selectedThemeId: 'theme_sky',
    );

    expect(find.text('나의 칭호 · 꾸준한 연습생'), findsOneWidget);
    expect(find.byType(HanGeoleumCharacter), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
