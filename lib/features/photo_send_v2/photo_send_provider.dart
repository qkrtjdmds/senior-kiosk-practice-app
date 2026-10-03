import 'package:flutter/foundation.dart';

import 'photo_send_models.dart';

class PhotoSendProvider extends ChangeNotifier {
  PhotoSendMode mode = PhotoSendMode.guided;
  bool isFreePractice = false;
  PhotoSendStep step = PhotoSendStep.recipient;
  PhotoSendScenario scenario = guidedPhotoScenario;
  PracticeContact? recipient;
  bool chatConfirmed = false;
  bool addPhotoOpened = false;
  PhotoPermissionChoice? permission;
  String? album;
  final List<String> selectedPhotoIds = [];
  bool previewConfirmed = false;
  bool reviewConfirmed = false;
  bool sending = false;
  bool sent = false;
  bool resultConfirmed = false;
  bool hintVisible = false;
  bool safetyExpanded = false;
  String? notice;
  bool _processing = false;

  bool get isSolo => mode == PhotoSendMode.solo;
  bool get canComplete => sent && resultConfirmed;
  List<PracticePhoto> get selectedPhotos =>
      selectedPhotoIds.map(photoById).toList(growable: false);
  List<PracticePhoto> photosForAlbum(String value) => practicePhotos
      .where((item) => item.album == value || value == '최근 사진')
      .toList(growable: false);

  void begin(PhotoSendMode value, {int completedCount = 0}) {
    mode = value;
    isFreePractice = false;
    scenario = value == PhotoSendMode.guided
        ? guidedPhotoScenario
        : soloPhotoScenarios[completedCount % soloPhotoScenarios.length];
    resetSession();
  }

  void beginFreePractice() {
    mode = PhotoSendMode.guided;
    isFreePractice = true;
    scenario = guidedPhotoScenario;
    resetSession();
  }

  void resetSession() {
    step = PhotoSendStep.recipient;
    recipient = null;
    chatConfirmed = false;
    addPhotoOpened = false;
    permission = null;
    album = null;
    selectedPhotoIds.clear();
    previewConfirmed = false;
    reviewConfirmed = false;
    sending = false;
    sent = false;
    resultConfirmed = false;
    hintVisible = false;
    safetyExpanded = false;
    notice = null;
    _processing = false;
    notifyListeners();
  }

  bool chooseRecipient(PracticeContact value) {
    if (!isFreePractice && value.id != scenario.contactId) {
      return _wrong('괜찮아요. 받을 사람의 이름과 관계를 다시 확인해 볼까요?');
    }
    recipient = value;
    _clearAfterRecipient();
    step = PhotoSendStep.chat;
    return _ok();
  }

  void confirmChat() {
    if (recipient == null) return;
    chatConfirmed = true;
    step = PhotoSendStep.addPhoto;
    _ok();
  }

  void openAddPhoto() {
    if (!chatConfirmed) return;
    addPhotoOpened = true;
    step = PhotoSendStep.permission;
    _ok();
  }

  bool choosePermission(PhotoPermissionChoice value) {
    if (value == PhotoPermissionChoice.denied) {
      permission = value;
      return _wrong('사진을 고르려면 사진 접근을 허용하는 연습을 해볼까요?');
    }
    if (!isFreePractice &&
        mode == PhotoSendMode.guided &&
        value != PhotoPermissionChoice.selectedOnly) {
      return _wrong('이번 연습에서는 필요한 사진만 허용해 볼까요?');
    }
    permission = value;
    _clearAfterPermission();
    step = PhotoSendStep.album;
    return _ok();
  }

  bool chooseAlbum(String value) {
    if (!isFreePractice && value != scenario.album) {
      return _wrong('괜찮아요. 오늘의 목표에 맞는 앨범을 다시 찾아볼까요?');
    }
    album = value;
    _clearAfterAlbum();
    step = PhotoSendStep.photos;
    return _ok();
  }

  bool togglePhoto(String id) {
    if (selectedPhotoIds.remove(id)) {
      _clearAfterPhotos();
      notifyListeners();
      return true;
    }
    if (selectedPhotoIds.length >= 3) {
      return _wrong('사진은 한 번에 최대 3장까지 선택할 수 있어요.');
    }
    final expectedIndex = selectedPhotoIds.length;
    if (!isFreePractice &&
        (expectedIndex >= scenario.photoIds.length ||
            scenario.photoIds[expectedIndex] != id)) {
      return _wrong('괜찮아요. 미션의 사진과 선택 순서를 다시 살펴볼까요?');
    }
    selectedPhotoIds.add(id);
    _clearAfterPhotos();
    return _ok();
  }

  bool finishPhotoSelection() {
    if (!isFreePractice && !listEquals(selectedPhotoIds, scenario.photoIds)) {
      return _wrong('선택한 사진과 순서를 한 번 더 확인해 주세요.');
    }
    step = PhotoSendStep.preview;
    return _ok();
  }

  void confirmPreview() {
    if (selectedPhotoIds.isEmpty) return;
    previewConfirmed = true;
    step = PhotoSendStep.review;
    _ok();
  }

  bool confirmReview() {
    if (!isFreePractice &&
        (recipient?.id != scenario.contactId ||
            !listEquals(selectedPhotoIds, scenario.photoIds))) {
      return _wrong('누구에게 어떤 사진을 보내는지 다시 확인해 주세요.');
    }
    reviewConfirmed = true;
    return _ok();
  }

  Future<bool> sendVirtually() async {
    if (_processing || !reviewConfirmed || sent) return false;
    _processing = true;
    sending = true;
    step = PhotoSendStep.sending;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    sending = false;
    sent = true;
    step = PhotoSendStep.result;
    _processing = false;
    notifyListeners();
    return true;
  }

  void confirmResult() {
    if (!sent) return;
    resultConfirmed = true;
    notifyListeners();
  }

  void toggleHint() {
    hintVisible = !hintVisible;
    notifyListeners();
  }

  void toggleSafety() {
    safetyExpanded = !safetyExpanded;
    notifyListeners();
  }

  void showNotice(String message) {
    notice = message;
    notifyListeners();
  }

  void goTo(PhotoSendStep value) {
    step = value;
    notice = null;
    notifyListeners();
  }

  void _clearAfterRecipient() {
    chatConfirmed = false;
    addPhotoOpened = false;
    permission = null;
    album = null;
    selectedPhotoIds.clear();
    _clearAfterPhotos();
  }

  void _clearAfterPermission() {
    album = null;
    selectedPhotoIds.clear();
    _clearAfterPhotos();
  }

  void _clearAfterAlbum() {
    selectedPhotoIds.clear();
    _clearAfterPhotos();
  }

  void _clearAfterPhotos() {
    previewConfirmed = false;
    reviewConfirmed = false;
    sending = false;
    sent = false;
    resultConfirmed = false;
    safetyExpanded = false;
  }

  bool _wrong(String message) {
    notice = message;
    notifyListeners();
    return false;
  }

  bool _ok() {
    notice = null;
    notifyListeners();
    return true;
  }
}
