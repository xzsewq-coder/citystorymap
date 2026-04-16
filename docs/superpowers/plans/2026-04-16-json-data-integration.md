# JSON 데이터 연동 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 하드코딩된 샘플 데이터를 제거하고 `data/*.json` 파일에서 실제 데이터를 로드하는 DataService 싱글톤을 구축하며, 라이브러리 외부 링크를 활성화한다.

**Architecture:** DataService 싱글톤이 앱 시작 시 3개 JSON을 한 번 로드해 메모리에 캐싱한다. 각 화면은 동기 메서드로 데이터를 요청한다. 모델 클래스는 `fromJson` 팩토리와 함께 `lib/models/`에 분리한다.

**Tech Stack:** Flutter, Dart, `flutter/services.dart` (rootBundle), `url_launcher: ^6.3.0`

---

## 파일 맵

| 작업 | 파일 | 내용 |
|------|------|------|
| 생성 | `lib/models/theme_model.dart` | ThemeModel + fromJson + hex→Color |
| 생성 | `lib/models/place_model.dart` | PlaceModel + fromJson |
| 생성 | `lib/models/related_work_model.dart` | RelatedWorkModel + fromJson + typeLabel |
| 생성 | `lib/services/data_service.dart` | 싱글톤, JSON 로딩, 5개 조회 메서드 |
| 생성 | `test/models/theme_model_test.dart` | ThemeModel.fromJson 단위 테스트 |
| 생성 | `test/models/place_model_test.dart` | PlaceModel.fromJson 단위 테스트 |
| 생성 | `test/models/related_work_model_test.dart` | RelatedWorkModel.fromJson 단위 테스트 |
| 생성 | `test/services/data_service_test.dart` | DataService 필터링 로직 단위 테스트 |
| 수정 | `pubspec.yaml` | assets 경로 + url_launcher 추가 |
| 수정 | `lib/main.dart` | DataService.initialize() 호출 |
| 수정 | `lib/screens/home_screen.dart` | 하드코딩 제거, DataService 사용 |
| 수정 | `lib/screens/theme_detail_screen.dart` | 하드코딩 제거, DataService 사용 |
| 수정 | `lib/screens/library_screen.dart` | 하드코딩 제거, DataService + url_launcher |
| 수정 | `android/app/src/main/AndroidManifest.xml` | url_launcher용 queries 블록 추가 |

---

## Task 1: pubspec.yaml 환경 설정

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: pubspec.yaml 수정**

`dependencies:` 블록과 `flutter:` 블록을 아래와 같이 수정한다:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  url_launcher: ^6.3.0        # 외부 링크 열기

flutter:
  uses-material-design: true
  assets:
    - data/themes.json
    - data/places.json
    - data/related_works.json
```

- [ ] **Step 2: 패키지 설치**

```bash
flutter pub get
```

Expected output (마지막 줄):
```
Got dependencies!
```

- [ ] **Step 3: 커밋**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: url_launcher 추가 및 data assets 경로 등록"
```

---

## Task 2: ThemeModel 생성 (TDD)

**Files:**
- Create: `lib/models/theme_model.dart`
- Create: `test/models/theme_model_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/models/theme_model_test.dart` 생성:

```dart
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
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
flutter test test/models/theme_model_test.dart
```

Expected: `Error: Cannot find 'package:citystorymap/models/theme_model.dart'`

- [ ] **Step 3: ThemeModel 구현**

`lib/models/theme_model.dart` 생성:

```dart
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
  static Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
```

- [ ] **Step 4: 테스트 재실행 → 통과 확인**

```bash
flutter test test/models/theme_model_test.dart
```

Expected:
```
00:01 +2: All tests passed!
```

- [ ] **Step 5: 커밋**

```bash
git add lib/models/theme_model.dart test/models/theme_model_test.dart
git commit -m "feat: ThemeModel 생성 (fromJson + hex→Color 변환)"
```

---

## Task 3: PlaceModel 생성 (TDD)

**Files:**
- Create: `lib/models/place_model.dart`
- Create: `test/models/place_model_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/models/place_model_test.dart` 생성:

```dart
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
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
flutter test test/models/place_model_test.dart
```

Expected: `Error: Cannot find 'package:citystorymap/models/place_model.dart'`

- [ ] **Step 3: PlaceModel 구현**

`lib/models/place_model.dart` 생성:

```dart
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
```

- [ ] **Step 4: 테스트 재실행 → 통과 확인**

```bash
flutter test test/models/place_model_test.dart
```

Expected:
```
00:01 +3: All tests passed!
```

- [ ] **Step 5: 커밋**

```bash
git add lib/models/place_model.dart test/models/place_model_test.dart
git commit -m "feat: PlaceModel 생성 (fromJson)"
```

---

## Task 4: RelatedWorkModel 생성 (TDD)

**Files:**
- Create: `lib/models/related_work_model.dart`
- Create: `test/models/related_work_model_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/models/related_work_model_test.dart` 생성:

```dart
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
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
flutter test test/models/related_work_model_test.dart
```

Expected: `Error: Cannot find 'package:citystorymap/models/related_work_model.dart'`

- [ ] **Step 3: RelatedWorkModel 구현**

`lib/models/related_work_model.dart` 생성:

```dart
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
      case 'anime':
        return '애니메이션';
      default:
        return type;
    }
  }
}
```

- [ ] **Step 4: 테스트 재실행 → 통과 확인**

```bash
flutter test test/models/related_work_model_test.dart
```

Expected:
```
00:01 +5: All tests passed!
```

- [ ] **Step 5: 커밋**

```bash
git add lib/models/related_work_model.dart test/models/related_work_model_test.dart
git commit -m "feat: RelatedWorkModel 생성 (fromJson + typeLabel)"
```

---

## Task 5: DataService 구현 (TDD)

**Files:**
- Create: `lib/services/data_service.dart`
- Create: `test/services/data_service_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/services/data_service_test.dart` 생성:

```dart
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
      heroGradient: [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
      placeCount: 2, isFeatured: true, featuredOrder: 1,
    ),
    ThemeModel(
      id: 'kinkakuji-mishima', cityId: 'kyoto', title: '금각사',
      category: '소설', year: '1956', hookText: '훅2', description: '설명2',
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
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

```bash
flutter test test/services/data_service_test.dart
```

Expected: `Error: Cannot find 'package:citystorymap/services/data_service.dart'`

- [ ] **Step 3: DataService 구현**

`lib/services/data_service.dart` 생성:

```dart
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
```

- [ ] **Step 4: 테스트 재실행 → 통과 확인**

```bash
flutter test test/services/data_service_test.dart
```

Expected:
```
00:01 +6: All tests passed!
```

- [ ] **Step 5: 전체 테스트 실행 → 이전 테스트도 여전히 통과 확인**

```bash
flutter test
```

Expected:
```
00:02 +16: All tests passed!
```

- [ ] **Step 6: 커밋**

```bash
git add lib/services/data_service.dart test/services/data_service_test.dart
git commit -m "feat: DataService 싱글톤 구현 (JSON 로딩 + 캐싱 + 조회 메서드)"
```

---

## Task 6: main.dart 수정

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: main() 함수 수정**

`lib/main.dart`의 `main()` 함수를 아래로 교체한다 (1~10번째 줄 근처):

```dart
import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/library_screen.dart';

/// 앱 진입점 - DataService 초기화 후 앱 실행
void main() async {
  // Flutter 엔진 초기화 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // JSON 데이터 로딩 (앱 시작 시 한 번만)
  await DataService.initialize();

  runApp(const CityStoryMapApp());
}
```

나머지 `CityStoryMapApp`, `MainScreen` 코드는 그대로 유지.

- [ ] **Step 2: 앱 빌드 확인**

```bash
flutter run
```

앱이 정상 실행되고 홈 화면이 뜨는지 확인. (아직 화면은 하드코딩 데이터 사용 중)

- [ ] **Step 3: 커밋**

```bash
git add lib/main.dart
git commit -m "feat: 앱 시작 시 DataService.initialize() 호출"
```

---

## Task 7: home_screen.dart 수정

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: home_screen.dart 전체 교체**

`lib/screens/home_screen.dart`를 아래 내용으로 교체한다:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../services/data_service.dart';
import 'theme_detail_screen.dart';

/// 홈 화면 (스토리 탭)
/// - 상단: 히어로 캐러셀 (featured 테마, 자동 슬라이드)
/// - 하단: 전체 스토리 리스트
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 캐러셀 페이지 컨트롤러
  final PageController _pageController = PageController();

  // 현재 캐러셀 페이지 인덱스
  int _currentPage = 0;

  // 자동 슬라이드 타이머
  Timer? _autoSlideTimer;

  // DataService에서 로드한 테마 목록
  late final List<ThemeModel> _allThemes;

  // 캐러셀에 표시할 featured 테마 목록
  late final List<ThemeModel> _featuredThemes;

  @override
  void initState() {
    super.initState();
    // DataService에서 데이터 로드 (동기 - 이미 캐싱됨)
    _allThemes = DataService.instance.getThemes();
    _featuredThemes = DataService.instance.getFeaturedThemes();
    // 자동 슬라이드 시작 (3.5초 간격)
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// 자동 슬라이드 시작
  void _startAutoSlide() {
    if (_featuredThemes.isEmpty) return;
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _featuredThemes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// 테마 상세 화면으로 이동
  void _navigateToThemeDetail(ThemeModel theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeDetailScreen(theme: theme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CityStoryMap',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // 도시 선택 (MVP는 교토 고정)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '교토',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),

      // 본문
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 히어로 캐러셀
              _buildHeroCarousel(context),

              const SizedBox(height: 24),

              // 스토리 리스트 섹션
              _buildStoryListSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 히어로 캐러셀 (자동 슬라이드)
  Widget _buildHeroCarousel(BuildContext context) {
    if (_featuredThemes.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        // 캐러셀 본체
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _featuredThemes.length,
            itemBuilder: (context, index) {
              return _buildCarouselSlide(context, _featuredThemes[index]);
            },
          ),
        ),

        const SizedBox(height: 12),

        // 닷 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_featuredThemes.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 캐러셀 슬라이드 아이템
  Widget _buildCarouselSlide(BuildContext context, ThemeModel theme) {
    return GestureDetector(
      onTap: () => _navigateToThemeDetail(theme),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.heroGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // 텍스처 오버레이 (미묘한 패턴)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _TexturePatternPainter(),
                ),
              ),
            ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 + 연도
                  Text(
                    '${theme.category} · ${theme.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 테마 제목
                  Text(
                    theme.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 훅 문구
                  Text(
                    theme.hookText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // 하단: 장소 수 + CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${theme.placeCount}곳',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '탐험하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 스토리 리스트 섹션
  Widget _buildStoryListSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '교토의 모든 이야기',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${_allThemes.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 스토리 카드들
          ...List.generate(_allThemes.length, (index) {
            return _buildStoryCard(context, _allThemes[index]);
          }),
        ],
      ),
    );
  }

  /// 스토리 카드 위젯
  Widget _buildStoryCard(BuildContext context, ThemeModel theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () => _navigateToThemeDetail(theme),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 그라디언트 썸네일
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.heroGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      theme.category[0], // 카테고리 첫 글자
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${theme.category} · ${theme.placeCount}곳',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // 화살표
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 캐러셀 배경 텍스처 패턴 페인터
class _TexturePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    // 대각선 패턴
    for (double i = -size.height; i < size.width + size.height; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 2: 앱 실행 → 홈 화면 데이터 확인**

```bash
flutter run
```

홈 화면에서:
- 캐러셀에 3개 테마가 자동 슬라이드되는지 확인
- 하단 리스트에 3개 테마 카드가 표시되는지 확인
- 각 카드/캐러셀 탭 시 테마 상세 화면으로 이동되는지 확인 (아직 상세 화면은 하드코딩)

- [ ] **Step 3: 커밋**

```bash
git add lib/screens/home_screen.dart
git commit -m "feat: home_screen 하드코딩 제거 → DataService 연동"
```

---

## Task 8: theme_detail_screen.dart 수정

**Files:**
- Modify: `lib/screens/theme_detail_screen.dart`

- [ ] **Step 1: theme_detail_screen.dart 전체 교체**

`lib/screens/theme_detail_screen.dart`를 아래 내용으로 교체한다:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../models/place_model.dart';
import '../models/related_work_model.dart';
import '../services/data_service.dart';

/// 테마 상세 화면
/// - 히어로 헤더 (그라디언트 배경)
/// - 3개 탭: 카드뷰 / 지도뷰 / 관련작품
class ThemeDetailScreen extends StatefulWidget {
  final ThemeModel theme;

  const ThemeDetailScreen({super.key, required this.theme});

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen>
    with SingleTickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;

  // DataService에서 로드한 장소 목록
  late final List<PlaceModel> _places;

  // DataService에서 로드한 관련 작품 목록
  late final List<RelatedWorkModel> _relatedWorks;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // DataService에서 이 테마의 장소와 관련 작품 로드
    _places = DataService.instance.getPlacesByTheme(widget.theme.id);
    _relatedWorks = DataService.instance.getRelatedWorksByTheme(widget.theme.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 히어로 헤더
          _buildHeroHeader(context),

          // 탭 바
          _buildTabBar(context),

          // 탭 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCardView(context),
                _buildMapView(context),
                _buildRelatedWorksView(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 히어로 헤더
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.theme.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 바 (뒤로가기 + 장소 수)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 뒤로가기
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  // 장소 수
                  Text(
                    '${widget.theme.placeCount}곳',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 카테고리 + 연도
              Text(
                '${widget.theme.category} · ${widget.theme.year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              // 테마 제목
              Text(
                widget.theme.title,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 탭 바
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.secondary,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '카드뷰'),
          Tab(text: '지도뷰'),
          Tab(text: '관련작품'),
        ],
      ),
    );
  }

  /// 카드뷰 탭
  Widget _buildCardView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        return _buildPlaceCard(context, _places[index], index + 1);
      },
    );
  }

  /// 장소 카드
  Widget _buildPlaceCard(BuildContext context, PlaceModel place, int order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역 (그라디언트 + 이모지)
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.theme.heroGradient[0].withValues(alpha: 0.8),
                  widget.theme.heroGradient[1].withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                // 순번
                Positioned(
                  top: 12,
                  left: 12,
                  child: Text(
                    order.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 이모지
                Center(
                  child: Text(
                    place.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                // 장소명 + 지역
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        place.district,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 본문 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인용문 (story_quote)
                Text(
                  '"${place.storyQuote}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // 태그들
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: place.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 지도뷰 탭 (목업)
  Widget _buildMapView(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4DF),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '테마 지도',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '이 테마의 ${widget.theme.placeCount}개 장소가\n지도에 표시됩니다',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 관련작품 탭
  Widget _buildRelatedWorksView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 헤더
        Text(
          '📚 이 이야기를 더\n    깊이 만나보세요',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            height: 1.4,
          ),
        ),

        const SizedBox(height: 20),

        // 작품 리스트
        ..._relatedWorks.map((work) => _buildWorkCard(context, work)),
      ],
    );
  }

  /// 작품 카드 (url_launcher로 외부 링크 열기)
  Widget _buildWorkCard(BuildContext context, RelatedWorkModel work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 이모지 (cover_emoji)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(work.coverEmoji, style: const TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 16),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  work.titleKo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${work.creator} · ${work.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // 외부 링크 버튼 (URL 있을 때만 표시)
          if (work.externalUrl.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () async {
                final uri = Uri.parse(work.externalUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 앱 실행 → 테마 상세 화면 확인**

```bash
flutter run
```

테마 카드 탭 후:
- 카드뷰에 JSON의 실제 장소 데이터가 표시되는지 확인
- 관련작품 탭에 JSON의 작품 데이터가 표시되는지 확인
- 관련작품 외부 링크 버튼이 작동하는지 확인

- [ ] **Step 3: 커밋**

```bash
git add lib/screens/theme_detail_screen.dart
git commit -m "feat: theme_detail_screen 하드코딩 제거 → DataService 연동 + url_launcher"
```

---

## Task 9: library_screen.dart 수정

**Files:**
- Modify: `lib/screens/library_screen.dart`

- [ ] **Step 1: library_screen.dart 전체 교체**

`lib/screens/library_screen.dart`를 아래 내용으로 교체한다:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/related_work_model.dart';
import '../services/data_service.dart';

/// 라이브러리 화면 (관련작품 탭)
/// - 도시와 관련된 모든 작품 (소설, 영화, 애니메이션)
/// - 카테고리 필터
/// - 외부 링크 연결
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // 현재 선택된 카테고리 필터
  String _selectedCategory = '전체';

  // 카테고리 목록 (JSON type 기준: book→소설, movie→영화, anime→애니메이션)
  final List<String> _categories = ['전체', '소설', '영화', '애니메이션'];

  // DataService에서 로드한 전체 작품 목록
  late final List<RelatedWorkModel> _allWorks;

  @override
  void initState() {
    super.initState();
    _allWorks = DataService.instance.getAllRelatedWorks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_library, size: 20),
            const SizedBox(width: 8),
            Text(
              '라이브러리',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),

      // 본문
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            _buildHeader(context),

            // 카테고리 필터
            _buildCategoryFilter(context),

            const SizedBox(height: 16),

            // 작품 리스트
            Expanded(
              child: _buildWorksList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '교토를 더 깊이',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            '만나는 작품들',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '여행 전에 읽고, 여행 후에 다시 보는 이야기',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터 (가로 스크롤)
  Widget _buildCategoryFilter(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 작품 리스트 (카테고리 필터 적용)
  Widget _buildWorksList(BuildContext context) {
    // typeLabel로 필터링 (book→소설, movie→영화, anime→애니메이션)
    final filteredWorks = _selectedCategory == '전체'
        ? _allWorks
        : _allWorks.where((w) => w.typeLabel == _selectedCategory).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredWorks.length,
      itemBuilder: (context, index) {
        return _buildWorkCard(context, filteredWorks[index]);
      },
    );
  }

  /// 작품 카드 (url_launcher로 외부 링크 열기)
  Widget _buildWorkCard(BuildContext context, RelatedWorkModel work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 커버 이모지 (cover_emoji)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        work.coverEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 텍스트 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 원제
                        Text(
                          work.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        // 한국어 제목
                        Text(
                          work.titleKo,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        // 저자/감독 · 연도
                        Text(
                          '${work.creator} · ${work.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // 타입 뱃지 (typeLabel 사용)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      work.typeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 자세히 보기 버튼 (URL 있을 때만 표시)
              if (work.externalUrl.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(work.externalUrl);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('자세히 보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 앱 실행 → 라이브러리 화면 확인**

```bash
flutter run
```

라이브러리 탭에서:
- 13개 작품이 모두 표시되는지 확인
- 카테고리 필터(소설/영화/애니메이션)가 동작하는지 확인
- '자세히 보기' 버튼 탭 시 외부 앱(브라우저)이 열리는지 확인

- [ ] **Step 3: 커밋**

```bash
git add lib/screens/library_screen.dart
git commit -m "feat: library_screen 하드코딩 제거 → DataService 연동 + url_launcher"
```

---

## Task 10: AndroidManifest.xml 수정 (url_launcher)

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: queries 블록 추가**

`android/app/src/main/AndroidManifest.xml`의 기존 `<queries>` 블록에 http/https intent를 추가한다:

```xml
<queries>
    <!-- 기존: Flutter 텍스트 처리 -->
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <!-- url_launcher: http/https URL 열기 -->
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="https"/>
    </intent>
    <intent>
        <action android:name="android.intent.action.VIEW"/>
        <data android:scheme="http"/>
    </intent>
</queries>
```

- [ ] **Step 2: 최종 전체 테스트**

```bash
flutter test
```

Expected:
```
00:03 +16: All tests passed!
```

- [ ] **Step 3: 앱 최종 확인**

```bash
flutter run
```

확인 항목:
- 홈 캐러셀/리스트: JSON 데이터 표시 ✓
- 테마 상세 카드뷰: 실제 장소 데이터 ✓
- 테마 상세 관련작품: 외부 링크 버튼 작동 ✓
- 라이브러리: 전체 13개 작품 + 필터 + 링크 ✓

- [ ] **Step 4: 최종 커밋**

```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat: AndroidManifest url_launcher queries 추가"
```
