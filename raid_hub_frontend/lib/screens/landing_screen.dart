import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui'; // For ImageFilter
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// [LandingScreen]
/// 앱의 첫인상을 결정하는 세련된 랜딩 페이지입니다.
/// 게이밍 감성의 글래스모피즘(Glassmorphism) UI와 부드러운 배경 전환 효과가 적용되어 있습니다.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _currentImageIndex = 0;
  late AnimationController _fadeController;

  final List<String> _backgroundImages = [
    'assets/images/landing_bg.jpg',
    'assets/images/landing_bg2.jpg',
    'assets/images/landing_bg3.jpg',
    'assets/images/landing_bg4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 6), (Timer t) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 다이나믹 배경 이미지 (크로스 페이드)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 2000),
              child: Container(
                key: ValueKey<int>(_currentImageIndex),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_backgroundImages[_currentImageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
                // 어두운 오버레이 레이어
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. 상단 액션 바 (다크모드 & 관리자)
          Positioned(
            top: 50,
            right: 20,
            child: FadeTransition(
              opacity: _fadeController,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        _buildHeaderIcon(
                          icon: isDark ? Icons.light_mode : Icons.dark_mode,
                          onPressed: () => themeProvider.toggleTheme(),
                        ),
                        Container(width: 1, height: 20, color: Colors.white24),
                        _buildHeaderIcon(
                          icon: authService.isAuthenticated ? Icons.logout : Icons.admin_panel_settings,
                          tooltip: authService.isAuthenticated ? '로그아웃' : '관리자',
                          onPressed: () {
                            if (authService.isAuthenticated) {
                              authService.logout();
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. 중앙 메인 콘텐츠
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 및 타이틀 섹션
                  Column(
                    children: [
                      const Icon(Icons.hub_outlined, color: Colors.blueAccent, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        'LOST ARK',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent.withValues(alpha: 0.8),
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'RAID HUB',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15),
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '당신의 완벽한 레이드를 위한\n올인원 공략 저장소',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // 메뉴 버튼들 (글래스모피즘 스타일)
                  _buildGlassButton(
                    context,
                    title: '공략 영상 탐색',
                    subtitle: '가장 빠르고 정확한 가이드',
                    icon: Icons.play_arrow_rounded,
                    primaryColor: Colors.blueAccent,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 0)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGlassButton(
                    context,
                    title: '컨닝 페이퍼',
                    subtitle: '핵심 기믹 한눈에 보기',
                    icon: Icons.auto_awesome_motion_rounded,
                    primaryColor: Colors.purpleAccent,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. 하단 푸터
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeController,
              child: Column(
                children: [
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 30),
                  const SizedBox(height: 10),
                  Text(
                    '© 2026 RAID HUB TEAM. ALL RIGHTS RESERVED.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({required IconData icon, String? tooltip, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 24),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 20,
    );
  }

  Widget _buildGlassButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 320,
      height: 80,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.05),
            child: InkWell(
              onTap: onTap,
              hoverColor: Colors.white.withValues(alpha: 0.05),
              splashColor: primaryColor.withValues(alpha: 0.2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
