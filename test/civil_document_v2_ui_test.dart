import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_models.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_provider.dart';
import 'package:han_geoleum_digital/features/civil_document_v2/civil_document_widgets.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('320dp 아주 큰 글씨에서 분야 목록과 하단 버튼이 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = CivilDocumentV2Provider()
      ..begin(CivilDocumentV2Mode.guided);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
            child: CivilKioskScaffold(
              step: 1,
              onBack: () {},
              bottom: civilPrimaryButton('다음', null),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const CivilQuestion('어떤 분야의 증명서가 필요한가요?'),
                  const SizedBox(height: 12),
                  for (final category in CivilDocumentCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CivilChoiceRow(
                        label: category.name,
                        subtitle: '증명서 연습 항목',
                        icon: civilCategoryIcon(category),
                        onTap: () {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('어떤 분야의 증명서가 필요한가요?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('시스템 뒤로가기도 공통 콜백을 사용한다', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CivilKioskScaffold(
          onBack: () => count++,
          child: const Text('현재 화면'),
        ),
      ),
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(count, 1);
    expect(find.text('현재 화면'), findsOneWidget);
  });
}
