import 'package:flutter/material.dart';

/// 지도 화면 (글로벌 지도 탭)
/// - 도시 전체 지도
/// - 모든 테마의 핀 표시
/// - 핀 클릭 시 테마 상세로 이동
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 20),
            const SizedBox(width: 8),
            Text(
              '교토 지도',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),

      // 본문 - 지도 플레이스홀더
      body: _buildMapPlaceholder(context),
    );
  }

  /// 지도 플레이스홀더 (MVP는 목업)
  Widget _buildMapPlaceholder(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4DF),
      child: Stack(
        children: [
          // 배경 그리드 패턴 (지도 느낌)
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),

          // 중앙 안내 메시지
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '교토 전체 지도',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '모든 스토리의 장소가 표시됩니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🗺️ Google Maps 연동 예정',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 샘플 핀들
          _buildSamplePin(context, top: 100, left: 80, emoji: '⚔️'),
          _buildSamplePin(context, top: 150, left: 200, emoji: '🏯'),
          _buildSamplePin(context, top: 250, left: 120, emoji: '⛩️'),
          _buildSamplePin(context, top: 300, left: 280, emoji: '🌧️'),
          _buildSamplePin(context, top: 180, left: 320, emoji: '🍃'),
        ],
      ),
    );
  }

  /// 샘플 지도 핀
  Widget _buildSamplePin(
    BuildContext context, {
    required double top,
    required double left,
    required String emoji,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          // TODO: 테마 상세로 이동
        },
        child: Container(
          width: 40,
          height: 40,
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
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// 지도 배경 그리드 페인터
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D0C9)
      ..strokeWidth = 0.5;

    // 가로선
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 세로선
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
