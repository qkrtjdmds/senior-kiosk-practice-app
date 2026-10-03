import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_models.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_provider.dart';

void main() {
  group('사진 보내기 V2 Provider', () {
    test('따라 해보기는 목표 연락처와 사진만 순서대로 진행한다', () {
      final p = PhotoSendProvider()..begin(PhotoSendMode.guided);
      expect(p.chooseRecipient(contactById('son')), isFalse);
      expect(p.step, PhotoSendStep.recipient);
      expect(p.chooseRecipient(contactById('daughter')), isTrue);
      p.confirmChat();
      p.openAddPhoto();
      expect(p.choosePermission(PhotoPermissionChoice.allPhotos), isFalse);
      expect(p.choosePermission(PhotoPermissionChoice.selectedOnly), isTrue);
      expect(p.chooseAlbum('음식'), isFalse);
      expect(p.chooseAlbum('꽃과 풍경'), isTrue);
      expect(p.togglePhoto('yellow_flower'), isFalse);
      expect(p.togglePhoto('red_flower'), isTrue);
      expect(p.finishPhotoSelection(), isTrue);
    });

    test('사진 선택과 취소는 순서를 유지하고 최대 3장을 넘지 않는다', () {
      final p = PhotoSendProvider()
        ..begin(PhotoSendMode.solo, completedCount: 2);
      p.chooseRecipient(contactById('family'));
      p.confirmChat();
      p.openAddPhoto();
      p.choosePermission(PhotoPermissionChoice.selectedOnly);
      p.chooseAlbum('가족 나들이');
      for (final id in ['beach', 'walk', 'sky']) {
        expect(p.togglePhoto(id), isTrue);
      }
      expect(p.selectedPhotoIds, ['beach', 'walk', 'sky']);
      expect(p.togglePhoto('dog_drawing'), isFalse);
      expect(p.selectedPhotoIds.length, 3);
      expect(p.togglePhoto('walk'), isTrue);
      expect(p.selectedPhotoIds, ['beach', 'sky']);
    });

    test('받는 사람과 앨범 변경은 이후 상태만 초기화한다', () {
      final p = PhotoSendProvider()..begin(PhotoSendMode.guided);
      p.chooseRecipient(contactById('daughter'));
      p.confirmChat();
      p.openAddPhoto();
      p.choosePermission(PhotoPermissionChoice.selectedOnly);
      p.chooseAlbum('꽃과 풍경');
      p.togglePhoto('red_flower');
      p.chooseAlbum('꽃과 풍경');
      expect(p.selectedPhotoIds, isEmpty);
      p.togglePhoto('red_flower');
      p.chooseRecipient(contactById('daughter'));
      expect(p.permission, isNull);
      expect(p.album, isNull);
      expect(p.selectedPhotoIds, isEmpty);
    });

    test('가상 전송은 빠른 중복 요청에도 한 번만 완료한다', () async {
      final p = PhotoSendProvider()..begin(PhotoSendMode.guided);
      p.chooseRecipient(contactById('daughter'));
      p.confirmChat();
      p.openAddPhoto();
      p.choosePermission(PhotoPermissionChoice.selectedOnly);
      p.chooseAlbum('꽃과 풍경');
      p.togglePhoto('red_flower');
      p.finishPhotoSelection();
      p.confirmPreview();
      expect(p.confirmReview(), isTrue);
      final first = p.sendVirtually();
      final second = p.sendVirtually();
      expect(await second, isFalse);
      expect(await first, isTrue);
      expect(p.sent, isTrue);
      p.confirmResult();
      expect(p.canComplete, isTrue);
    });

    test('혼자 해보기 세 시나리오는 완료 횟수에 따라 순환한다', () {
      final p = PhotoSendProvider();
      for (var index = 0; index < 3; index++) {
        p.begin(PhotoSendMode.solo, completedCount: index);
        expect(p.scenario, same(soloPhotoScenarios[index]));
      }
      p.begin(PhotoSendMode.solo, completedCount: 3);
      expect(p.scenario, same(soloPhotoScenarios.first));
    });

    test('새 연습은 권한과 사진 및 전송 상태를 메모리에서 제거한다', () async {
      final p = PhotoSendProvider()..begin(PhotoSendMode.guided);
      p.chooseRecipient(contactById('daughter'));
      p.confirmChat();
      p.openAddPhoto();
      p.choosePermission(PhotoPermissionChoice.selectedOnly);
      p.chooseAlbum('꽃과 풍경');
      p.togglePhoto('red_flower');
      p.finishPhotoSelection();
      p.confirmPreview();
      p.confirmReview();
      await p.sendVirtually();
      p.resetSession();
      expect(p.recipient, isNull);
      expect(p.permission, isNull);
      expect(p.selectedPhotoIds, isEmpty);
      expect(p.sent, isFalse);
    });
  });
}
