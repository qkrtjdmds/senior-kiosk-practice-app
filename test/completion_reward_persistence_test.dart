import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/learning/learning_progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LearningProgressProvider> provider() async {
    return LearningProgressProvider(await SharedPreferences.getInstance());
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('따라 해보기 완료 보상은 Provider가 다시 만들어져도 한 번만 지급된다', () async {
    var progress = await provider();

    progress.selectMode(CafeLearningMode.guided);
    await progress.completeCafeLearning();
    progress = await provider();
    expect(progress.mode, CafeLearningMode.guided);
    await progress.completeCafeLearning();
    expect(progress.totalPoints, 10);
    expect(progress.guidedCompletionCount, 1);

    progress.selectHospitalMode(HospitalLearningMode.guided);
    await progress.completeHospitalLearning();
    progress = await provider();
    expect(progress.hospitalMode, HospitalLearningMode.guided);
    await progress.completeHospitalLearning();
    expect(progress.totalPoints, 20);
    expect(progress.hospitalCompletionCount, 1);

    progress.selectPhotoMode(PhotoLearningMode.guided);
    await progress.completePhotoLearning();
    progress = await provider();
    expect(progress.photoMode, PhotoLearningMode.guided);
    await progress.completePhotoLearning();
    expect(progress.totalPoints, 30);
    expect(progress.photoCompletionCount, 1);

    progress.selectTrainMode(TrainLearningMode.guided);
    await progress.completeTrainLearning();
    progress = await provider();
    expect(progress.trainMode, TrainLearningMode.guided);
    await progress.completeTrainLearning();
    expect(progress.totalPoints, 40);
    expect(progress.trainCompletionCount, 1);

    progress.selectHamburgerMode(HamburgerLearningMode.guided);
    await progress.completeHamburgerLearning();
    progress = await provider();
    await progress.completeHamburgerLearning();
    expect(progress.totalPoints, 50);
    expect(progress.hamburgerCompletionCount, 1);

    await progress.startAtmLearning();
    await progress.completeAtmLearning();
    progress = await provider();
    await progress.completeAtmLearning();
    expect(progress.totalPoints, 60);
    expect(progress.atmCompletionCount, 1);

    await progress.startCivilDocumentLearning();
    await progress.completeCivilDocumentLearning();
    progress = await provider();
    await progress.completeCivilDocumentLearning();
    expect(progress.totalPoints, 70);
    expect(progress.civilDocumentCompletionCount, 1);
    expect(progress.recentPracticeRecords, hasLength(7));
  });

  test('혼자 해보기 완료 보상과 첫 배지는 재진입해도 중복 지급되지 않는다', () async {
    var progress = await provider();

    progress.selectMode(CafeLearningMode.solo);
    expect(await progress.completeCafeLearning(), isTrue);
    progress = await provider();
    expect(progress.isSoloMode, isTrue);
    expect(await progress.completeCafeLearning(), isFalse);

    progress.selectHospitalMode(HospitalLearningMode.solo);
    expect(await progress.completeHospitalSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isHospitalSoloMode, isTrue);
    expect(await progress.completeHospitalSoloLearning(), isFalse);

    progress.selectPhotoMode(PhotoLearningMode.solo);
    expect(await progress.completePhotoSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isPhotoSoloMode, isTrue);
    expect(await progress.completePhotoSoloLearning(), isFalse);

    progress.selectTrainMode(TrainLearningMode.solo);
    expect(await progress.completeTrainSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isTrainSoloMode, isTrue);
    expect(await progress.completeTrainSoloLearning(), isFalse);

    await progress.startHamburgerSoloMission();
    expect(await progress.completeHamburgerSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isHamburgerSoloMode, isTrue);
    expect(await progress.completeHamburgerSoloLearning(), isFalse);

    await progress.startAtmLearning(AtmLearningMode.solo);
    expect(await progress.completeAtmSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isAtmSoloMode, isTrue);
    expect(await progress.completeAtmSoloLearning(), isFalse);

    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.solo);
    expect(await progress.completeCivilDocumentSoloLearning(), isTrue);
    progress = await provider();
    expect(progress.isCivilDocumentSoloMode, isTrue);
    expect(await progress.completeCivilDocumentSoloLearning(), isFalse);

    expect(progress.totalPoints, 140);
    expect(progress.soloCompletionCount, 1);
    expect(progress.hospitalSoloCompletionCount, 1);
    expect(progress.photoSoloCompletionCount, 1);
    expect(progress.trainSoloCompletionCount, 1);
    expect(progress.hamburgerSoloCompletionCount, 1);
    expect(progress.atmSoloCompletionCount, 1);
    expect(progress.civilDocumentSoloCompletionCount, 1);
    expect(progress.recentPracticeRecords, hasLength(7));
  });
}
