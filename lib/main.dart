import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/library_screen.dart';

/// 앱 진입점
void main() {
  runApp(const CityStoryMapApp());
}

/// CityStoryMap 앱의 루트 위젯
class CityStoryMapApp extends StatelessWidget {
  const CityStoryMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityStoryMap',
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: _buildTheme(),
      home: const MainScreen(),
    );
  }

  /// PRD 디자인 시스템 기반 테마 설정
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      // 기본 배경색 (크림색 계열)
      scaffoldBackgroundColor: const Color(0xFFFAF9F6),

      // 컬러 스킴
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B6F4E),       // 액센트 (브라운골드)
        onPrimary: Colors.white,
        surface: Color(0xFFF5F3EE),       // 페이지 배경
        onSurface: Color(0xFF2C2C2C),     // 기본 텍스트
        secondary: Color(0xFF888888),     // 보조 텍스트
        outline: Color(0xFFEDE9E3),       // 구분선
      ),

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAF9F6),
        foregroundColor: Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),

      // 텍스트 테마 (Georgia 폰트 - 감성/문학적 톤)
      textTheme: const TextTheme(
        // 큰 제목 (테마 타이틀 등)
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Color(0xFF2C2C2C),
        ),
        // 중간 제목
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
        // 작은 제목
        headlineSmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
        // 본문 (이탤릭)
        bodyLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: Color(0xFF2C2C2C),
        ),
        // 일반 본문
        bodyMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 14,
          color: Color(0xFF2C2C2C),
        ),
        // 작은 텍스트 / 메타 정보
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFF888888),
        ),
        // 레이블
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF888888),
        ),
      ),

      // 하단 네비게이션 바 테마
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFAF9F6),
        selectedItemColor: Color(0xFF8B6F4E),
        unselectedItemColor: Color(0xFFBBBBBB),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

/// 메인 화면 (하단 탭 바 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭 인덱스
  int _currentIndex = 0;

  // 각 탭에 해당하는 화면 목록
  final List<Widget> _screens = const [
    HomeScreen(),     // 스토리 탭
    MapScreen(),      // 지도 탭
    LibraryScreen(),  // 라이브러리 탭
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 탭의 화면 표시
      body: _screens[_currentIndex],

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories),
            label: '스토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library_outlined),
            activeIcon: Icon(Icons.local_library),
            label: '라이브러리',
          ),
        ],
      ),
    );
  }
}
