import 'dart:math';
import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../models/place_model.dart';
import '../services/data_service.dart';
import 'theme_detail_screen.dart';

/// 지도 화면 (글로벌 지도 탭)
/// - 실제 장소 좌표 기반 핀 배치 (목업 — Google Maps 연동 예정)
/// - 테마별 핀 표시, 탭 시 테마 상세 이동
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final List<ThemeModel> _themes;
  late final List<PlaceModel> _places;

  // 현재 선택된 테마 (팝업 표시용)
  ThemeModel? _selectedTheme;

  @override
  void initState() {
    super.initState();
    _themes = DataService.instance.getThemes();
    _places = DataService.instance.getThemes()
        .expand((t) => DataService.instance.getPlacesByTheme(t.id))
        .toList();
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

  /// 장소 좌표들의 경계 상자 계산
  _CoordBounds _calcBounds() {
    final lats = _places.map((p) => p.lat).toList();
    final lngs = _places.map((p) => p.lng).toList();
    final minLat = lats.reduce(min);
    final maxLat = lats.reduce(max);
    final minLng = lngs.reduce(min);
    final maxLng = lngs.reduce(max);
    // 여백 15% 추가
    final latPad = (maxLat - minLat) * 0.15;
    final lngPad = (maxLng - minLng) * 0.15;
    return _CoordBounds(
      minLat: minLat - latPad,
      maxLat: maxLat + latPad,
      minLng: minLng - lngPad,
      maxLng: maxLng + lngPad,
    );
  }

  /// 위경도 → 화면 픽셀 변환
  Offset _toScreenOffset(double lat, double lng, Size size, _CoordBounds bounds) {
    final x = (lng - bounds.minLng) / (bounds.maxLng - bounds.minLng) * size.width;
    // 위도는 위로 갈수록 커지므로 y축 반전
    final y = (1 - (lat - bounds.minLat) / (bounds.maxLat - bounds.minLat)) * size.height;
    return Offset(x, y);
  }

  /// 테마별 대표 좌표 (해당 테마 장소들의 평균 위경도)
  Map<String, _ThemePin> _buildThemePins() {
    final result = <String, _ThemePin>{};
    for (final theme in _themes) {
      final themePlaces = _places.where((p) => p.themeId == theme.id).toList();
      if (themePlaces.isEmpty) continue;
      final avgLat = themePlaces.map((p) => p.lat).reduce((a, b) => a + b) / themePlaces.length;
      final avgLng = themePlaces.map((p) => p.lng).reduce((a, b) => a + b) / themePlaces.length;
      result[theme.id] = _ThemePin(lat: avgLat, lng: avgLng, theme: theme);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 20),
            const SizedBox(width: 8),
            Text(
              '${DataService.instance.cityNameKo} 지도',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
      body: _places.isEmpty
          ? _buildEmptyState(context)
          : _buildMap(context),
    );
  }

  /// 메인 지도 영역
  Widget _buildMap(BuildContext context) {
    final pins = _buildThemePins();
    final bounds = _calcBounds();

    return Stack(
      children: [
        // 배경 그리드 (지도 느낌)
        CustomPaint(
          size: Size.infinite,
          painter: _GridPainter(),
        ),

        // 핀 레이어
        LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              children: pins.values.map((pin) {
                final offset = _toScreenOffset(pin.lat, pin.lng, size, bounds);
                final isSelected = _selectedTheme?.id == pin.theme.id;
                return _buildPin(context, pin.theme, offset, isSelected);
              }).toList(),
            );
          },
        ),

        // 선택된 테마 팝업
        if (_selectedTheme != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildSelectedPopup(context, _selectedTheme!),
          ),

        // 좌상단 안내 뱃지
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '🗺️ Google Maps 연동 예정',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  /// 테마 핀 위젯
  Widget _buildPin(BuildContext context, ThemeModel theme, Offset offset, bool isSelected) {
    const pinSize = 44.0;
    return Positioned(
      // 핀 중앙이 좌표에 오도록 offset 적용
      left: offset.dx - pinSize / 2,
      top: offset.dy - pinSize / 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTheme = isSelected ? null : theme;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? pinSize * 1.2 : pinSize,
          height: isSelected ? pinSize * 1.2 : pinSize,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? theme.heroGradient.first
                  : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? theme.heroGradient.first.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              theme.emoji,
              style: TextStyle(fontSize: isSelected ? 24 : 20),
            ),
          ),
        ),
      ),
    );
  }

  /// 선택된 테마 팝업 카드
  Widget _buildSelectedPopup(BuildContext context, ThemeModel theme) {
    return GestureDetector(
      onTap: () => _navigateToThemeDetail(theme),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 테마 이모지
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.heroGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(theme.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 12),

            // 테마 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${theme.category} · ${theme.placeCount}곳',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // 이동 화살표
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 상태 (데이터 없을 때)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        '장소 데이터를 불러올 수 없습니다',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

/// 좌표 경계 상자
class _CoordBounds {
  final double minLat, maxLat, minLng, maxLng;
  const _CoordBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

/// 테마 핀 데이터
class _ThemePin {
  final double lat, lng;
  final ThemeModel theme;
  const _ThemePin({required this.lat, required this.lng, required this.theme});
}

/// 지도 배경 그리드 페인터
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 배경색
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8E4DF),
    );

    final paint = Paint()
      ..color = const Color(0xFFD5D0C9)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
