import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/theme_model.dart';
import '../models/place_model.dart';
import '../models/related_work_model.dart';

/// JSON 데이터 로딩 및 캐싱 서비스 (싱글톤)
/// 앱 시작 시 initialize()를 한 번 호출하면 이후 모든 조회는 동기로 처리된다
class DataService {
  static final DataService instance = DataService._internal();
  DataService._internal();

  // 메모리 캐시
  List<ThemeModel> _themes = [];
  List<PlaceModel> _places = [];
  List<RelatedWorkModel> _relatedWorks = [];

  /// 앱 시작 시 한 번 호출 - assets의 모든 JSON 파일을 로드하고 파싱한다
  static Future<void> initialize() async {
    try {
      final themesJson = await rootBundle.loadString('data/themes.json');
      final placesJson = await rootBundle.loadString('data/places.json');
      final worksJson = await rootBundle.loadString('data/related_works.json');

      final themesData = json.decode(themesJson) as Map<String, dynamic>;
      final placesData = json.decode(placesJson) as Map<String, dynamic>;
      final worksData = json.decode(worksJson) as Map<String, dynamic>;

      instance._themes = (themesData['themes'] as List<dynamic>)
          .map((t) => ThemeModel.fromJson(t as Map<String, dynamic>))
          .toList();
      instance._places = (placesData['places'] as List<dynamic>)
          .map((p) => PlaceModel.fromJson(p as Map<String, dynamic>))
          .toList();
      instance._relatedWorks = (worksData['related_works'] as List<dynamic>)
          .map((w) => RelatedWorkModel.fromJson(w as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 로딩 실패 시 빈 리스트로 graceful degradation (크래시 방지)
      instance._themes = [];
      instance._places = [];
      instance._relatedWorks = [];
    }
  }

  /// 테스트용 데이터 직접 주입 (실제 앱에서는 사용 금지)
  static void loadForTesting({
    required List<ThemeModel> themes,
    required List<PlaceModel> places,
    required List<RelatedWorkModel> relatedWorks,
  }) {
    instance._themes = themes;
    instance._places = places;
    instance._relatedWorks = relatedWorks;
  }

  /// 전체 테마 목록 반환
  List<ThemeModel> getThemes() => List.unmodifiable(_themes);

  /// featured=true인 테마를 featuredOrder 순으로 반환
  List<ThemeModel> getFeaturedThemes() {
    final featured = _themes.where((t) => t.isFeatured).toList();
    featured.sort((a, b) => a.featuredOrder.compareTo(b.featuredOrder));
    return featured;
  }

  /// 특정 테마의 장소 목록을 order 순으로 반환
  List<PlaceModel> getPlacesByTheme(String themeId) {
    final places = _places.where((p) => p.themeId == themeId).toList();
    places.sort((a, b) => a.order.compareTo(b.order));
    return places;
  }

  /// 특정 테마와 연관된 작품 목록 반환
  List<RelatedWorkModel> getRelatedWorksByTheme(String themeId) {
    return _relatedWorks
        .where((w) => w.themeIds.contains(themeId))
        .toList();
  }

  /// 전체 관련 작품 목록 반환
  List<RelatedWorkModel> getAllRelatedWorks() =>
      List.unmodifiable(_relatedWorks);
}
