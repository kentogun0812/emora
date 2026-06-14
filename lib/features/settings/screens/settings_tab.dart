// lib/features/settings/screens/settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../pairing/bloc/pairing_bloc.dart';
import '../../pairing/bloc/pairing_event.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/bloc/calendar_event.dart';
import '../../calendar/bloc/calendar_state.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  int _cycleLength = 28;
  int _periodLength = 5;
  String _shareLevel = 'Summary';

  @override
  void initState() {
    super.initState();
    // Load settings from current calendar state if available
    final calendarState = context.read<CalendarBloc>().state;
    if (calendarState is CalendarLoaded) {
      final settings = calendarState.activeSettings;
      _cycleLength = settings['avg_cycle_length'] as int? ?? 28;
      _periodLength = settings['avg_period_length'] as int? ?? 5;
      _shareLevel = settings['share_level'] as String? ?? 'Summary';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final colors = themeState.themeColors;
    final isDark = themeState.themeName == 'Midnight Starlight';

    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is CalendarLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Days Together Card (Hero section of settings)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.secondary, colors.background],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            '❤️',
                            style: TextStyle(fontSize: 36),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.translate('settings.days_together').replaceAll('{days}', '365'),
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bên nhau mỗi ngày, thấu hiểu mỗi giây',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Premium Upgrade Banner (if free)
                  if (!themeState.isPremium) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, EmoraRoutes.premiumPaywall);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.translate('settings.upgrade_premium'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.translate('premium.desc'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Dynamic Theme Selector
                  Text(
                    context.translate('settings.theme_title'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: EmoraColors.themes.keys.map((themeName) {
                        final previewColors = EmoraColors.themes[themeName]!;
                        final isSelected = themeState.themeName == themeName;
                        final isPremiumTheme = themeName != 'Cozy Haven';
                        final isLocked = isPremiumTheme && !themeState.isPremium;

                        return GestureDetector(
                          onTap: () {
                            if (isLocked) {
                              Navigator.pushNamed(context, EmoraRoutes.premiumPaywall);
                            } else {
                              context.read<ThemeBloc>().add(ChangeTheme(themeName));
                            }
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: previewColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : (isDark ? Colors.white24 : Colors.black12),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textDark.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        themeName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: previewColors.textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isLocked)
                                      const Icon(Icons.lock, size: 14, color: Colors.amber)
                                    else if (isSelected)
                                      Icon(Icons.check_circle, size: 14, color: colors.primary),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: previewColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: previewColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: previewColors.background,
                                        border: Border.all(color: Colors.black12, width: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cycle Parameters Section
                  Text(
                    "Cấu hình chu kỳ cá nhân",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Cycle Length Dropdown
                        DropdownButtonFormField<int>(
                          value: _cycleLength,
                          decoration: InputDecoration(
                            labelText: context.translate('settings.cycle_length'),
                            labelStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.secondary.withOpacity(0.5)),
                            ),
                          ),
                          items: List.generate(36, (index) => index + 15).map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text("$value ngày", style: TextStyle(color: colors.textDark)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _cycleLength = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Period Length Dropdown
                        DropdownButtonFormField<int>(
                          value: _periodLength,
                          decoration: InputDecoration(
                            labelText: context.translate('settings.period_length'),
                            labelStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.secondary.withOpacity(0.5)),
                            ),
                          ),
                          items: List.generate(8, (index) => index + 3).map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text("$value ngày", style: TextStyle(color: colors.textDark)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _periodLength = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Baby Hub Section
                  Text(
                    "Trợ lý bé yêu",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Text('👶', style: TextStyle(fontSize: 22)),
                          title: Text(
                            "Thiết lập hồ sơ bé yêu",
                            style: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
                          ),
                          subtitle: const Text("Chỉnh sửa tên, giới tính và ngày sinh của bé", style: TextStyle(fontSize: 12)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: colors.textMuted),
                          onTap: () {
                            Navigator.pushNamed(context, EmoraRoutes.babySetup);
                          },
                        ),
                        Divider(height: 1, color: colors.background),
                        ListTile(
                          leading: const Text('💉', style: TextStyle(fontSize: 22)),
                          title: Text(
                            "Lịch tiêm chủng của bé",
                            style: TextStyle(fontWeight: FontWeight.bold, color: colors.textDark),
                          ),
                          subtitle: const Text("Theo dõi tiến trình tiêm chủng vắc-xin", style: TextStyle(fontSize: 12)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: colors.textMuted),
                          onTap: () {
                            Navigator.pushNamed(context, EmoraRoutes.vaccineTracker);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Privacy Settings Section
                  Text(
                    context.translate('settings.cycle_privacy'),
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPrivacyOption(
                          'Full',
                          '🛡️',
                          context.translate('settings.share_full'),
                          'Chia sẻ chi tiết lịch và các ngày dự báo cho đối phương.',
                          colors,
                        ),
                        Divider(height: 1, color: colors.background),
                        _buildPrivacyOption(
                          'Summary',
                          '👁️',
                          context.translate('settings.share_summary'),
                          'Chỉ hiển thị trạng thái tổng quan (đang trong kỳ kinh/PMS).',
                          colors,
                        ),
                        Divider(height: 1, color: colors.background),
                        _buildPrivacyOption(
                          'None',
                          '🔒',
                          context.translate('settings.share_none'),
                          'Bảo mật tuyệt đối, không chia sẻ bất kỳ thông tin nào.',
                          colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.read<CalendarBloc>().add(
                            SaveSettings(
                              cycleLength: _cycleLength,
                              periodLength: _periodLength,
                              shareLevel: _shareLevel,
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.translate('calendar.success_save')),
                          backgroundColor: colors.primary,
                        ),
                      );
                    },
                    child: Text(
                      context.translate('settings.save_settings'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      _showDisconnectConfirmationDialog(context, colors);
                    },
                    child: Text(
                      context.translate('settings.disconnect'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPrivacyOption(
    String value,
    String emoji,
    String title,
    String subtitle,
    ThemeColors colors,
  ) {
    final isSelected = _shareLevel == value;

    return InkWell(
      onTap: () {
        setState(() {
          _shareLevel = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.secondary.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colors.primary : colors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _shareLevel,
              activeColor: colors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _shareLevel = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectConfirmationDialog(BuildContext context, ThemeColors colors) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            context.translate('settings.disconnect'),
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: colors.textDark),
          ),
          content: Text(
            "Bạn có chắc chắn muốn hủy kết nối với đối phương? Các dữ liệu dùng chung sẽ được ẩn đi.",
            style: TextStyle(color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                context.translate('common.cancel'),
                style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PairingBloc>().add(DisconnectRequested());
                context.read<AuthBloc>().add(AppStarted()); // Reload state
              },
              child: Text(
                "Đồng ý",
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
