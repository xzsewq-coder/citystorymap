import 'package:flutter/material.dart';

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
  // 현재 선택된 카테고리 필터
  String _selectedCategory = '전체';

  // 카테고리 목록
  final List<String> _categories = ['전체', '소설', '영화', '드라마', '애니메이션'];

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

  /// 작품 리스트
  Widget _buildWorksList(BuildContext context) {
    // 샘플 데이터 (추후 JSON에서 로딩)
    final works = [
      _WorkItem(
        emoji: '📖',
        title: '燃えよ剣',
        titleKo: '타오르라 검이여',
        creator: '시바 료타로',
        year: 1964,
        type: '소설',
        linkedTheme: '신선조 협객',
      ),
      _WorkItem(
        emoji: '🎬',
        title: '壬生義士伝',
        titleKo: '미부 의사전',
        creator: '타키타 요지로',
        year: 2003,
        type: '영화',
        linkedTheme: '신선조 협객',
      ),
      _WorkItem(
        emoji: '📖',
        title: '金閣寺',
        titleKo: '금각사',
        creator: '미시마 유키오',
        year: 1956,
        type: '소설',
        linkedTheme: '미시마 유키오의 금각사',
      ),
      _WorkItem(
        emoji: '🎞️',
        title: '言の葉の庭',
        titleKo: '언어의 정원',
        creator: '신카이 마코토',
        year: 2013,
        type: '애니메이션',
        linkedTheme: '언어의 정원의 교토',
      ),
      _WorkItem(
        emoji: '⚔️',
        title: 'るろうに剣心',
        titleKo: '바람의 검심',
        creator: '와츠키 노부히로',
        year: 1996,
        type: '애니메이션',
        linkedTheme: '신선조 협객',
      ),
    ];

    // 카테고리 필터링
    final filteredWorks = _selectedCategory == '전체'
        ? works
        : works.where((w) => w.type == _selectedCategory).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredWorks.length,
      itemBuilder: (context, index) {
        return _buildWorkCard(context, filteredWorks[index]);
      },
    );
  }

  /// 작품 카드
  Widget _buildWorkCard(BuildContext context, _WorkItem work) {
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
                  // 이모지 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        work.emoji,
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
                        if (work.titleKo != null)
                          Text(
                            work.titleKo!,
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

                  // 타입 뱃지
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
                      work.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 연결된 테마
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    work.linkedTheme,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 외부 링크 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 외부 URL 열기
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

/// 작품 아이템 데이터 클래스
class _WorkItem {
  final String emoji;
  final String title;
  final String? titleKo;
  final String creator;
  final int year;
  final String type;
  final String linkedTheme;

  _WorkItem({
    required this.emoji,
    required this.title,
    this.titleKo,
    required this.creator,
    required this.year,
    required this.type,
    required this.linkedTheme,
  });
}
