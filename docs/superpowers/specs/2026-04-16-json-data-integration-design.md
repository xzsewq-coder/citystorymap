# JSON 데이터 연동 설계

**날짜:** 2026-04-16  
**범위:** themes.json / places.json / related_works.json → 각 화면 연동 + 외부 링크 열기

---

## 목표

현재 각 화면에 하드코딩된 샘플 데이터를 제거하고, `data/` 폴더의 JSON 파일에서 실제 데이터를 불러오도록 연동한다. 라이브러리 화면의 "자세히 보기" 버튼도 함께 활성화한다.

---

## 선택한 접근 방식: DataService 싱글톤 (B안)

- `DataService` 하나가 모든 JSON을 앱 시작 시 한 번만 로딩, 메모리에 캐싱
- 각 화면은 `DataService.instance`를 통해 데이터를 요청
- CLAUDE.md의 "UI와 Data 분리" 원칙 준수

**선택 이유:**
- 화면 이동마다 파일 I/O 없음 (빠른 탐색)
- 데이터 로직이 한 곳에 집중 → 도시 추가 시 수정 포인트 최소화
- Provider는 읽기 전용 데이터엔 불필요 (나중에 즐겨찾기 등 생길 때 추가)

---

## 파일 구조

```
lib/
  models/
    theme_model.dart          ← Theme 모델 클래스
    place_model.dart          ← Place 모델 클래스
    related_work_model.dart   ← RelatedWork 모델 클래스
  services/
    data_service.dart         ← JSON 로딩 + 메모리 캐싱
  screens/
    home_screen.dart          ← 수정: 하드코딩 제거, DataService 사용
    theme_detail_screen.dart  ← 수정: 하드코딩 제거, DataService 사용
    library_screen.dart       ← 수정: 하드코딩 제거, DataService 사용, url_launcher 연결
  main.dart                   ← 수정: DataService.initialize() 호출
pubspec.yaml                  ← 수정: assets 경로 추가, url_launcher 패키지 추가
```

---

## 데이터 흐름

```
앱 시작
  └─ main.dart: WidgetsFlutterBinding.ensureInitialized()
       └─ DataService.initialize()
            ├─ rootBundle.loadString('data/themes.json')
            ├─ rootBundle.loadString('data/places.json')
            └─ rootBundle.loadString('data/related_works.json')
                 └─ 파싱 후 메모리 캐싱

각 화면 (동기 호출)
  ├─ DataService.instance.getThemes()                   → List<ThemeModel>
  ├─ DataService.instance.getFeaturedThemes()           → List<ThemeModel> (is_featured=true, order 순)
  ├─ DataService.instance.getPlacesByTheme(themeId)     → List<PlaceModel>
  └─ DataService.instance.getRelatedWorksByTheme(themeId) → List<RelatedWorkModel>
```

---

## 모델 클래스 명세

### ThemeModel (`lib/models/theme_model.dart`)

| 필드 | 타입 | JSON 키 |
|------|------|---------|
| id | String | id |
| cityId | String | city_id |
| title | String | title |
| category | String | category |
| year | String | year |
| hookText | String | hook_text |
| description | String | description |
| heroGradient | List\<Color\> | hero_gradient (hex 문자열 → Color 변환) |
| placeCount | int | place_count |
| isFeatured | bool | is_featured |
| featuredOrder | int | featured_order |

### PlaceModel (`lib/models/place_model.dart`)

| 필드 | 타입 | JSON 키 |
|------|------|---------|
| id | String | id |
| themeId | String | theme_id |
| name | String | name |
| emoji | String | emoji |
| district | String | district |
| storyQuote | String | story_quote |
| detailStory | String | detail_story |
| relatedPerson | String | related_person |
| visitTip | String | visit_tip |
| tags | List\<String\> | tags |
| order | int | order |
| lat | double | lat |
| lng | double | lng |

### RelatedWorkModel (`lib/models/related_work_model.dart`)

| 필드 | 타입 | JSON 키 |
|------|------|---------|
| id | String | id |
| type | String | type (book/movie/anime) |
| title | String | title |
| titleKo | String | title_ko |
| creator | String | creator |
| year | int | year |
| coverEmoji | String | cover_emoji |
| description | String | description |
| externalUrl | String | external_url |
| themeIds | List\<String\> | theme_ids |

---

## DataService 명세 (`lib/services/data_service.dart`)

```dart
class DataService {
  static final DataService instance = DataService._();
  DataService._();

  // 초기화 (main.dart에서 앱 시작 시 한 번 호출)
  static Future<void> initialize() async { ... }

  // 조회 메서드 (동기, 캐시에서 반환)
  List<ThemeModel> getThemes()
  List<ThemeModel> getFeaturedThemes()          // is_featured=true, featuredOrder 순 정렬
  List<PlaceModel> getPlacesByTheme(String themeId)
  List<RelatedWorkModel> getRelatedWorksByTheme(String themeId)
  List<RelatedWorkModel> getAllRelatedWorks()
}
```

---

## 화면별 변경 사항

### home_screen.dart
- `_ThemeData` 내부 클래스 → `ThemeModel` 로 교체
- `_themes` 하드코딩 리스트 → `DataService.instance.getThemes()`
- 캐러셀은 `getFeaturedThemes()` 사용 (featured_order 순)
- `ThemeDetailScreen`에 전달하는 파라미터 타입을 `ThemeModel` 기준으로 정리

### theme_detail_screen.dart
- `_PlaceData` 내부 클래스 → `PlaceModel` 로 교체
- `switch(themeId)` 하드코딩 분기 → `DataService.instance.getPlacesByTheme(themeId)`
- 관련작품 탭: `DataService.instance.getRelatedWorksByTheme(themeId)`

### library_screen.dart
- `_WorkItem` 내부 클래스 → `RelatedWorkModel` 로 교체
- 샘플 리스트 → `DataService.instance.getAllRelatedWorks()`
- 카테고리 필터: JSON의 `type` 필드 기준 (book→소설, movie→영화, anime→애니메이션 매핑)
- 현재 '드라마' 카테고리는 JSON 데이터 없음 → 필터 목록에서 제거 (`['전체', '소설', '영화', '애니메이션']`)
- "자세히 보기" 버튼: `url_launcher` 패키지로 `externalUrl` 열기

---

## 외부 링크 (`url_launcher`)

- `pubspec.yaml`에 `url_launcher: ^6.3.0` 추가
- `launchUrl(Uri.parse(work.externalUrl), mode: LaunchMode.externalApplication)`
- URL이 비어 있으면 버튼 비활성화

---

## pubspec.yaml 변경

```yaml
dependencies:
  url_launcher: ^6.3.0      # 추가

flutter:
  assets:
    - data/themes.json       # 추가
    - data/places.json       # 추가
    - data/related_works.json # 추가
```

---

## 에러 처리

- `initialize()` 실패 시 앱이 빈 리스트로 graceful degradation (크래시 방지)
- `externalUrl`이 빈 문자열이면 "자세히 보기" 버튼 숨김

---

## 완료 기준

- [ ] 홈 화면 캐러셀/리스트가 `themes.json` 데이터로 표시됨
- [ ] 테마 상세 → 카드뷰가 `places.json` 데이터로 표시됨
- [ ] 테마 상세 → 관련작품 탭이 `related_works.json` 데이터로 표시됨
- [ ] 라이브러리 화면이 `related_works.json` 전체 데이터로 표시됨
- [ ] 라이브러리 "자세히 보기" 버튼이 외부 URL을 열음
- [ ] 하드코딩 샘플 데이터가 모두 제거됨
