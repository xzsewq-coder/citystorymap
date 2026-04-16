// CityStoryMap 앱 기본 위젯 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citystorymap/main.dart';

void main() {
  testWidgets('앱이 정상적으로 로드되는지 테스트', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(const CityStoryMapApp());

    // 하단 탭 바가 존재하는지 확인
    expect(find.text('스토리'), findsOneWidget);
    expect(find.text('지도'), findsOneWidget);
    expect(find.text('라이브러리'), findsOneWidget);

    // 홈 화면 타이틀이 보이는지 확인
    expect(find.text('CityStoryMap'), findsOneWidget);
  });
}
