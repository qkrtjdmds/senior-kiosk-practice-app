import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/atm_v2/atm_withdrawal_provider.dart';
import 'package:han_geoleum_digital/features/cafe_v2/cafe_order_provider.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_provider.dart';
import 'package:han_geoleum_digital/features/hamburger_v2/burger_order_provider.dart';
import 'package:han_geoleum_digital/features/hospital_v2/hospital_reception_provider.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_models.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_provider.dart';
import 'package:han_geoleum_digital/features/train_v2/train_booking_provider.dart';

void main() {
  group('자유 연습 모드', () {
    test('7개 V2 Provider가 자유 연습 상태로 새 세션을 시작한다', () {
      final cafe = CafeOrderProvider()..startFreePractice();
      final burger = BurgerOrderProvider()..beginFreePractice();
      final hospital = HospitalReceptionProvider()..beginFreePractice();
      final train = TrainBookingProvider()..beginFreePractice();
      final atm = AtmWithdrawalProvider()..beginFreePractice();
      final civil = CivilDocumentV2Provider()..beginFreePractice();
      final photo = PhotoSendProvider()..beginFreePractice();

      expect(cafe.isFreePractice, isTrue);
      expect(burger.isFreePractice, isTrue);
      expect(hospital.isFreePractice, isTrue);
      expect(train.isFreePractice, isTrue);
      expect(atm.isFreePractice, isTrue);
      expect(civil.isFreePractice, isTrue);
      expect(photo.isFreePractice, isTrue);
    });

    test('카페와 햄버거는 시나리오와 다른 정상 선택도 허용한다', () {
      final cafe = CafeOrderProvider()..startFreePractice();
      final latte = cafeMenuItems.firstWhere((item) => item.id == 'cafe_latte');
      expect(cafe.selectMenu(latte), isTrue);
      expect(cafe.selectTemperature(CafeTemperature.hot), isTrue);
      expect(cafe.selectSize(CafeSize.large), isTrue);
      expect(cafe.selectDineOption(CafeDineOption.dineIn), isTrue);

      final burger = BurgerOrderProvider()..beginFreePractice();
      burger.chooseDine('매장', correct: false);
      expect(burger.dineOption, '매장');
      burger.chooseMenu(BurgerOrderProvider.menus.last, correct: false);
      expect(burger.selectedMenu, BurgerOrderProvider.menus.last);
    });

    test('병원 접수와 사진 보내기는 목표가 아닌 정상 선택을 허용한다', () {
      final hospital = HospitalReceptionProvider()..beginFreePractice();
      hospital.chooseVisit('처음 방문이에요');
      expect(hospital.visit, '처음 방문이에요');

      final photo = PhotoSendProvider()..beginFreePractice();
      expect(photo.chooseRecipient(contactById('son')), isTrue);
      photo.confirmChat();
      photo.openAddPhoto();
      expect(photo.choosePermission(PhotoPermissionChoice.allPhotos), isTrue);
      expect(photo.chooseAlbum('최근 사진'), isTrue);
      expect(photo.togglePhoto('dog_drawing'), isTrue);
      expect(photo.finishPhotoSelection(), isTrue);
    });

    test('사진 자유 연습도 최대 3장 안전 제한은 유지한다', () {
      final photo = PhotoSendProvider()..beginFreePractice();
      photo.chooseRecipient(contactById('family'));
      photo.confirmChat();
      photo.openAddPhoto();
      photo.choosePermission(PhotoPermissionChoice.allPhotos);
      photo.chooseAlbum('최근 사진');
      expect(photo.togglePhoto('red_flower'), isTrue);
      expect(photo.togglePhoto('yellow_flower'), isTrue);
      expect(photo.togglePhoto('beach'), isTrue);
      expect(photo.togglePhoto('walk'), isFalse);
      expect(photo.selectedPhotoIds.length, 3);
    });
  });
}
