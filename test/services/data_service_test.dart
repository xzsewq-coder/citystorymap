import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:citystorymap/models/theme_model.dart';
import 'package:citystorymap/models/place_model.dart';
import 'package:citystorymap/models/related_work_model.dart';
import 'package:citystorymap/services/data_service.dart';

void main() {
  // 테스트용 더미 데이터
  final dummyThemes = [
    ThemeModel(
      id: 'shinsengumi', cityId: 'kyoto', title: '신선조',
      category: '역사', year: '1863', hookText: '훅', description: '설명',
      emoji: '⚔️',
      heroGradient: [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
      placeCount: 2, isFeatured: true, featuredOrder: 1,
    ),
    ThemeModel(
      id: 'kinkakuji-mishima', cityId: 'kyoto', title: '금각사',
      category: '소설', year: '1956', hookText: '훅2', description: '설명2',
      emoji: '🏯',
      heroGradient: [const Color(0xFF2d132c), const Color(0xFF801336)],
      placeCount: 1, isFeatured: true, featuredOrder: 2,
    ),
  ];

  final dummyPlaces = [
    PlaceModel(
      id: 'ikedaya', themeId: 'shinsengumi', name: '이케다야', emoji: '⚔️',
      district: '가와라마치', storyQuote: '인용문', detailStory: '상세',
      relatedPerson: '오키타', visitTip: '팁', tags: ['1864년'], order: 1,
      lat: 35.0, lng: 135.7,
    ),
    PlaceModel(
      id: 'mibu', themeId: 'shinsengumi', name: '미부', emoji: '🏯',
      district: '미부', storyQuote: '인용문2', detailStory: '상세2',
      relatedPerson: '곤도', visitTip: '팁2', tags: ['1863년'], order: 2,
      lat: 35.0, lng: 135.7,
    ),
    PlaceModel(
      id: 'kinkakuji', themeId: 'kinkakuji-mishima', name: '금각사', emoji: '🏯',
      district: '기타구', storyQuote: '인용문3', detailStory: '상세3',
      relatedPerson: '', visitTip: '팁3', tags: ['1950년대'], order: 1,
      lat: 35.0, lng: 135.7,
    ),
  ];

  final dummyWorks = [
    RelatedWorkModel(
      id: 'moeyo-ken', type: 'book', title: '燃えよ剣', titleKo: '타오르라 검이여',
      creator: '시바 료타로', year: 1964, coverEmoji: '📖', description: '설명',
      externalUrl: 'https://example.com', themeIds: ['shinsengumi'],
    ),
    RelatedWorkModel(
      id: 'kinkakuji-novel', type: 'book', title: '金閣寺', titleKo: '금각사',
      creator: '미시마 유키오', year: 1956, coverEmoji: '📖', description: '설명',
      externalUrl: 'https://example.com', themeIds: ['kinkakuji-mishima'],
    ),
  ];

  setUp(() {
    // 각 테스트 전 DataService에 더미 데이터 주입
    DataService.loadForTesting(
      themes: dummyThemes,
      places: dummyPlaces,
      relatedWorks: dummyWorks,
    );
  });

  group('DataService 조회 메서드', () {
    test('getThemes - 전체 테마 반환', () {
      expect(DataService.instance.getThemes().length, 2);
    });

    test('getFeaturedThemes - featured=true만 featuredOrder 순으로 반환', () {
      final featured = DataService.instance.getFeaturedThemes();
      expect(featured.length, 2);
      expect(featured[0].id, 'shinsengumi');   // order 1
      expect(featured[1].id, 'kinkakuji-mishima'); // order 2
    });

    test('getPlacesByTheme - 테마 ID로 필터링', () {
      final places = DataService.instance.getPlacesByTheme('shinsengumi');
      expect(places.length, 2);
      expect(places.every((p) => p.themeId == 'shinsengumi'), true);
    });

    test('getPlacesByTheme - order 순 정렬', () {
      final places = DataService.instance.getPlacesByTheme('shinsengumi');
      expect(places[0].order, 1);
      expect(places[1].order, 2);
    });

    test('getRelatedWorksByTheme - 테마 ID로 필터링', () {
      final works = DataService.instance.getRelatedWorksByTheme('shinsengumi');
      expect(works.length, 1);
      expect(works[0].id, 'moeyo-ken');
    });

    test('getAllRelatedWorks - 전체 작품 반환', () {
      expect(DataService.instance.getAllRelatedWorks().length, 2);
    });
  });
}
