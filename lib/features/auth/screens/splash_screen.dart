// lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.login);
        } else if (state is AuthSuccessUnpaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.pairing);
        } else if (state is AuthSuccessPaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.dashboard);
        }
      },
      child: Scaffold(
        backgroundColor: EmoraColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
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
              const SizedBox(height: 40),
              Text(
                context.translate('app_name'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: EmoraColors.textDark,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.translate('slogan'),
                style: const TextStyle(
                  fontSize: 16,
                  color: EmoraColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
