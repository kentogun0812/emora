// lib/features/calendar/bloc/calendar_state.dart
import 'package:equatable/equatable.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  final List<Map<String, dynamic>> periodLogs;
  final List<Map<String, dynamic>> journalEntries;
  final Map<String, dynamic>? mySettings;
  final Map<String, dynamic>? partnerSettings;
  final String? myId;
  final String? partnerId;
  final String? coupleId;
  final String myBioRole;

  const CalendarLoaded({
    required this.periodLogs,
    required this.journalEntries,
    this.mySettings,
    this.partnerSettings,
    this.myId,
    this.partnerId,
    this.coupleId,
    this.myBioRole = 'Other',
  });

  CalendarLoaded copyWith({
    List<Map<String, dynamic>>? periodLogs,
    List<Map<String, dynamic>>? journalEntries,
    Map<String, dynamic>? mySettings,
    Map<String, dynamic>? partnerSettings,
    String? myId,
    String? partnerId,
    String? coupleId,
    String? myBioRole,
  }) {
    return CalendarLoaded(
      periodLogs: periodLogs ?? this.periodLogs,
      journalEntries: journalEntries ?? this.journalEntries,
      mySettings: mySettings ?? this.mySettings,
      partnerSettings: partnerSettings ?? this.partnerSettings,
      myId: myId ?? this.myId,
      partnerId: partnerId ?? this.partnerId,
      coupleId: coupleId ?? this.coupleId,
      myBioRole: myBioRole ?? this.myBioRole,
    );
  }

  // Get active cycle settings for prediction (either my settings or partner settings if female logs exist)
  Map<String, dynamic> get activeSettings {
    // If user has settings, use it, otherwise use defaults
    return mySettings ?? {
      'avg_cycle_length': 28,
      'avg_period_length': 5,
      'share_level': 'Summary',
    };
  }

  // Helper: Get all actual period dates logged (inclusive of start and end dates)
  List<DateTime> get loggedPeriodDays {
    final list = <DateTime>[];
    for (var log in periodLogs) {
      final startStr = log['start_date'] as String;
      final endStr = log['end_date'] as String?;
      
      final start = DateTime.parse(startStr);
      final end = endStr != null ? DateTime.parse(endStr) : start;

      // Expand dates
      var current = DateTime(start.year, start.month, start.day);
      final last = DateTime(end.year, end.month, end.day);
      while (current.isBefore(last) || current.isAtSameMomentAs(last)) {
        list.add(current);
        current = current.add(const Duration(days: 1));
      }
    }
    return list;
  }

  // Helper: Calculate predicted period days for the next 3 cycles
  List<DateTime> get predictedPeriodDays {
    if (periodLogs.isEmpty) return [];

    // Find the latest period start date
    DateTime? latestStart;
    for (var log in periodLogs) {
      final startStr = log['start_date'] as String;
      final start = DateTime.parse(startStr);
      if (latestStart == null || start.isAfter(latestStart)) {
        latestStart = start;
      }
    }

    if (latestStart == null) return [];

    final settings = activeSettings;
    final int cycleLength = settings['avg_cycle_length'] as int? ?? 28;
    final int periodLength = settings['avg_period_length'] as int? ?? 5;

    final list = <DateTime>[];

    // Predict next 3 cycles
    for (int i = 1; i <= 3; i++) {
      final cycleStart = latestStart.add(Duration(days: cycleLength * i));
      for (int d = 0; d < periodLength; d++) {
        final day = cycleStart.add(Duration(days: d));
        list.add(DateTime(day.year, day.month, day.day));
      }
    }

    return list;
  }

  // Helper: Calculate predicted fertile days for the next 3 cycles
  List<DateTime> get predictedFertileDays {
    if (periodLogs.isEmpty) return [];

    // Find latest start
    DateTime? latestStart;
    for (var log in periodLogs) {
      final startStr = log['start_date'] as String;
      final start = DateTime.parse(startStr);
      if (latestStart == null || start.isAfter(latestStart)) {
        latestStart = start;
      }
    }

    if (latestStart == null) return [];

    final settings = activeSettings;
    final int cycleLength = settings['avg_cycle_length'] as int? ?? 28;

    final list = <DateTime>[];

    // Predict next 3 cycles
    for (int i = 1; i <= 3; i++) {
      final nextPeriodStart = latestStart.add(Duration(days: cycleLength * i));
      // Ovulation day = next period start - 14 days
      final ovulationDay = nextPeriodStart.subtract(const Duration(days: 14));
      // Fertile window = 5 days before ovulation + 1 day after ovulation (7 days total)
      for (int d = -5; d <= 1; d++) {
        final day = ovulationDay.add(Duration(days: d));
        list.add(DateTime(day.year, day.month, day.day));
      }
    }

    return list;
  }

  // Helper: Map relation journal entries by date string (YYYY-MM-DD) for quick lookup
  Map<String, Map<String, dynamic>> get journalMap {
    final map = <String, Map<String, dynamic>>{};
    for (var entry in journalEntries) {
      final dateStr = entry['relation_date'] as String;
      map[dateStr] = entry;
    }
    return map;
  }

  @override
  List<Object?> get props => [
        periodLogs,
        journalEntries,
        mySettings,
        partnerSettings,
        myId,
        partnerId,
        coupleId,
        myBioRole,
      ];
}

class CalendarFailure extends CalendarState {
  final String errorMessage;

  const CalendarFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
