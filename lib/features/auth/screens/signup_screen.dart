// lib/features/auth/screens/signup_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  Timer? _resendTimer;
  int _secondsRemaining = 0;

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        _resendTimer?.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessNeedsProfileSetup) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.profileSetup);
        } else if (state is AuthSuccessUnpaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.dashboard);
        } else if (state is AuthSuccessPaired) {
          Navigator.pushReplacementNamed(context, EmoraRoutes.dashboard);
        } else if (state is AuthFailure) {
          String errorMsg = context.translate('login.error_failed');
          if (state.errorMessage.contains('Invalid OTP') || 
              state.errorMessage.contains('invalid token') || 
              state.errorMessage.contains('incorrect') ||
              state.errorMessage.toLowerCase().contains('otp')) {
            errorMsg = context.translate('signup.error_invalid_otp');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: EmoraColors.primary,
            ),
          );
        } else if (state is AuthOtpSent) {
          _startResendTimer();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isOtpSent = state is AuthOtpSent;
        final currentEmail = isOtpSent ? state.email : '';

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
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // App Name & Slogan (Pushed slightly up, compact layout)
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
                            const SizedBox(height: 16),
                            Text(
                              context.translate('app_name'),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.translate('slogan'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: EmoraColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                context.translate('signup.welcome'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: EmoraColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                context.translate('signup.desc'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: EmoraColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              
                              if (isLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: CircularProgressIndicator(
                                      color: EmoraColors.primary,
                                    ),
                                  ),
                                )
                              else if (isOtpSent) ...[
                                // Waiting for OTP view
                                Text(
                                  context.translate('signup.otp_sent_to').replaceAll('{email}', currentEmail),
                                  style: const TextStyle(fontSize: 13, color: EmoraColors.textMuted),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                    color: EmoraColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '• • • • • •',
                                    hintStyle: const TextStyle(letterSpacing: 6, color: EmoraColors.textMuted),
                                    prefixIcon: const Icon(Icons.lock_outline, color: EmoraColors.primary),
                                    filled: true,
                                    fillColor: EmoraColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty || int.tryParse(val.trim()) == null) {
                                      return context.translate('signup.invalid_otp');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmoraColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(VerifyOtpRequested(
                                        currentEmail,
                                        _otpController.text.trim(),
                                        type: OtpType.signup,
                                      ));
                                    }
                                  },
                                  child: Text(
                                    context.translate('signup.verify_otp'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(LogoutRequested());
                                        _otpController.clear();
                                      },
                                      child: Text(
                                        context.translate('signup.back_to_email'),
                                        style: const TextStyle(color: EmoraColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _secondsRemaining == 0
                                          ? () {
                                              context.read<AuthBloc>().add(SendOtpRequested(
                                                currentEmail,
                                                shouldCreateUser: true,
                                              ));
                                            }
                                          : null,
                                      child: Text(
                                        _secondsRemaining == 0
                                            ? context.translate('login.resend_otp')
                                            : context.translate('login.resend_wait').replaceAll('{seconds}', _secondsRemaining.toString()),
                                        style: TextStyle(
                                          color: _secondsRemaining == 0 ? EmoraColors.primary : EmoraColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Email signup view
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: EmoraColors.textDark),
                                  decoration: InputDecoration(
                                    hintText: context.translate('login.email_hint'),
                                    hintStyle: const TextStyle(color: EmoraColors.textMuted),
                                    prefixIcon: const Icon(Icons.email_outlined, color: EmoraColors.primary),
                                    filled: true,
                                    fillColor: EmoraColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty || !val.contains('@')) {
                                      return context.translate('login.invalid_email');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmoraColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(SendOtpRequested(
                                        _emailController.text.trim(),
                                        shouldCreateUser: true,
                                      ));
                                    }
                                  },
                                  child: Text(
                                    context.translate('signup.send_otp'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        context.translate('pairing.desc_input_code').startsWith('H') ? 'Hoặc' : 'Or',
                                        style: const TextStyle(color: EmoraColors.textMuted, fontSize: 13),
                                      ),
                                    ),
                                    const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildOAuthButton(
                                  context: context,
                                  label: context.translate('signup.sign_up_apple'),
                                  iconPath: 'assets/icons/apple.png',
                                  onPressed: () {
                                    context.read<AuthBloc>().add(LoginRequestedApple());
                                  },
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
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
                                    },
                                    child: Text(
                                      context.translate('signup.already_have_account'),
                                      style: const TextStyle(
                                        color: EmoraColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.apple,
            size: 26,
            color: Colors.white,
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
