// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shake/shake.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/supabase_handler.dart';
import '../../../core/utils/localization.dart';
import '../../../core/constants/routes.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../pairing/bloc/pairing_bloc.dart';
import '../../pairing/bloc/pairing_event.dart';
import '../../pairing/bloc/pairing_state.dart';
import '../../calendar/screens/calendar_tab.dart';
import '../../settings/screens/settings_tab.dart';
import '../../settings/widgets/profile_setup_sheet.dart';
import '../../settings/bloc/theme_bloc.dart';
import '../../settings/bloc/theme_state.dart';
import '../widgets/dynamic_theme_background.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/active_requests_list.dart';
import '../widgets/care_request_sheet.dart';
import '../widgets/couple_widget_card.dart';
import '../widgets/empathy_hints_card.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/hero_bubble_painter.dart';
import '../widgets/mood_selector_sheet.dart';
import '../widgets/baby_hub_card.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;
  ShakeDetector? _shakeDetector;
  int? _lastNudgeTrigger;
  bool _hasAutoOpenedProfileSetup = false;

  @override
  void initState() {
    super.initState();
    // Initialize accelerometer listener to send nudges on shake
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        context.read<DashboardBloc>().add(const SendNudge());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('nudge.sent_success')),
            backgroundColor: EmoraColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      shakeThresholdGravity: 2.7,
    );

    // Fetch pairing info so pairing code is loaded/generated in PairingBloc
    context.read<PairingBloc>().add(LoadPairingInfo());
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  String _getTabTitle(int index, BuildContext context) {
    switch (index) {
      case 0:
        return 'Emora';
      case 1:
        return context.translate('calendar.title');
      case 2:
        return context.translate('settings.title');
      default:
        return 'Emora';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final colors = themeState.themeColors;
    final dashboardState = context.watch<DashboardBloc>().state;

    final isMaleUnpaired = dashboardState is DashboardLoaded &&
        dashboardState.myBioRole == 'Male' &&
        !dashboardState.isPaired;

    Widget mainScaffold = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.surface.withOpacity(0.85),
        elevation: 0,
        title: Text(
          _getTabTitle(_currentTabIndex, context),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: colors.primary,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.sports_esports, color: colors.primary),
            tooltip: context.translate('vent_room.title'),
            onPressed: isMaleUnpaired ? null : () {
              Navigator.pushNamed(context, EmoraRoutes.ventRoom);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: colors.textMuted),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: const [
          DashboardTab(),
          CalendarTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colors.textDark.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: isMaleUnpaired ? null : (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          backgroundColor: colors.surface,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.textMuted,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month),
              label: context.translate('calendar.title'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: context.translate('settings.title'),
            ),
          ],
        ),
      ),
    );

    return BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) {
          if (previous is DashboardLoaded && current is DashboardLoaded) {
            return current.nudgeTrigger > previous.nudgeTrigger ||
                (current.myBioRole == 'Other' && previous.myBioRole != 'Other') ||
                current.isPaired != previous.isPaired;
          }
          if (current is DashboardLoaded && previous is! DashboardLoaded) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state is DashboardLoaded) {
            if (_lastNudgeTrigger != null && state.nudgeTrigger > _lastNudgeTrigger!) {
              HapticFeedback.lightImpact();
            }
            _lastNudgeTrigger = state.nudgeTrigger;

            // Trigger AuthBloc reload when pairing is complete
            if (state.isPaired) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthSuccessUnpaired) {
                context.read<AuthBloc>().add(AppStarted());
              }
            }

            // Check female unpaired onboarding modal
            if (state.myBioRole == 'Female' && !state.isPaired) {
              _checkAndShowFemaleOnboarding(state.nickname);
            }

            if (state.myBioRole == 'Other' && !_hasAutoOpenedProfileSetup) {
              _hasAutoOpenedProfileSetup = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => ProfileSetupSheet(
                    initialBioRole: state.myBioRole,
                    initialCallSign: state.myCallSign,
                    initialPartnerCallSign: state.partnerCallSign,
                    initialRelationshipStatus: state.relationshipStatus,
                  ),
                );
              });
            }
          }
        },
        child: DynamicThemeBackground(
          child: Stack(
            children: [
              mainScaffold,
              if (isMaleUnpaired)
                _buildMaleLockOverlay(context, dashboardState, colors),
            ],
          ),
        ),
      );
  }

  void _checkAndShowFemaleOnboarding(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = SupabaseHandler.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    final key = 'emora_female_onboarding_shown_$currentUserId';
    final shown = prefs.getBool(key) ?? false;
    if (!shown) {
      await prefs.setBool(key, true);
      if (mounted) {
        final themeState = context.read<ThemeBloc>().state;
        _showFemaleOnboardingModal(context, themeState.themeColors);
      }
    }
  }

  void _showFemaleOnboardingModal(BuildContext context, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (sheetContext) {
        return _FemaleOnboardingSheet(colors: colors);
      },
    );
  }

  Widget _buildMaleLockOverlay(
    BuildContext context,
    DashboardLoaded state,
    ThemeColors colors,
  ) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.65),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SafeArea(
              child: Stack(
                children: [
                  // Upper right Logout Button
                  Positioned(
                    top: 10,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                      tooltip: context.translate('pairing.logout'),
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutRequested());
                      },
                    ),
                  ),
                  
                  // Central Locking UI
                  Center(
                    child: BlocBuilder<PairingBloc, PairingState>(
                      builder: (context, pairingState) {
                        String code = '------';
                        if (pairingState is PairingInfoLoaded) {
                          code = pairingState.myCode;
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Beautiful Lock Icon with pulsing glow
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary.withOpacity(0.2),
                                border: Border.all(color: colors.primary, width: 2),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                size: 54,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              context.translate('pairing.male_lock_title'),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            
                            // Description
                            Text(
                              context.translate('pairing.male_lock_desc'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Code Display Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    context.translate('pairing.desc_your_code'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: EmoraColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    code,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                      letterSpacing: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.translate('pairing.male_lock_guide'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: EmoraColors.textMuted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: code));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Sao chép mã ghép đôi thành công!'),
                                          backgroundColor: colors.primary,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(Icons.copy),
                                    label: Text(
                                      context.translate('pairing.copy_code'),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final shareMsg = context.translate('pairing.share_message', {'code': code});
                                      Clipboard.setData(ClipboardData(text: shareMsg));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Sao chép lời mời ghép đôi thành công!'),
                                          backgroundColor: colors.primary,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white, width: 1.5),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    icon: const Icon(Icons.share),
                                    label: Text(
                                      context.translate('pairing.share_code'),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final colors = themeState.themeColors;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return Center(
            child: CircularProgressIndicator(color: colors.primary),
          );
        }

        if (state is DashboardFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage,
                    style: TextStyle(fontSize: 16, color: colors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      context.read<DashboardBloc>().add(const LoadDashboard());
                    },
                    child: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          final partnerMoodColor = EmoraColors.moodColors[state.partnerMood] ?? colors.secondary;
          final partnerMoodName = context.translate('mood.${state.partnerMood}');
          final partnerMoodEmoji = MoodSelectorSheet.moodEmojis[state.partnerMood] ?? '😊';
          final myId = SupabaseHandler.client.auth.currentUser?.id;

          return RefreshIndicator(
            color: colors.primary,
            onRefresh: () async {
              context.read<DashboardBloc>().add(const LoadDashboard());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Partner Status Card
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: colors.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: partnerMoodColor.withOpacity(0.3),
                            child: Text(
                              state.partnerName.isNotEmpty
                                  ? state.partnerName[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.partnerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Đang kết nối cùng bạn',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
 
                    // Hero Bubble Section (Center point of interaction)
                    Center(
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Large Bubble (Partner's Mood)
                            Positioned(
                              left: 10,
                              top: 10,
                              child: FloatingHearts(
                                nudgeTrigger: state.nudgeTrigger,
                                child: HeroBubble(
                                  size: 170.0,
                                  bubbleColor: partnerMoodColor,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Single tap: show sweet message about partner status
                                      final moodText = context.translate('mood.${state.partnerMood}');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${state.partnerName} đang cảm thấy $moodText $partnerMoodEmoji ❤️'),
                                          backgroundColor: colors.primary,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    onDoubleTap: () {
                                      // Send nudge
                                      context.read<DashboardBloc>().add(const SendNudge());
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.translate('nudge.sent_success')),
                                          backgroundColor: colors.primary,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      // Open care requests grid sheet
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => CareRequestSheet(
                                          onTemplateSelected: (templateId) {
                                            context.read<DashboardBloc>().add(
                                                  CreateCareRequest(templateId),
                                                );
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(context.translate('care_requests.success_sent')),
                                                backgroundColor: colors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              partnerMoodEmoji,
                                              style: const TextStyle(fontSize: 48),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              state.partnerName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: colors.textDark,
                                                fontFamily: 'Outfit',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              partnerMoodName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colors.textMuted,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 2. Small Bubble (My Mood)
                            Positioned(
                              right: 15,
                              bottom: 15,
                              child: HeroBubble(
                                size: 100.0,
                                bubbleColor: EmoraColors.moodColors[state.myMood] ?? colors.secondary,
                                child: GestureDetector(
                                  onTap: () {
                                    // Open mood selector sheet
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => MoodSelectorSheet(
                                        currentMood: state.myMood,
                                        onMoodSelected: (newMood) {
                                          context
                                              .read<DashboardBloc>()
                                              .add(UpdateMyMood(newMood));
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            MoodSelectorSheet.moodEmojis[state.myMood] ?? '😊',
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            state.myCallSign.isNotEmpty ? state.myCallSign : 'Bạn',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: colors.textDark,
                                              fontFamily: 'Outfit',
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Trạng thái đối phương: $partnerMoodName $partnerMoodEmoji',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
 
                    // Couple Home Screen Widget Simulator
                    CoupleWidgetCard(
                      partnerName: state.partnerName,
                      partnerMood: state.partnerMood,
                      activeRequests: state.activeRequests,
                      myId: myId,
                    ),
                    const SizedBox(height: 32),
 
                    // Baby Hub Tracker Card
                    const BabyHubCard(),
                    const SizedBox(height: 32),
 
                    // Active Care Requests List
                    ActiveRequestsList(
                      activeRequests: state.activeRequests,
                      myId: myId,
                    ),
                    const SizedBox(height: 32),
 
                    // Empathy Hints Card
                    EmpathyHintsCard(
                      partnerName: state.partnerName,
                      partnerMood: state.partnerMood,
                      partnerBioRole: state.partnerBioRole,
                      isPartnerInPeriod: state.isPartnerInPeriod,
                      isPartnerInPms: state.isPartnerInPms,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTipRow(IconData icon, String text, ThemeColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _FemaleOnboardingSheet extends StatefulWidget {
  final ThemeColors colors;
  const _FemaleOnboardingSheet({Key? key, required this.colors}) : super(key: key);

  @override
  State<_FemaleOnboardingSheet> createState() => _FemaleOnboardingSheetState();
}

class _FemaleOnboardingSheetState extends State<_FemaleOnboardingSheet> {
  int _stage = 1; // 1: Info, 2: Input Code
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _stage == 1 ? _buildStage1(context) : _buildStage2(context),
        ),
      ),
    );
  }

  Widget _buildStage1(BuildContext context) {
    final colors = widget.colors;
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFFFD2C4),
          child: Text('💑', style: TextStyle(fontSize: 36)),
        ),
        const SizedBox(height: 16),
        Text(
          context.translate('pairing.female_onboarding_title'),
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          context.translate('pairing.female_onboarding_desc'),
          style: TextStyle(
            fontSize: 14,
            color: colors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _stage = 2;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: Text(
            context.translate('pairing.pair_now'),
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: colors.textMuted,
          ),
          child: Text(
            context.translate('pairing.later'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStage2(BuildContext context) {
    final colors = widget.colors;
    return BlocConsumer<PairingBloc, PairingState>(
      listener: (context, state) {
        if (state is PairingSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isConnecting = state is PairingConnecting;
        final errorMessage = state is PairingFailure ? state.errorMessage : null;

        return Column(
          key: const ValueKey(2),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.textDark),
                  onPressed: () {
                    setState(() {
                      _stage = 1;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    context.translate('pairing.tab_input_code'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance back button
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.translate('pairing.desc_input_code'),
              style: TextStyle(fontSize: 14, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 10,
                color: colors.textDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                hintText: context.translate('pairing.input_placeholder'),
                hintStyle: const TextStyle(fontSize: 16, letterSpacing: 1, color: EmoraColors.textMuted),
                filled: true,
                fillColor: colors.background,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.secondary, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 2.0),
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage.startsWith('pairing.') ? context.translate(errorMessage) : errorMessage,
                style: const TextStyle(color: EmoraColors.primary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            if (isConnecting)
              const Center(child: CircularProgressIndicator(color: EmoraColors.primary))
            else
              ElevatedButton(
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.length == 6) {
                    context.read<PairingBloc>().add(ConnectRequested(code));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.translate('pairing.connect_btn'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
