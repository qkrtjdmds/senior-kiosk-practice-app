import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_models.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_provider.dart';
import 'package:han_geoleum_digital/features/photo_send_v2/photo_send_v2_pages.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('320dp 아주 큰 글씨에서 연락처 목록이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = PhotoSendProvider()..begin(PhotoSendMode.guided);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.35)),
          child: child!,
        ),
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const PhotoSendV2FlowPage(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('딸 김하늘'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('사진 격자는 320dp에서 2열과 선택 번호를 표시한다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = PhotoSendProvider()..begin(PhotoSendMode.guided);
    provider
      ..chooseRecipient(contactById('daughter'))
      ..confirmChat()
      ..openAddPhoto()
      ..choosePermission(PhotoPermissionChoice.selectedOnly)
      ..chooseAlbum('꽃과 풍경')
      ..togglePhoto('red_flower');
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const PhotoSendV2FlowPage(),
        ),
      ),
    );
    expect(find.text('빨간 꽃'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
