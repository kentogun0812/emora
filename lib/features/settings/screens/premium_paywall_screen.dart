// lib/features/settings/screens/premium_paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({Key? key}) : super(key: key);

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  bool _isLoading = false;

  void _triggerMockCheckout(BuildContext context) {
    setState(() {
      _isLoading = true;
    });

    // Simulate standard payment gateway validation (1.5 seconds)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Dispatch event to upgrade
      context.read<ThemeBloc>().add(const UpgradeToPremium());

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final isDark = context.read<ThemeBloc>().state.themeName == 'Midnight Starlight';
          final textColors = context.read<ThemeBloc>().state.themeColors;

          return AlertDialog(
            backgroundColor: textColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.translate('premium.success_title'),
                    style: TextStyle(
                      color: textColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              context.translate('premium.success_desc'),
              style: TextStyle(
                color: textColors.textMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Dismiss success dialog
                  Navigator.of(context).pop(); // Back to Settings Tab
                },
                child: Text(
                  context.translate('premium.close'),
                  style: TextStyle(
                    color: textColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final colors = state.themeColors;
        final isDark = state.themeName == 'Midnight Starlight';

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              context.translate('premium.title'),
              style: TextStyle(
                color: colors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Decorative background gradient circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.1),
                  ),
                ),
              ),

              // Paywall main content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Gold Crown / Stars Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 72,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "EMORA PREMIUM",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: colors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.translate('premium.desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Feature List (Glassmorphism card)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.1),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textDark.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            context,
                            Icons.color_lens,
                            context.translate('premium.features_theme'),
                            colors,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildFeatureItem(
                            context,
                            Icons.sentiment_very_satisfied,
                            context.translate('premium.features_vent'),
                            colors,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          _buildFeatureItem(
                            context,
                            Icons.block,
                            context.translate('premium.features_ads'),
                            colors,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Checkout / Trial Button
                    if (state.isPremium) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.translate('premium.success_desc'),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Option to Reset to Free for testing convenience
                      TextButton(
                        onPressed: () {
                          context.read<ThemeBloc>().add(const ResetToFree());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã chuyển về trạng thái Miễn phí để kiểm thử"),
                            ),
                          );
                        },
                        child: Text(
                          "Khôi phục trạng thái Miễn phí (Kiểm thử)",
                          style: TextStyle(color: colors.textMuted),
                        ),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _triggerMockCheckout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          context.translate('premium.upgrade_btn'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.translate('premium.trial_desc'),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Full Screen Processing Loader
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SpinKitDoubleBounce(
                          color: Colors.amber,
                          size: 80.0,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.translate('premium.processing'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
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

  Widget _buildFeatureItem(
      BuildContext context, IconData icon, String text, ThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
