import 'package:flutter_test/flutter_test.dart';
import 'package:citystorymap/models/related_work_model.dart';

void main() {
  // RelatedWorkModel.fromJson 파싱 테스트
  group('RelatedWorkModel.fromJson', () {
    final sampleJson = {
      'id': 'moeyo-ken',
      'type': 'book',
      'title': '燃えよ剣',
      'title_ko': '타오르라 검이여',
      'creator': '시바 료타로',
      'creator_local': '司馬遼太郎',
      'year': 1964,
      'cover_emoji': '📖',
      'description': '히지카타 토시조의 시점으로 신선조의 흥망을 그린 역사 소설의 걸작',
      'external_url': 'https://www.amazon.co.jp/dp/4101152063',
      'theme_ids': ['shinsengumi'],
    };

    test('기본 필드 파싱', () {
      final work = RelatedWorkModel.fromJson(sampleJson);
      expect(work.id, 'moeyo-ken');
      expect(work.type, 'book');
      expect(work.title, '燃えよ剣');
      expect(work.titleKo, '타오르라 검이여');
      expect(work.year, 1964);
      expect(work.coverEmoji, '📖');
      expect(work.externalUrl, 'https://www.amazon.co.jp/dp/4101152063');
    });

    test('themeIds 리스트 파싱', () {
      final work = RelatedWorkModel.fromJson(sampleJson);
      expect(work.themeIds, ['shinsengumi']);
    });

    test('typeLabel - book → 소설', () {
      final work = RelatedWorkModel.fromJson(sampleJson);
      expect(work.typeLabel, '소설');
    });

    test('typeLabel - movie → 영화', () {
      final movieJson = Map<String, dynamic>.from(sampleJson)
        ..['type'] = 'movie';
      expect(RelatedWorkModel.fromJson(movieJson).typeLabel, '영화');
    });

    test('typeLabel - anime → 애니메이션', () {
      final animeJson = Map<String, dynamic>.from(sampleJson)
        ..['type'] = 'anime';
      expect(RelatedWorkModel.fromJson(animeJson).typeLabel, '애니메이션');
    });
  });
}
