// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessUnpaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.pairing);
        } else if (state is AuthSuccessPaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.dashboard);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('login.error_failed')),
              backgroundColor: EmoraColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              // Dynamic Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: EmoraColors.bgGradient,
                ),
              ),
              // Dim glowing circles behind to create depth effect
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmoraColors.primary.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmoraColors.secondary.withOpacity(0.15),
                  ),
                ),
              ),
              // Main Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      // App Name & Slogan
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [EmoraColors.primary, EmoraColors.secondary],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'e',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: EmoraColors.textLight,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              context.translate('app_name'),
                              style: const TextStyle(
                                fontSize: 40,
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
                      const Spacer(),
                      // Solid Cozy Haven Card with Soft Shadow
                      Container(
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: EmoraColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: EmoraColors.primary.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              context.translate('login.welcome'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.translate('login.desc'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: EmoraColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            if (isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: EmoraColors.primary,
                                ),
                              )
                            else ...[
                              // Google Login Button
                              _buildOAuthButton(
                                context: context,
                                label: context.translate('login.sign_in_google'),
                                iconPath: 'assets/icons/google.png',
                                onPressed: () {
                                  context.read<AuthBloc>().add(LoginRequestedGoogle());
                                },
                                isGoogle: true,
                              ),
                              const SizedBox(height: 16),
                              // Apple Login Button
                              _buildOAuthButton(
                                context: context,
                                label: context.translate('login.sign_in_apple'),
                                iconPath: 'assets/icons/apple.png',
                                onPressed: () {
                                  context.read<AuthBloc>().add(LoginRequestedApple());
                                },
                                isGoogle: false,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOAuthButton({
    required BuildContext context,
    required String label,
    required String iconPath,
    required VoidCallback onPressed,
    required bool isGoogle,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: isGoogle ? Colors.black87 : Colors.white,
        backgroundColor: isGoogle ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: isGoogle ? const BorderSide(color: Color(0xFFE2E8F0), width: 1.5) : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGoogle ? Icons.g_mobiledata : Icons.apple,
            size: 26,
            color: isGoogle ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
