import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/related_work_model.dart';
import '../models/theme_model.dart';
import '../services/data_service.dart';
import 'theme_detail_screen.dart';

/// 라이브러리 화면 (관련작품 탭)
/// - 도시와 관련된 모든 작품 (책, 영화, 드라마, 애니메이션)
/// - 카테고리 필터
/// - 외부 링크 연결
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // 현재 선택된 카테고리 필터 (type 값: 'all', 'book', 'movie', 'anime')
  String _selectedType = 'all';

  // DataService에서 로드한 전체 작품 목록
  late final List<RelatedWorkModel> _allWorks;

  // DataService에서 로드한 테마 목록 (테마 이름 조회용)
  late final List<ThemeModel> _themes;

  // 카테고리 필터 옵션 (타입 값과 라벨)
  final List<_FilterOption> _filterOptions = [
    _FilterOption(type: 'all', label: '전체'),
    _FilterOption(type: 'book', label: '소설'),
    _FilterOption(type: 'movie', label: '영화'),
    _FilterOption(type: 'anime', label: '애니메이션'),
  ];

  @override
  void initState() {
    super.initState();
    // DataService에서 데이터 로드
    _allWorks = DataService.instance.getAllRelatedWorks();
    _themes = DataService.instance.getThemes();
  }

  /// 테마 ID로 테마 이름 조회
  String _getThemeName(String themeId) {
    final theme = _themes.where((t) => t.id == themeId).firstOrNull;
    return theme?.title ?? '';
  }

  /// 테마 ID로 테마 모델 조회
  ThemeModel? _getTheme(String themeId) {
    return _themes.where((t) => t.id == themeId).firstOrNull;
  }

  /// 외부 URL 열기
  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 테마 상세 화면으로 이동
  void _navigateToTheme(ThemeModel theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeDetailScreen(theme: theme),
      ),
    );
  }

  /// 필터된 작품 목록 반환
  List<RelatedWorkModel> get _filteredWorks {
    if (_selectedType == 'all') {
      return _allWorks;
    }
    return _allWorks.where((w) => w.type == _selectedType).toList();
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
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = option.type == _selectedType;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = option.type;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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

  /// 작품 리스트
  Widget _buildWorksList(BuildContext context) {
    final works = _filteredWorks;

    if (works.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: works.length,
      itemBuilder: (context, index) {
        return _buildWorkCard(context, works[index]);
      },
    );
  }

  /// 작품 카드
  Widget _buildWorkCard(BuildContext context, RelatedWorkModel work) {
    // 연결된 첫 번째 테마 (있는 경우)
    final linkedThemeId = work.themeIds.isNotEmpty ? work.themeIds.first : null;
    final linkedThemeName = linkedThemeId != null ? _getThemeName(linkedThemeId) : '';
    final linkedTheme = linkedThemeId != null ? _getTheme(linkedThemeId) : null;

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
                  // 커버 이모지 아이콘
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
                        // 원제 (일본어)
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

                  // 타입 뱃지 (소설/영화/애니메이션)
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

              // 연결된 테마 (있는 경우에만 표시)
              if (linkedThemeName.isNotEmpty) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: linkedTheme != null
                      ? () => _navigateToTheme(linkedTheme)
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          linkedThemeName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 외부 링크 버튼 (URL이 있는 경우에만)
              if (work.externalUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(work.externalUrl),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('자세히 보기'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            '해당 카테고리의 작품이 없습니다',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// 카테고리 필터 옵션
class _FilterOption {
  final String type;  // 'all', 'book', 'movie', 'anime'
  final String label; // '전체', '소설', '영화', '애니메이션'

  const _FilterOption({required this.type, required this.label});
}
