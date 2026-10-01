import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:han_geoleum_digital/features/atm_v2/atm_kiosk_widgets.dart';
import 'package:han_geoleum_digital/features/atm_v2/atm_withdrawal_provider.dart';

void main() {
  testWidgets('Android 시스템 뒤로가기도 현재 단계 콜백을 사용한다', (tester) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AtmKioskScaffold(
          onBack: () => backCount++,
          child: const Text('현재 단계'),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(backCount, 1);
    expect(find.text('현재 단계'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('320dp와 아주 큰 글씨에서 PIN 키패드가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = AtmWithdrawalProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.35)),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: AtmPinPad(
                  length: 2,
                  onDigit: _noopDigit,
                  onRemove: _noop,
                  onClear: _noop,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.text('한 글자'), findsNothing);
    expect(find.text('전체'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('기본 글씨에서는 삭제 문구를 한 줄로 온전히 표시한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: AtmPinPad(
              length: 0,
              onDigit: _noopDigit,
              onRemove: _noop,
              onClear: _noop,
            ),
          ),
        ),
      ),
    );
    expect(find.text('한 글자'), findsOneWidget);
    expect(find.text('전체'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
void _noopDigit(String _) {}
