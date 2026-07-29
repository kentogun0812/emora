// lib/features/calendar/bloc/calendar_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_handler.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final SupabaseClient _client = SupabaseHandler.client;

  // Realtime subscription channels
  RealtimeChannel? _periodChannel;
  RealtimeChannel? _journalChannel;
  RealtimeChannel? _settingsChannel;
  RealtimeChannel? _partnerSettingsChannel;

  // Local storage for mock bypass mode
  final List<Map<String, dynamic>> _mockPeriodLogs = [];
  final List<Map<String, dynamic>> _mockJournalEntries = [];
  String _mockMyBioRole = 'Other';
  final Map<String, dynamic> _mockMySettings = {
    'avg_cycle_length': 28,
    'avg_period_length': 5,
    'share_level': 'Full',
  };
  final Map<String, dynamic> _mockPartnerSettings = {
    'avg_cycle_length': 28,
    'avg_period_length': 5,
    'share_level': 'Full',
  };

  CalendarBloc() : super(const CalendarInitial()) {
    _initializeMockData();

    on<LoadCalendar>(_onLoadCalendar);
    on<SavePeriod>(_onSavePeriod);
    on<SaveJournal>(_onSaveJournal);
    on<SaveSettings>(_onSaveSettings);

    on<PeriodLogsUpdated>(_onPeriodLogsUpdated);
    on<RelationsJournalUpdated>(_onRelationsJournalUpdated);
    on<CycleSettingsUpdated>(_onCycleSettingsUpdated);
    on<PartnerCycleSettingsUpdated>(_onPartnerCycleSettingsUpdated);
  }

  void _initializeMockData() {
    final today = DateTime.now();
    
    // Period log from 20 days ago (lasting 5 days)
    final pStart = today.subtract(const Duration(days: 20));
    final pEnd = today.subtract(const Duration(days: 16));
    _mockPeriodLogs.add({
      'id': 'mock-period-1',
      'user_id': 'mock-user-id',
      'start_date': pStart.toIso8601String().split('T')[0],
      'end_date': pEnd.toIso8601String().split('T')[0],
    });

    // Journal entries
    final jDate1 = today.subtract(const Duration(days: 10));
    _mockJournalEntries.add({
      'id': 'mock-journal-1',
      'couple_id': 'mock-couple-id',
      'created_by': 'mock-partner-id',
      'relation_date': jDate1.toIso8601String().split('T')[0],
      'protection_type': 'Protected',
      'notes': 'Loved the movie night ❤️',
    });

    final jDate2 = today.subtract(const Duration(days: 2));
    _mockJournalEntries.add({
      'id': 'mock-journal-2',
      'couple_id': 'mock-couple-id',
      'created_by': 'mock-user-id',
      'relation_date': jDate2.toIso8601String().split('T')[0],
      'protection_type': 'Unprotected',
      'notes': 'Cozy evening',
    });
  }

  Future<void> _onLoadCalendar(
      LoadCalendar event, Emitter<CalendarState> emit) async {
    emit(const CalendarLoading());
    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Emit loaded state with mock data for login bypass mode
        emit(CalendarLoaded(
          periodLogs: List.from(_mockPeriodLogs),
          journalEntries: List.from(_mockJournalEntries),
          mySettings: Map.from(_mockMySettings),
          partnerSettings: Map.from(_mockPartnerSettings),
          myId: null,
          partnerId: null,
          coupleId: null,
          myBioRole: _mockMyBioRole,
        ));
        return;
      }

      // Fetch user profile info
      final myProfile = await _client
          .from('users')
          .select('couple_id, partner_id, bio_role')
          .eq('id', myId)
          .single();

      final coupleId = myProfile['couple_id'] as String?;
      final partnerId = myProfile['partner_id'] as String?;
      final myBioRole = myProfile['bio_role'] as String? ?? 'Other';

      // 1. Fetch/Initialize my cycle settings
      Map<String, dynamic>? mySettings;
      try {
        final settingsRes = await _client
            .from('cycle_settings')
            .select()
            .eq('user_id', myId)
            .maybeSingle();

        if (settingsRes == null) {
          // Create default settings if not exists
          final defaultSettings = {
            'user_id': myId,
            'avg_cycle_length': 28,
            'avg_period_length': 5,
            'share_level': 'Summary',
          };
          final inserted = await _client
              .from('cycle_settings')
              .insert(defaultSettings)
              .select()
              .single();
          mySettings = inserted;
        } else {
          mySettings = settingsRes;
        }
      } catch (e) {
        // Ignore settings query error, use defaults
        mySettings = {
          'user_id': myId,
          'avg_cycle_length': 28,
          'avg_period_length': 5,
          'share_level': 'Summary',
        };
      }

      // 2. Fetch my period logs
      List<Map<String, dynamic>> periodLogs = [];
      try {
        final periodRes = await _client
            .from('period_logs')
            .select()
            .eq('user_id', myId)
            .order('start_date', ascending: false);
        periodLogs = List<Map<String, dynamic>>.from(periodRes);
      } catch (_) {}

      // 3. Fetch partner settings if exists
      Map<String, dynamic>? partnerSettings;
      if (partnerId != null) {
        try {
          final partnerSettingsRes = await _client
              .from('cycle_settings')
              .select()
              .eq('user_id', partnerId)
              .maybeSingle();
          partnerSettings = partnerSettingsRes;
        } catch (_) {}

        // If partner share level is Full, fetch partner's period logs and combine them
        if (partnerSettings != null && partnerSettings['share_level'] == 'Full') {
          try {
            final partnerPeriods = await _client
                .from('period_logs')
                .select()
                .eq('user_id', partnerId)
                .order('start_date', ascending: false);
            periodLogs.addAll(List<Map<String, dynamic>>.from(partnerPeriods));
          } catch (_) {}
        }
      }

      // 4. Fetch shared relations journal
      List<Map<String, dynamic>> journalEntries = [];
      if (coupleId != null) {
        try {
          final journalRes = await _client
              .from('relations_journal')
              .select()
              .eq('couple_id', coupleId)
              .order('relation_date', ascending: false);
          journalEntries = List<Map<String, dynamic>>.from(journalRes);
        } catch (_) {}
      }

      // Clean up previous subscriptions if any
      await _cleanupChannels();

      // Set up realtime channels
      _setupRealtimeSubscriptions(myId, partnerId, coupleId);

      emit(CalendarLoaded(
        periodLogs: periodLogs,
        journalEntries: journalEntries,
        mySettings: mySettings,
        partnerSettings: partnerSettings,
        myId: myId,
        partnerId: partnerId,
        coupleId: coupleId,
        myBioRole: myBioRole,
      ));
    } catch (e) {
      emit(CalendarFailure(e.toString()));
    }
  }

  Future<void> _onSavePeriod(
      SavePeriod event, Emitter<CalendarState> emit) async {
    final currentState = state;
    if (currentState is! CalendarLoaded) return;

    final startStr = event.startDate.toIso8601String().split('T')[0];
    final endStr = event.endDate?.toIso8601String().split('T')[0];

    try {
      if (currentState.myId == null) {
        // Local state update in bypass mode
        final index = _mockPeriodLogs.indexWhere((log) => log['start_date'] == startStr);
        final newLog = {
          'id': index != -1 ? _mockPeriodLogs[index]['id'] : 'mock-period-${DateTime.now().millisecondsSinceEpoch}',
          'user_id': 'mock-user-id',
          'start_date': startStr,
          'end_date': endStr,
        };

        if (index != -1) {
          _mockPeriodLogs[index] = newLog;
        } else {
          _mockPeriodLogs.add(newLog);
        }

        emit(currentState.copyWith(periodLogs: List.from(_mockPeriodLogs)));
        return;
      }

      // Supabase database update
      await _client.from('period_logs').upsert({
        'user_id': currentState.myId,
        'start_date': startStr,
        'end_date': endStr,
      });

      // Manually trigger reload to immediately sync changes
      add(const LoadCalendar());
    } catch (e) {
      emit(CalendarFailure(e.toString()));
    }
  }

  Future<void> _onSaveJournal(
      SaveJournal event, Emitter<CalendarState> emit) async {
    final currentState = state;
    if (currentState is! CalendarLoaded) return;

    final dateStr = event.relationDate.toIso8601String().split('T')[0];

    try {
      if (currentState.myId == null) {
        // Local state update in bypass mode
        final index = _mockJournalEntries.indexWhere((entry) => entry['relation_date'] == dateStr);
        final newEntry = {
          'id': index != -1 ? _mockJournalEntries[index]['id'] : 'mock-journal-${DateTime.now().millisecondsSinceEpoch}',
          'couple_id': 'mock-couple-id',
          'created_by': 'mock-user-id',
          'relation_date': dateStr,
          'protection_type': event.protectionType,
          'notes': event.notes,
        };

        if (index != -1) {
          _mockJournalEntries[index] = newEntry;
        } else {
          _mockJournalEntries.add(newEntry);
        }

        emit(currentState.copyWith(journalEntries: List.from(_mockJournalEntries)));
        return;
      }

      if (currentState.coupleId == null) {
        throw Exception("Cannot write shared journal without a connected couple.");
      }

      // Supabase database update
      await _client.from('relations_journal').upsert({
        'couple_id': currentState.coupleId,
        'created_by': currentState.myId,
        'relation_date': dateStr,
        'protection_type': event.protectionType,
        'notes': event.notes,
      });

      // Manually trigger reload to immediately sync changes
      add(const LoadCalendar());
    } catch (e) {
      emit(CalendarFailure(e.toString()));
    }
  }

  Future<void> _onSaveSettings(
      SaveSettings event, Emitter<CalendarState> emit) async {
    final currentState = state;
    if (currentState is! CalendarLoaded) return;

    try {
      if (currentState.myId == null) {
        // Local state update in bypass mode
        _mockMySettings['avg_cycle_length'] = event.cycleLength;
        _mockMySettings['avg_period_length'] = event.periodLength;
        _mockMySettings['share_level'] = event.shareLevel;

        emit(currentState.copyWith(mySettings: Map.from(_mockMySettings)));
        return;
      }

      // Supabase database update
      await _client.from('cycle_settings').upsert({
        'user_id': currentState.myId,
        'avg_cycle_length': event.cycleLength,
        'avg_period_length': event.periodLength,
        'share_level': event.shareLevel,
      });

      // Manually trigger reload to immediately sync changes
      add(const LoadCalendar());
    } catch (e) {
      emit(CalendarFailure(e.toString()));
    }
  }

  void _onPeriodLogsUpdated(PeriodLogsUpdated event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(periodLogs: event.periodLogs));
    }
  }

  void _onRelationsJournalUpdated(RelationsJournalUpdated event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(journalEntries: event.journalEntries));
    }
  }

  void _onCycleSettingsUpdated(CycleSettingsUpdated event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(mySettings: event.settings));
    }
  }

  void _onPartnerCycleSettingsUpdated(PartnerCycleSettingsUpdated event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(partnerSettings: event.settings));
    }
  }

  void _setupRealtimeSubscriptions(String myId, String? partnerId, String? coupleId) {
    // 1. Period Logs Channel (for my logs and partner logs if Full shared)
    _periodChannel = _client
        .channel('realtime_period_logs')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'period_logs',
          callback: (payload) {
            // Hot reload calendar to sync changes safely
            add(const LoadCalendar());
          },
        );
    _periodChannel?.subscribe();

    // 2. Relations Journal Channel (for the couple's journal logs)
    if (coupleId != null) {
      _journalChannel = _client
          .channel('realtime_relations_journal')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'relations_journal',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'couple_id',
              value: coupleId,
            ),
            callback: (payload) {
              add(const LoadCalendar());
            },
          );
      _journalChannel?.subscribe();
    }

    // 3. User Cycle Settings Channel
    _settingsChannel = _client
        .channel('realtime_my_cycle_settings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cycle_settings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: myId,
          ),
          callback: (payload) {
            add(const LoadCalendar());
          },
        );
    _settingsChannel?.subscribe();

    // 4. Partner Cycle Settings Channel
    if (partnerId != null) {
      _partnerSettingsChannel = _client
          .channel('realtime_partner_cycle_settings')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cycle_settings',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: partnerId,
            ),
            callback: (payload) {
              add(const LoadCalendar());
            },
          );
      _partnerSettingsChannel?.subscribe();
    }
  }

  Future<void> _cleanupChannels() async {
    if (_periodChannel != null) {
      await _client.removeChannel(_periodChannel!);
      _periodChannel = null;
    }
    if (_journalChannel != null) {
      await _client.removeChannel(_journalChannel!);
      _journalChannel = null;
    }
    if (_settingsChannel != null) {
      await _client.removeChannel(_settingsChannel!);
      _settingsChannel = null;
    }
    if (_partnerSettingsChannel != null) {
      await _client.removeChannel(_partnerSettingsChannel!);
      _partnerSettingsChannel = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanupChannels();
    return super.close();
  }
}
