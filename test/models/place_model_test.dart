import 'package:flutter_test/flutter_test.dart';
import 'package:citystorymap/models/place_model.dart';

void main() {
  // PlaceModel.fromJson 파싱 테스트
  group('PlaceModel.fromJson', () {
    final sampleJson = {
      'id': 'ikedaya',
      'theme_id': 'shinsengumi',
      'name': '이케다야 터',
      'name_en': 'Ikedaya Site',
      'name_local': '池田屋跡',
      'emoji': '⚔️',
      'district': '가와라마치',
      'district_local': '河原町',
      'story_quote': '1864년 음력 6월 5일, 신선조는 이곳에서 존왕양이파 지사들을 급습했다.',
      'detail_story': '당시 여관이었던 이케다야에 모인 조슈번과 도사번의 지사 약 30명을 신선조 대원 10여 명이 급습했다.',
      'related_person': '오키타 소우지, 나가쿠라 신파치',
      'visit_tip': '현재는 이자카야가 들어서 있어 식사하며 역사를 느낄 수 있다',
      'tags': ['1864년', '전투지', '막부말기'],
      'order': 1,
      'lat': 35.0094,
      'lng': 135.7688,
    };

    test('기본 필드 파싱', () {
      final place = PlaceModel.fromJson(sampleJson);
      expect(place.id, 'ikedaya');
      expect(place.themeId, 'shinsengumi');
      expect(place.name, '이케다야 터');
      expect(place.emoji, '⚔️');
      expect(place.district, '가와라마치');
      expect(place.order, 1);
    });

    test('tags 리스트 파싱', () {
      final place = PlaceModel.fromJson(sampleJson);
      expect(place.tags, ['1864년', '전투지', '막부말기']);
    });

    test('좌표 파싱 (double)', () {
      final place = PlaceModel.fromJson(sampleJson);
      expect(place.lat, 35.0094);
      expect(place.lng, 135.7688);
    });
  });
}
