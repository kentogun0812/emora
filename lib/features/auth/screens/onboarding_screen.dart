// lib/features/auth/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _slides = [
    OnboardingData(
      emoji: '💌',
      titleKey: 'onboarding.title_1',
      descKey: 'onboarding.desc_1',
      glowColor: EmoraColors.primary,
    ),
    OnboardingData(
      emoji: '🌸',
      titleKey: 'onboarding.title_2',
      descKey: 'onboarding.desc_2',
      glowColor: Colors.purple,
    ),
    OnboardingData(
      emoji: '💝',
      titleKey: 'onboarding.title_3',
      descKey: 'onboarding.desc_3',
      glowColor: EmoraColors.secondary,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    
    // Smooth transition to login screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Theme Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: EmoraColors.bgGradient,
            ),
          ),
          
          // Background Glow for visual depth
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _slides[_currentPage].glowColor.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header / Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        context.translate('onboarding.btn_skip'),
                        style: const TextStyle(
                          color: EmoraColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page Slider Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Emoji Illustative Circle
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: EmoraColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: slide.glowColor.withOpacity(0.15),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                slide.emoji,
                                style: const TextStyle(fontSize: 72),
                              ),
                            ),
                            const SizedBox(height: 50),
                            
                            // Title
                            Text(
                              context.translate(slide.titleKey),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            
                            // Description
                            Text(
                              context.translate(slide.descKey),
                              style: const TextStyle(
                                fontSize: 16,
                                color: EmoraColors.textMuted,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Navigation Bottom Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Column(
                    children: [
                      // Indicators Dot Layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? EmoraColors.primary
                                  : EmoraColors.textMuted.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Next/Start Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EmoraColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          if (_currentPage == _slides.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? context.translate('onboarding.btn_start')
                              : context.translate('onboarding.btn_continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingData {
  final String emoji;
  final String titleKey;
  final String descKey;
  final Color glowColor;

  OnboardingData({
    required this.emoji,
    required this.titleKey,
    required this.descKey,
    required this.glowColor,
  });
}
