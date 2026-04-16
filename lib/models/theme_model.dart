import 'package:flutter/material.dart';

/// 테마 데이터 모델 (themes.json 구조에 대응)
class ThemeModel {
  final String id;
  final String cityId;
  final String title;
  final String category;
  final String year;
  final String hookText;
  final String description;
  final List<Color> heroGradient; // hex 문자열 → Color 변환됨
  final int placeCount;
  final bool isFeatured;
  final int featuredOrder;

  const ThemeModel({
    required this.id,
    required this.cityId,
    required this.title,
    required this.category,
    required this.year,
    required this.hookText,
    required this.description,
    required this.heroGradient,
    required this.placeCount,
    required this.isFeatured,
    required this.featuredOrder,
  });

  /// JSON 맵에서 ThemeModel 생성
  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] as String,
      cityId: json['city_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      year: json['year'] as String,
      hookText: json['hook_text'] as String,
      description: json['description'] as String,
      heroGradient: (json['hero_gradient'] as List<dynamic>)
          .map((hex) => _hexToColor(hex as String))
          .toList(),
      placeCount: json['place_count'] as int,
      isFeatured: json['is_featured'] as bool,
      featuredOrder: json['featured_order'] as int,
    );
  }

  /// hex 색상 문자열을 Color로 변환 (#1a1a2e → Color(0xFF1a1a2e))
  /// 잘못된 형식이면 검은색으로 폴백하고 디버그 어설션 발생
  static Color _hexToColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      assert(false, 'themes.json에 잘못된 hex 색상값이 있습니다: $hex');
      return const Color(0xFF000000); // 폴백 색상
    }
  }
}
