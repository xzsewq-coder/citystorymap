/// 장소 데이터 모델 (places.json 구조에 대응)
class PlaceModel {
  final String id;
  final String themeId;
  final String name;
  final String emoji;
  final String district;
  final String storyQuote;
  final String detailStory;
  final String relatedPerson;
  final String visitTip;
  final List<String> tags;
  final int order;
  final double lat;
  final double lng;

  const PlaceModel({
    required this.id,
    required this.themeId,
    required this.name,
    required this.emoji,
    required this.district,
    required this.storyQuote,
    required this.detailStory,
    required this.relatedPerson,
    required this.visitTip,
    required this.tags,
    required this.order,
    required this.lat,
    required this.lng,
  });

  /// JSON 맵에서 PlaceModel 생성
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String,
      themeId: json['theme_id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      district: json['district'] as String,
      storyQuote: json['story_quote'] as String,
      detailStory: json['detail_story'] as String,
      relatedPerson: json['related_person'] as String,
      visitTip: json['visit_tip'] as String,
      tags: (json['tags'] as List<dynamic>).map((t) => t as String).toList(),
      order: json['order'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
