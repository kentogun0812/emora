// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shake/shake.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/supabase_handler.dart';
import '../../../core/utils/localization.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../calendar/screens/calendar_tab.dart';
import '../../settings/screens/settings_tab.dart';
import '../../settings/bloc/theme_bloc.dart';
import '../../settings/bloc/theme_state.dart';
import '../widgets/dynamic_theme_background.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/active_requests_list.dart';
import '../widgets/care_request_sheet.dart';
import '../widgets/couple_widget_card.dart';
import '../widgets/floating_hearts.dart';
import '../widgets/hero_bubble_painter.dart';
import '../widgets/mood_selector_sheet.dart';
import '../widgets/baby_hub_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;
  ShakeDetector? _shakeDetector;

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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Temporarily commented out to bypass login
        // if (state is AuthUnauthenticated) {
        //   Navigator.pushReplacementNamed(context, EmoraRoutes.login);
        // }
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) {
          if (previous is DashboardLoaded && current is DashboardLoaded) {
            return current.nudgeTrigger > previous.nudgeTrigger;
          }
          return false;
        },
        listener: (context, state) {
          // Trigger physical haptic feedback when a nudge is received
          HapticFeedback.lightImpact();
        },
        child: DynamicThemeBackground(
          child: Scaffold(
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
                  onPressed: () {
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
                onTap: (index) {
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
                      child: FloatingHearts(
                        nudgeTrigger: state.nudgeTrigger,
                        child: HeroBubble(
                          bubbleColor: partnerMoodColor,
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
                                      style: const TextStyle(fontSize: 54),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      partnerMoodName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textDark,
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

                    // Interaction Tips Card
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: colors.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.secondary.withOpacity(0.5), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Tương tác nhanh Cozy Haven',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildTipRow(Icons.touch_app, 'Chạm 1 lần vào bong bóng để đổi cảm xúc của bạn.', colors),
                          const SizedBox(height: 8),
                          _buildTipRow(Icons.favorite, 'Chạm đúp vào bong bóng để gửi Nudge yêu thương.', colors),
                          const SizedBox(height: 8),
                          _buildTipRow(Icons.hourglass_empty, 'Nhấn giữ bong bóng để gửi Yêu cầu chăm sóc (Care Request).', colors),
                        ],
                      ),
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
