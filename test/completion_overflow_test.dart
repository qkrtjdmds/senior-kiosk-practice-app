import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:han_geoleum_digital/app/app.dart';
import 'package:han_geoleum_digital/app/app_router.dart';
import 'package:han_geoleum_digital/app/app_routes.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';

void main() {
  testWidgets('좁은 화면과 아주 큰 글씨에서 모든 완료 화면이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final progress = LearningProgressProvider(preferences);
    await progress.setAccessibilityTextSize(AccessibilityTextSize.extraLarge);
    await progress.setScreenContrast(ScreenContrast.vivid);
    appRouter.go(AppRoutes.home);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: const HanGeoleumDigitalApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> verifyPage(String route) async {
      appRouter.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$route 완료 화면 오버플로우');
      appRouter.go(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$route 홈 이동 오버플로우');
    }

    progress.selectMode(CafeLearningMode.guided);
    await verifyPage(AppRoutes.cafeComplete);
    progress.selectHospitalMode(HospitalLearningMode.guided);
    await verifyPage(AppRoutes.hospitalComplete);
    progress.selectPhotoMode(PhotoLearningMode.guided);
    await verifyPage(AppRoutes.photoComplete);
    progress.selectTrainMode(TrainLearningMode.guided);
    await verifyPage(AppRoutes.trainComplete);
    progress.selectHamburgerMode(HamburgerLearningMode.guided);
    await verifyPage(AppRoutes.hamburgerComplete);
    await progress.startAtmLearning(AtmLearningMode.guided);
    await verifyPage(AppRoutes.atmComplete);
    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.guided);
    await verifyPage(AppRoutes.civilDocumentComplete);

    progress.selectMode(CafeLearningMode.solo);
    await verifyPage(AppRoutes.cafeComplete);
    progress.selectHospitalMode(HospitalLearningMode.solo);
    await verifyPage(AppRoutes.hospitalComplete);
    progress.selectPhotoMode(PhotoLearningMode.solo);
    await verifyPage(AppRoutes.photoComplete);
    progress.selectTrainMode(TrainLearningMode.solo);
    await verifyPage(AppRoutes.trainComplete);
    await progress.startHamburgerSoloMission();
    await verifyPage(AppRoutes.hamburgerComplete);
    await progress.startAtmLearning(AtmLearningMode.solo);
    await verifyPage(AppRoutes.atmComplete);
    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.solo);
    await verifyPage(AppRoutes.civilDocumentComplete);
  });
}
