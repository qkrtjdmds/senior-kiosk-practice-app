import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:han_geoleum_digital/features/train_v2/train_booking_widgets.dart';

void main() {
  testWidgets('320dp 아주 큰 글씨에서 객차 선택이 2열로 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(640, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.33)),
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(20),
              child: TrainSegmentControl<int>(
                options: [
                  TrainSegmentOption(value: 1, label: '1호차'),
                  TrainSegmentOption(value: 2, label: '2호차'),
                  TrainSegmentOption(value: 3, label: '3호차'),
                  TrainSegmentOption(value: 4, label: '4호차'),
                ],
                selected: 1,
                onSelected: _ignoreSelection,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('1호차'), findsOneWidget);
    expect(find.text('4호차'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignoreSelection(int _) {}
