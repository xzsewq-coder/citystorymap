import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citystorymap/models/theme_model.dart';

void main() {
  // ThemeModel.fromJson 파싱 테스트
  group('ThemeModel.fromJson', () {
    // 테스트용 샘플 JSON (themes.json 구조와 동일)
    final sampleJson = {
      'id': 'shinsengumi',
      'city_id': 'kyoto',
      'title': '신선조 협객의 교토',
      'category': '역사',
      'year': '1863-1869',
      'hook_text': '막부 말기, 교토를 지킨 검객들의 발자취를 따라 걷다',
      'description': '신선조는 에도 막부 말기에 교토의 치안을 담당했던 무장 집단이다.',
      'hero_gradient': ['#1a1a2e', '#16213e'],
      'place_count': 5,
      'is_featured': true,
      'featured_order': 1,
    };

    test('기본 필드 파싱', () {
      final theme = ThemeModel.fromJson(sampleJson);
      expect(theme.id, 'shinsengumi');
      expect(theme.cityId, 'kyoto');
      expect(theme.title, '신선조 협객의 교토');
      expect(theme.category, '역사');
      expect(theme.year, '1863-1869');
      expect(theme.placeCount, 5);
      expect(theme.isFeatured, true);
      expect(theme.featuredOrder, 1);
    });

    test('hex 색상을 Color로 변환', () {
      final theme = ThemeModel.fromJson(sampleJson);
      expect(theme.heroGradient.length, 2);
      expect(theme.heroGradient[0], const Color(0xFF1a1a2e));
      expect(theme.heroGradient[1], const Color(0xFF16213e));
    });
  });
}
