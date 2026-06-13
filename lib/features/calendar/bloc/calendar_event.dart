// lib/features/calendar/bloc/calendar_event.dart
import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendar extends CalendarEvent {
  const LoadCalendar();
}

class SavePeriod extends CalendarEvent {
  final DateTime startDate;
  final DateTime? endDate;

  const SavePeriod({required this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class SaveJournal extends CalendarEvent {
  final DateTime relationDate;
  final String protectionType;
  final String? notes;

  const SaveJournal({
    required this.relationDate,
    required this.protectionType,
    this.notes,
  });

  @override
  List<Object?> get props => [relationDate, protectionType, notes];
}

class SaveSettings extends CalendarEvent {
  final int cycleLength;
  final int periodLength;
  final String shareLevel;

  const SaveSettings({
    required this.cycleLength,
    required this.periodLength,
    required this.shareLevel,
  });

  @override
  List<Object?> get props => [cycleLength, periodLength, shareLevel];
}

class PeriodLogsUpdated extends CalendarEvent {
  final List<Map<String, dynamic>> periodLogs;

  const PeriodLogsUpdated(this.periodLogs);

  @override
  List<Object?> get props => [periodLogs];
}

class RelationsJournalUpdated extends CalendarEvent {
  final List<Map<String, dynamic>> journalEntries;

  const RelationsJournalUpdated(this.journalEntries);

  @override
  List<Object?> get props => [journalEntries];
}

class CycleSettingsUpdated extends CalendarEvent {
  final Map<String, dynamic>? settings;

  const CycleSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class PartnerCycleSettingsUpdated extends CalendarEvent {
  final Map<String, dynamic>? settings;

  const PartnerCycleSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}
