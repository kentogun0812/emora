// lib/features/settings/screens/settings_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../pairing/bloc/pairing_bloc.dart';
import '../../pairing/bloc/pairing_event.dart';
import '../../calendar/bloc/calendar_bloc.dart';
import '../../calendar/bloc/calendar_event.dart';
import '../../calendar/bloc/calendar_state.dart';

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
                      gradient: const LinearGradient(
                        colors: [EmoraColors.secondary, EmoraColors.background],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: EmoraColors.primary.withOpacity(0.06),
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
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: EmoraColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Bên nhau mỗi ngày, thấu hiểu mỗi giây',
                          style: TextStyle(
                            fontSize: 14,
                            color: EmoraColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cycle Parameters Section
                  const Text(
                    "Cấu hình chu kỳ cá nhân",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: EmoraColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: EmoraColors.primary.withOpacity(0.04),
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
                            labelStyle: const TextStyle(color: EmoraColors.textMuted, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: EmoraColors.secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: EmoraColors.secondary.withOpacity(0.5)),
                            ),
                          ),
                          items: List.generate(36, (index) => index + 15).map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text("$value ngày", style: const TextStyle(color: EmoraColors.textDark)),
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
                            labelStyle: const TextStyle(color: EmoraColors.textMuted, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: EmoraColors.secondary.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: EmoraColors.secondary.withOpacity(0.5)),
                            ),
                          ),
                          items: List.generate(8, (index) => index + 3).map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text("$value ngày", style: const TextStyle(color: EmoraColors.textDark)),
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

                  // Privacy Settings Section
                  Text(
                    context.translate('settings.cycle_privacy'),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EmoraColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: EmoraColors.primary.withOpacity(0.04),
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
                        ),
                        const Divider(height: 1, color: EmoraColors.background),
                        _buildPrivacyOption(
                          'Summary',
                          '👁️',
                          context.translate('settings.share_summary'),
                          'Chỉ hiển thị trạng thái tổng quan (đang trong kỳ kinh/PMS).',
                        ),
                        const Divider(height: 1, color: EmoraColors.background),
                        _buildPrivacyOption(
                          'None',
                          '🔒',
                          context.translate('settings.share_none'),
                          'Bảo mật tuyệt đối, không chia sẻ bất kỳ thông tin nào.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EmoraColors.primary,
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
                          backgroundColor: EmoraColors.primary,
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
                      foregroundColor: EmoraColors.primary,
                      side: const BorderSide(color: EmoraColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {
                      _showDisconnectConfirmationDialog(context);
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
          color: isSelected ? EmoraColors.secondary.withOpacity(0.25) : Colors.transparent,
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
                      color: isSelected ? EmoraColors.primary : EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: EmoraColors.textMuted),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _shareLevel,
              activeColor: EmoraColors.primary,
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

  void _showDisconnectConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: EmoraColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            context.translate('settings.disconnect'),
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
          ),
          content: const Text("Bạn có chắc chắn muốn hủy kết nối với đối phương? Các dữ liệu dùng chung sẽ được ẩn đi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                context.translate('common.cancel'),
                style: const TextStyle(color: EmoraColors.textMuted, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PairingBloc>().add(DisconnectRequested());
                context.read<AuthBloc>().add(AppStarted()); // Reload state
              },
              child: const Text(
                "Đồng ý",
                style: TextStyle(color: EmoraColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
