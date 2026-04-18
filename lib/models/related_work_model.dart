/// 관련 작품 데이터 모델 (related_works.json 구조에 대응)
class RelatedWorkModel {
  final String id;
  final String type; // 'book' | 'movie' | 'anime'
  final String title;
  final String titleKo;
  final String creator;
  final int year;
  final String coverEmoji;
  final String description;
  final String externalUrl;
  final List<String> themeIds;

  const RelatedWorkModel({
    required this.id,
    required this.type,
    required this.title,
    required this.titleKo,
    required this.creator,
    required this.year,
    required this.coverEmoji,
    required this.description,
    required this.externalUrl,
    required this.themeIds,
  });

  /// JSON 맵에서 RelatedWorkModel 생성
  factory RelatedWorkModel.fromJson(Map<String, dynamic> json) {
    return RelatedWorkModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      titleKo: json['title_ko'] as String,
      creator: json['creator'] as String,
      year: json['year'] as int,
      coverEmoji: json['cover_emoji'] as String,
      description: json['description'] as String,
      externalUrl: json['external_url'] as String,
      themeIds: (json['theme_ids'] as List<dynamic>)
          .map((id) => id as String)
          .toList(),
    );
  }

  /// type을 한국어 라벨로 변환 (카테고리 필터용)
  String get typeLabel {
    switch (type) {
      case 'book':
        return '소설';
      case 'movie':
        return '영화';
      case 'drama':
        return '드라마';
      case 'anime':
        return '애니메이션';
      default:
        return type;
    }
  }
}
