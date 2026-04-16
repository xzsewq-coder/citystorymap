import 'dart:async';
import 'package:flutter/material.dart';
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

  // 샘플 테마 데이터 (추후 JSON에서 로딩)
  final List<_ThemeData> _themes = [
    _ThemeData(
      id: 'shinsengumi',
      emoji: '⚔️',
      title: '신선조 협객의 교토',
      category: '역사',
      year: '1863-1869',
      hookText: '막부 말기, 교토를 지킨 검객들의 발자취를 따라 걷다',
      placeCount: 5,
      gradientColors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
    ),
    _ThemeData(
      id: 'kinkakuji-mishima',
      emoji: '🏯',
      title: '미시마 유키오의 금각사',
      category: '소설',
      year: '1956',
      hookText: '아름다움에 사로잡힌 한 청년의 광기어린 집착',
      placeCount: 4,
      gradientColors: [const Color(0xFF2D132C), const Color(0xFF801336)],
    ),
    _ThemeData(
      id: 'garden-of-words',
      emoji: '🌧️',
      title: '〈언어의 정원〉의 교토',
      category: '애니메이션',
      year: '2013',
      hookText: '비 오는 날, 정원에서 시작된 두 사람의 이야기',
      placeCount: 3,
      gradientColors: [const Color(0xFF134E5E), const Color(0xFF71B280)],
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _themes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// 테마 상세 화면으로 이동
  void _navigateToThemeDetail(_ThemeData theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeDetailScreen(
          themeId: theme.id,
          title: theme.title,
          category: theme.category,
          year: theme.year,
          placeCount: theme.placeCount,
          gradientColors: theme.gradientColors,
        ),
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
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              return _buildCarouselSlide(context, _themes[index]);
            },
          ),
        ),

        const SizedBox(height: 12),

        // 닷 인디케이터
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_themes.length, (index) {
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
  Widget _buildCarouselSlide(BuildContext context, _ThemeData theme) {
    return GestureDetector(
      onTap: () => _navigateToThemeDetail(theme),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradientColors,
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

                  const SizedBox(height: 8),

                  // 이모지
                  Text(
                    theme.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),

                  const SizedBox(height: 8),

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
                '${_themes.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 스토리 카드들
          ...List.generate(_themes.length, (index) {
            final theme = _themes[index];
            return _buildStoryCard(context, theme);
          }),
        ],
      ),
    );
  }

  /// 스토리 카드 위젯
  Widget _buildStoryCard(BuildContext context, _ThemeData theme) {
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
                // 이모지 썸네일
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      theme.emoji,
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

/// 테마 데이터 클래스
class _ThemeData {
  final String id;
  final String emoji;
  final String title;
  final String category;
  final String year;
  final String hookText;
  final int placeCount;
  final List<Color> gradientColors;

  _ThemeData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.category,
    required this.year,
    required this.hookText,
    required this.placeCount,
    required this.gradientColors,
  });
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
