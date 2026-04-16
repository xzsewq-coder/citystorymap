import 'package:flutter/material.dart';

/// 테마 상세 화면
/// - 히어로 헤더 (그라디언트 배경)
/// - 3개 탭: 카드뷰 / 지도뷰 / 관련작품
class ThemeDetailScreen extends StatefulWidget {
  final String themeId;
  final String title;
  final String category;
  final String year;
  final int placeCount;
  final List<Color> gradientColors;

  const ThemeDetailScreen({
    super.key,
    required this.themeId,
    required this.title,
    required this.category,
    required this.year,
    required this.placeCount,
    required this.gradientColors,
  });

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen>
    with SingleTickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;

  // 샘플 장소 데이터 (테마별로 다르게 - 추후 JSON 로딩)
  List<_PlaceData> get _places {
    switch (widget.themeId) {
      case 'shinsengumi':
        return [
          _PlaceData(
            emoji: '⚔️',
            name: '이케다야 터',
            district: '가와라마치',
            quote: '1864년, 신선조는 이곳에서 존왕양이파 지사들을 급습했다.',
            tags: ['1864년', '전투지'],
          ),
          _PlaceData(
            emoji: '🏯',
            name: '미부 둔소 터',
            district: '미부',
            quote: '신선조가 결성되고 훈련했던 본거지.',
            tags: ['1863년', '본거지'],
          ),
          _PlaceData(
            emoji: '⛩️',
            name: '니시혼간지',
            district: '시모교구',
            quote: '신선조가 미부에서 이전한 두 번째 둔소.',
            tags: ['1865년', '세계문화유산'],
          ),
          _PlaceData(
            emoji: '🏮',
            name: '시마바라 유곽',
            district: '시모교구',
            quote: '신선조 대원들이 자주 찾았던 유흥가.',
            tags: ['유흥가', '로맨스'],
          ),
          _PlaceData(
            emoji: '🗡️',
            name: '데라다야 여관',
            district: '후시미',
            quote: '사카모토 료마가 습격을 피해 탈출한 곳.',
            tags: ['1866년', '료마'],
          ),
        ];
      case 'kinkakuji-mishima':
        return [
          _PlaceData(
            emoji: '🏯',
            name: '금각사',
            district: '기타구',
            quote: '미조구치가 집착한 "절대적 아름다움".',
            tags: ['1950년대', '사원'],
          ),
          _PlaceData(
            emoji: '🍃',
            name: '다이토쿠지',
            district: '기타구',
            quote: '소설 속 미조구치가 수행했던 선종 사찰.',
            tags: ['선종', '수행'],
          ),
          _PlaceData(
            emoji: '🌲',
            name: '난젠지',
            district: '사쿄구',
            quote: '거대한 삼문이 압도적 존재감을 드러낸다.',
            tags: ['사원', '삼문'],
          ),
          _PlaceData(
            emoji: '🪨',
            name: '료안지 석정',
            district: '우쿄구',
            quote: '15개의 돌, 그러나 어디서 보아도 14개만 보인다.',
            tags: ['석정', '명상'],
          ),
        ];
      case 'garden-of-words':
        return [
          _PlaceData(
            emoji: '🌧️',
            name: '쇼세이엔 정원',
            district: '시모교구',
            quote: '비 내리는 정원의 고요함.',
            tags: ['정원', '비'],
          ),
          _PlaceData(
            emoji: '🍵',
            name: '무린안',
            district: '사쿄구',
            quote: '동산을 배경으로 한 차경의 정원.',
            tags: ['정원', '말차'],
          ),
          _PlaceData(
            emoji: '🍁',
            name: '에이칸도',
            district: '사쿄구',
            quote: '단풍의 명소이자, 빗방울이 가장 아름다운 사찰.',
            tags: ['단풍', '사원'],
          ),
        ];
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          colors: widget.gradientColors,
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
                    '${widget.placeCount}곳',
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
                '${widget.category} · ${widget.year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              // 테마 제목
              Text(
                widget.title,
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
  Widget _buildPlaceCard(BuildContext context, _PlaceData place, int order) {
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
                  widget.gradientColors[0].withValues(alpha: 0.8),
                  widget.gradientColors[1].withValues(alpha: 0.8),
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
                // 인용문
                Text(
                  '"${place.quote}"',
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
                '이 테마의 ${widget.placeCount}개 장소가\n지도에 표시됩니다',
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
    // 테마별 관련 작품 (추후 JSON 로딩)
    final works = _getRelatedWorks();

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
        ...works.map((work) => _buildWorkCard(context, work)),
      ],
    );
  }

  /// 관련 작품 데이터 가져오기
  List<_WorkData> _getRelatedWorks() {
    switch (widget.themeId) {
      case 'shinsengumi':
        return [
          _WorkData(
            emoji: '📖',
            title: '燃えよ剣',
            titleKo: '타오르라 검이여',
            creator: '시바 료타로',
            year: 1964,
          ),
          _WorkData(
            emoji: '🎬',
            title: '壬生義士伝',
            titleKo: '미부 의사전',
            creator: '타키타 요지로',
            year: 2003,
          ),
          _WorkData(
            emoji: '🎞️',
            title: '銀魂',
            titleKo: '은혼',
            creator: '소라치 히데아키',
            year: 2006,
          ),
        ];
      case 'kinkakuji-mishima':
        return [
          _WorkData(
            emoji: '📖',
            title: '金閣寺',
            titleKo: '금각사',
            creator: '미시마 유키오',
            year: 1956,
          ),
          _WorkData(
            emoji: '🎬',
            title: '炎上',
            titleKo: '염상',
            creator: '이치카와 곤',
            year: 1958,
          ),
        ];
      case 'garden-of-words':
        return [
          _WorkData(
            emoji: '🎞️',
            title: '言の葉の庭',
            titleKo: '언어의 정원',
            creator: '신카이 마코토',
            year: 2013,
          ),
          _WorkData(
            emoji: '🎞️',
            title: '君の名は。',
            titleKo: '너의 이름은.',
            creator: '신카이 마코토',
            year: 2016,
          ),
        ];
      default:
        return [];
    }
  }

  /// 작품 카드
  Widget _buildWorkCard(BuildContext context, _WorkData work) {
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
          // 이모지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(work.emoji, style: const TextStyle(fontSize: 24)),
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
                if (work.titleKo != null)
                  Text(
                    work.titleKo!,
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

          // 외부 링크 버튼
          IconButton(
            icon: Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              // TODO: 외부 URL 열기
            },
          ),
        ],
      ),
    );
  }
}

/// 장소 데이터 클래스
class _PlaceData {
  final String emoji;
  final String name;
  final String district;
  final String quote;
  final List<String> tags;

  _PlaceData({
    required this.emoji,
    required this.name,
    required this.district,
    required this.quote,
    required this.tags,
  });
}

/// 작품 데이터 클래스
class _WorkData {
  final String emoji;
  final String title;
  final String? titleKo;
  final String creator;
  final int year;

  _WorkData({
    required this.emoji,
    required this.title,
    this.titleKo,
    required this.creator,
    required this.year,
  });
}
