import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/theme_model.dart';

/// 장소 상세 화면
/// - 히어로 헤더 (이모지 + 장소명)
/// - 상세 스토리
/// - 관련 인물
/// - 방문 팁
/// - 지도 미리보기 (목업)
class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;
  final ThemeModel theme; // 테마 색상 사용을 위해

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 히어로 헤더 (SliverAppBar)
          _buildHeroHeader(context),

          // 본문 콘텐츠
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  /// 히어로 헤더 (스크롤 시 축소되는 앱바)
  Widget _buildHeroHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // 텍스처 패턴
              Positioned.fill(
                child: CustomPaint(
                  painter: _TexturePatternPainter(),
                ),
              ),

              // 콘텐츠
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이모지
                      Text(
                        place.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),

                      const SizedBox(height: 12),

                      // 장소명
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // 지역
                      Text(
                        place.district,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 본문 콘텐츠
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그들
          _buildTags(context),

          const SizedBox(height: 24),

          // 인용문 (storyQuote)
          _buildQuoteSection(context),

          const SizedBox(height: 24),

          // 상세 스토리
          if (place.detailStory.isNotEmpty) ...[
            _buildSection(
              context,
              icon: Icons.auto_stories,
              title: '이야기',
              content: place.detailStory,
            ),
            const SizedBox(height: 24),
          ],

          // 관련 인물
          if (place.relatedPerson.isNotEmpty) ...[
            _buildSection(
              context,
              icon: Icons.person,
              title: '관련 인물',
              content: place.relatedPerson,
            ),
            const SizedBox(height: 24),
          ],

          // 방문 팁
          if (place.visitTip.isNotEmpty) ...[
            _buildSection(
              context,
              icon: Icons.lightbulb_outline,
              title: '방문 팁',
              content: place.visitTip,
              backgroundColor: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
          ],

          // 지도 미리보기 (목업)
          _buildMapPreview(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 태그 섹션
  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: place.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 인용문 섹션
  Widget _buildQuoteSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // 인용 아이콘
          Icon(
            Icons.format_quote,
            color: theme.heroGradient.first.withValues(alpha: 0.5),
            size: 32,
          ),

          const SizedBox(height: 8),

          // 인용문
          Text(
            place.storyQuote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 위젯 (아이콘 + 제목 + 내용)
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: backgroundColor == null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (아이콘 + 제목)
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 내용
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// 지도 미리보기 (목업)
  Widget _buildMapPreview(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 그리드 패턴
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _GridPainter(),
            ),
          ),

          // 중앙 핀
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  place.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),

          // 좌표 표시
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Google Maps 연동 예정 표시
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🗺️ 지도 연동 예정',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 텍스처 패턴 페인터
class _TexturePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

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

/// 지도 그리드 페인터
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D0C9)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
