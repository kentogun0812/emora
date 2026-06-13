// lib/features/calendar/screens/calendar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../widgets/period_log_sheet.dart';
import '../widgets/relations_journal_sheet.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({Key? key}) : super(key: key);

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load calendar data when tab is initialized
    context.read<CalendarBloc>().add(const LoadCalendar());
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        if (state is CalendarLoading || state is CalendarInitial) {
          return const Center(
            child: CircularProgressIndicator(color: EmoraColors.primary),
          );
        }

        if (state is CalendarFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: EmoraColors.primary),
                const SizedBox(height: 16),
                Text(state.errorMessage, style: const TextStyle(color: EmoraColors.textDark)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<CalendarBloc>().add(const LoadCalendar());
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is CalendarLoaded) {
          final loggedPeriods = state.loggedPeriodDays;
          final predictedPeriods = state.predictedPeriodDays;
          final fertileDays = state.predictedFertileDays;
          final journalMap = state.journalMap;

          // Check logs for currently selected day
          final selectedDayKey = _selectedDay.toIso8601String().split('T')[0];
          final hasJournal = journalMap.containsKey(selectedDayKey);
          final journalEntry = journalMap[selectedDayKey];

          final isPeriodDay = loggedPeriods.any((d) => _isSameDay(d, _selectedDay));
          final isPredictedPeriod = predictedPeriods.any((d) => _isSameDay(d, _selectedDay));

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CalendarBloc>().add(const LoadCalendar());
            },
            color: EmoraColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Calendar Section Card
                    Container(
                      decoration: BoxDecoration(
                        color: EmoraColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: EmoraColors.primary.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TableCalendar(
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        // Styling header
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EmoraColors.textDark,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left, color: EmoraColors.primary),
                          rightChevronIcon: Icon(Icons.chevron_right, color: EmoraColors.primary),
                        ),
                        // Days styling
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(fontWeight: FontWeight.w600, color: EmoraColors.textMuted),
                          weekendStyle: TextStyle(fontWeight: FontWeight.w600, color: EmoraColors.primary),
                        ),
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                        ),
                        // Custom cell builders
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            return _buildCalendarCell(day, loggedPeriods, predictedPeriods, fertileDays, journalMap);
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return _buildCalendarCell(day, loggedPeriods, predictedPeriods, fertileDays, journalMap, isToday: true);
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return _buildCalendarCell(day, loggedPeriods, predictedPeriods, fertileDays, journalMap, isSelected: true);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Legend Panel
                    _buildLegendPanel(),
                    const SizedBox(height: 24),

                    // Daily Details Card
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
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "${context.translate('calendar.title')} - ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Current Logs Status
                          if (isPeriodDay)
                            _buildStatusRow(Icons.water_drop, context.translate('calendar.period_log'), EmoraColors.primary),
                          if (isPredictedPeriod && !isPeriodDay)
                            _buildStatusRow(Icons.water_drop_outlined, "Dự báo ngày chu kỳ", EmoraColors.primary.withOpacity(0.6)),
                          
                          if (hasJournal) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: journalEntry!['protection_type'] == 'Protected'
                                    ? EmoraColors.tertiary.withOpacity(0.1)
                                    : EmoraColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: journalEntry['protection_type'] == 'Protected'
                                      ? EmoraColors.tertiary.withOpacity(0.3)
                                      : EmoraColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        journalEntry['protection_type'] == 'Protected' ? '🛡️' : '⚠️',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        journalEntry['protection_type'] == 'Protected'
                                            ? context.translate('calendar.relation_protected')
                                            : context.translate('calendar.relation_unprotected'),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  if (journalEntry['notes'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      journalEntry['notes'],
                                      style: const TextStyle(fontSize: 13, color: EmoraColors.textDark),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          if (!isPeriodDay && !isPredictedPeriod && !hasJournal)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Chưa có ghi chép nào trong ngày này.",
                                style: TextStyle(color: EmoraColors.textMuted, fontSize: 14),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Quick Log Actions
                          Row(
                            children: [
                              // Log Cycle Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmoraColors.secondary,
                                    foregroundColor: EmoraColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(Icons.calendar_today, size: 18),
                                  label: Text(
                                    context.translate('calendar.period_log'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  onPressed: () {
                                    // Open period log sheet
                                    DateTime? existingEnd;
                                    final match = state.periodLogs.firstWhere(
                                      (log) => log['start_date'] == _selectedDay.toIso8601String().split('T')[0],
                                      orElse: () => {},
                                    );
                                    if (match.isNotEmpty && match['end_date'] != null) {
                                      existingEnd = DateTime.parse(match['end_date']);
                                    }

                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => PeriodLogSheet(
                                        initialDate: _selectedDay,
                                        existingEndDate: existingEnd,
                                        onSave: (start, end) {
                                          context.read<CalendarBloc>().add(
                                                SavePeriod(startDate: start, endDate: end),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(context.translate('calendar.success_save')),
                                              backgroundColor: EmoraColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Log Shared Journal Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmoraColors.tertiary.withOpacity(0.2),
                                    foregroundColor: EmoraColors.tertiary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: const Icon(Icons.favorite_border, size: 18),
                                  label: Text(
                                    context.translate('calendar.relation_journal'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (_) => RelationsJournalSheet(
                                        date: _selectedDay,
                                        initialProtectionType: journalEntry?['protection_type'],
                                        initialNotes: journalEntry?['notes'],
                                        onSave: (type, notes) {
                                          context.read<CalendarBloc>().add(
                                                SaveJournal(
                                                  relationDate: _selectedDay,
                                                  protectionType: type,
                                                  notes: notes,
                                                ),
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(context.translate('calendar.success_save')),
                                              backgroundColor: EmoraColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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

  Widget _buildCalendarCell(
    DateTime day,
    List<DateTime> loggedPeriods,
    List<DateTime> predictedPeriods,
    List<DateTime> fertileDays,
    Map<String, Map<String, dynamic>> journalMap, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final dayKey = day.toIso8601String().split('T')[0];
    final hasJournal = journalMap.containsKey(dayKey);

    final isPeriod = loggedPeriods.any((d) => _isSameDay(d, day));
    final isPredicted = predictedPeriods.any((d) => _isSameDay(d, day));
    final isFertile = fertileDays.any((d) => _isSameDay(d, day));

    BoxDecoration? cellDecoration;
    TextStyle textStyle = const TextStyle(color: EmoraColors.textDark, fontSize: 14);

    if (isSelected) {
      cellDecoration = BoxDecoration(
        color: EmoraColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: EmoraColors.primary.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      );
      textStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
    } else if (isPeriod) {
      cellDecoration = const BoxDecoration(
        color: EmoraColors.secondary, // Soft Peach background
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(color: EmoraColors.textDark, fontWeight: FontWeight.bold, fontSize: 14);
    } else if (isPredicted) {
      cellDecoration = BoxDecoration(
        color: EmoraColors.secondary.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: EmoraColors.primary.withOpacity(0.4), width: 1.5, style: BorderStyle.solid),
      );
      textStyle = const TextStyle(color: EmoraColors.textDark, fontWeight: FontWeight.bold, fontSize: 14);
    } else if (isFertile) {
      cellDecoration = BoxDecoration(
        color: EmoraColors.tertiary.withOpacity(0.15), // Lavender background
        shape: BoxShape.circle,
      );
      textStyle = const TextStyle(color: EmoraColors.textDark, fontSize: 14);
    } else if (isToday) {
      cellDecoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: EmoraColors.primary, width: 1.5),
      );
      textStyle = const TextStyle(color: EmoraColors.primary, fontWeight: FontWeight.bold, fontSize: 14);
    }

    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: cellDecoration,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: textStyle,
          ),
          if (hasJournal)
            Positioned(
              bottom: 2,
              child: Icon(
                Icons.all_inclusive,
                size: 10,
                color: isSelected ? Colors.white : EmoraColors.tertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EmoraColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chú giải lịch",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: EmoraColors.textDark),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _buildLegendItem(EmoraColors.secondary, "Kỳ kinh đã lưu"),
              _buildLegendItem(
                EmoraColors.secondary.withOpacity(0.25),
                "Dự báo kỳ kinh tiếp theo",
                borderColor: EmoraColors.primary.withOpacity(0.4),
              ),
              _buildLegendItem(EmoraColors.tertiary.withOpacity(0.15), "Cửa sổ thụ thai (màu tím)"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.all_inclusive, size: 14, color: EmoraColors.tertiary),
                  const SizedBox(width: 6),
                  const Text("Nhật ký quan hệ", style: TextStyle(fontSize: 12, color: EmoraColors.textDark)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, {Color? borderColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: EmoraColors.textDark),
        ),
      ],
    );
  }

  Widget _buildStatusRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, color: EmoraColors.textDark, fontSize: 14),
        ),
      ],
    );
  }
}
