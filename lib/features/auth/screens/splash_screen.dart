// lib/features/auth/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../pairing/screens/pairing_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'profile_setup_screen.dart';
import '../../../core/utils/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    // Create pulse animation for logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Trigger session check process when opening screen
    context.read<AuthBloc>().add(AppStarted());

    // Wait at least 5 seconds before allowing redirect
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _minTimeElapsed = true;
      });
      _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    if (!_minTimeElapsed) return;
    
    final state = context.read<AuthBloc>().state;
    if (state is AuthUnauthenticated) {
      // Check onboarding state
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!hasSeenOnboarding) {
        if (!mounted) return;
        GlobalAuthGuard.initialNavigationDone = true;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
        return;
      }

      if (!mounted) return;
      GlobalAuthGuard.initialNavigationDone = true;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else if (state is AuthSuccessNeedsProfileSetup) {
      if (!mounted) return;
      GlobalAuthGuard.initialNavigationDone = true;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ProfileSetupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else if (state is AuthSuccessUnpaired || state is AuthSuccessPaired) {
      if (!mounted) return;
      GlobalAuthGuard.initialNavigationDone = true;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _checkAndNavigate();
      },
      child: Scaffold(
        backgroundColor: EmoraColors.background,
        body: Center(
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: EmoraColors.primary.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 8,
                  )
                ],
                gradient: const LinearGradient(
                  colors: [EmoraColors.primary, EmoraColors.secondary],
                ),
              ),
              child: const Center(
                child: Text(
                  'e',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
