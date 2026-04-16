import 'package:flutter/material.dart';

/// 홈 화면 (스토리 탭)
/// - 상단: 히어로 캐러셀 (featured 테마)
/// - 하단: 전체 스토리 리스트
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // 히어로 캐러셀 영역 (추후 구현)
              _buildHeroCarouselPlaceholder(context),

              const SizedBox(height: 24),

              // 스토리 리스트 섹션
              _buildStoryListSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 히어로 캐러셀 플레이스홀더 (추후 실제 캐러셀로 교체)
  Widget _buildHeroCarouselPlaceholder(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              '히어로 캐러셀',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '추후 구현 예정',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.5),
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
                '3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 플레이스홀더 스토리 카드들
          _buildStoryCard(
            context,
            emoji: '⚔️',
            title: '신선조 협객의 교토',
            category: '역사',
            placeCount: 5,
          ),
          _buildStoryCard(
            context,
            emoji: '🏯',
            title: '미시마 유키오의 금각사',
            category: '소설',
            placeCount: 4,
          ),
          _buildStoryCard(
            context,
            emoji: '🌧️',
            title: '〈언어의 정원〉의 교토',
            category: '애니메이션',
            placeCount: 3,
          ),
        ],
      ),
    );
  }

  /// 스토리 카드 위젯
  Widget _buildStoryCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String category,
    required int placeCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: () {
            // TODO: 테마 상세 화면으로 이동
          },
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
                      emoji,
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
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$category · $placeCount곳',
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
