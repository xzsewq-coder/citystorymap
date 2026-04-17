import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/theme_model.dart';
import '../models/place_model.dart';
import '../models/related_work_model.dart';
import '../services/data_service.dart';
import 'place_detail_screen.dart';

/// 테마 상세 화면
/// - 히어로 헤더 (그라디언트 배경)
/// - 3개 탭: 카드뷰 / 지도뷰 / 관련작품
class ThemeDetailScreen extends StatefulWidget {
  // 테마 모델 객체를 직접 받음
  final ThemeModel theme;

  const ThemeDetailScreen({
    super.key,
    required this.theme,
  });

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

    // DataService에서 해당 테마의 장소와 관련 작품 로드
    _places = DataService.instance.getPlacesByTheme(widget.theme.id);
    _relatedWorks = DataService.instance.getRelatedWorksByTheme(widget.theme.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 외부 URL 열기 (관련 작품 링크)
  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 장소 상세 화면으로 이동
  void _navigateToPlaceDetail(PlaceModel place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailScreen(
          place: place,
          theme: widget.theme,
        ),
      ),
    );
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
    final theme = widget.theme;

    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.heroGradient,
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
                    '${theme.placeCount}곳',
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
                '${theme.category} · ${theme.year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              // 테마 제목
              Text(
                theme.title,
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

  /// 카드뷰 탭 - 장소 카드 리스트
  Widget _buildCardView(BuildContext context) {
    if (_places.isEmpty) {
      return _buildEmptyState(context, '장소 정보가 없습니다');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        return _buildPlaceCard(context, _places[index], index + 1);
      },
    );
  }

  /// 장소 카드 위젯
  Widget _buildPlaceCard(BuildContext context, PlaceModel place, int order) {
    final gradientColors = widget.theme.heroGradient;

    return GestureDetector(
      onTap: () => _navigateToPlaceDetail(place),
      child: Container(
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
                  gradientColors[0].withValues(alpha: 0.8),
                  gradientColors[1].withValues(alpha: 0.8),
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
                // 순번 (01, 02...)
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
                      // 장소명
                      Flexible(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 지역명
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
                // 스토리 인용문
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
      ),
    );
  }

  /// 지도뷰 탭 (목업 - 추후 Google Maps 연동)
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
    if (_relatedWorks.isEmpty) {
      return _buildEmptyState(context, '관련 작품이 없습니다');
    }

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

  /// 관련 작품 카드
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
          // 커버 이모지
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

          // 작품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일본어 제목
                Text(
                  work.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // 한국어 제목
                if (work.titleKo.isNotEmpty)
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

          // 외부 링크 버튼
          if (work.externalUrl.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () => _launchUrl(work.externalUrl),
            ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
