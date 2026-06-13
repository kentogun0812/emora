// lib/features/dashboard/bloc/dashboard_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_handler.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SupabaseClient _client = SupabaseHandler.client;
  RealtimeChannel? _partnerChannel;
  RealtimeChannel? _nudgeChannel;
  RealtimeChannel? _careRequestsChannel;

  // Local storage for mock bypass mode
  final List<Map<String, dynamic>> _mockCareRequests = [];

  DashboardBloc() : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<UpdateMyMood>(_onUpdateMyMood);
    on<PartnerMoodChanged>(_onPartnerMoodChanged);
    on<SendNudge>(_onSendNudge);
    on<NudgeReceived>(_onNudgeReceived);
    on<CreateCareRequest>(_onCreateCareRequest);
    on<UpdateRequestStatus>(_onUpdateRequestStatus);
    on<CareRequestsUpdated>(_onCareRequestsUpdated);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Initialize mock care requests if empty
        if (_mockCareRequests.isEmpty) {
          _mockCareRequests.add({
            'id': 'mock-req-1',
            'couple_id': 'mock-couple-id',
            'sender_id': 'mock-partner-id',
            'template_id': 'need_hug',
            'status': 'Pending',
            'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toUtc().toIso8601String(),
            'updated_at': DateTime.now().subtract(const Duration(minutes: 15)).toUtc().toIso8601String(),
          });
        }
        
        // Emit loaded state with mock data for debugging bypass mode
        emit(DashboardLoaded(
          myMood: 'Calm',
          partnerMood: 'Calm',
          partnerName: 'Mock Partner',
          nudgeTrigger: 0,
          activeRequests: List.from(_mockCareRequests),
        ));
        return;
      }

      // Fetch my profile
      final myProfile = await _client
          .from('users')
          .select('current_mood, couple_id, partner_id')
          .eq('id', myId)
          .single();

      final myMood = myProfile['current_mood'] as String? ?? 'Calm';
      final coupleId = myProfile['couple_id'] as String?;
      final partnerId = myProfile['partner_id'] as String?;

      String partnerMood = 'Calm';
      String partnerName = 'Partner';
      List<Map<String, dynamic>> activeRequests = [];

      // Clean up existing channels if reloading
      await _cleanupChannels();

      if (partnerId != null) {
        // Fetch partner profile
        final partnerProfile = await _client
            .from('users')
            .select('email, current_mood')
            .eq('id', partnerId)
            .single();

        partnerMood = partnerProfile['current_mood'] as String? ?? 'Calm';
        
        final partnerEmail = partnerProfile['email'] as String? ?? '';
        if (partnerEmail.contains('@')) {
          partnerName = partnerEmail.split('@')[0];
        } else {
          partnerName = partnerEmail;
        }

        // Subscribe to partner's table updates
        _partnerChannel = _client
            .channel('partner_mood_changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'users',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'id',
                value: partnerId,
              ),
              callback: (payload) {
                final newMood = payload.newRecord['current_mood'] as String?;
                if (newMood != null) {
                  add(PartnerMoodChanged(newMood));
                }
              },
            );
        _partnerChannel?.subscribe();
      }

      if (coupleId != null) {
        // Subscribe to nudge realtime broadcast
        _nudgeChannel = _client.channel('couple_nudge_$coupleId');
        _nudgeChannel?.onBroadcast(
          event: 'nudge',
          callback: (payload) {
            add(const NudgeReceived());
          },
        );
        _nudgeChannel?.subscribe();

        // 1. Fetch active care requests
        final res = await _client
            .from('care_requests')
            .select()
            .eq('couple_id', coupleId)
            .or('status.eq.Pending,status.eq.Accepted')
            .order('created_at', ascending: false);

        final allRequests = List<Map<String, dynamic>>.from(res);
        final now = DateTime.now();

        // Filter: Keep only 'Accepted' or 'Pending' requests younger than 24 hours
        activeRequests = allRequests.where((req) {
          final status = req['status'] as String;
          if (status == 'Pending') {
            final createdAt = DateTime.parse(req['created_at'] as String);
            return now.difference(createdAt).inHours < 24;
          }
          return true;
        }).toList();

        // 2. Subscribe to care_requests realtime table updates
        _careRequestsChannel = _client
            .channel('realtime_care_requests')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'care_requests',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'couple_id',
                value: coupleId,
              ),
              callback: (payload) {
                add(const LoadDashboard());
              },
            );
        _careRequestsChannel?.subscribe();
      }

      emit(DashboardLoaded(
        myMood: myMood,
        partnerMood: partnerMood,
        partnerName: partnerName,
        nudgeTrigger: 0,
        activeRequests: activeRequests,
      ));
    } catch (e) {
      emit(DashboardFailure(e.toString()));
    }
  }

  Future<void> _onUpdateMyMood(
      UpdateMyMood event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) return;

      // Optimistically update the UI state
      emit(currentState.copyWith(myMood: event.mood));

      // Persist user mood update to database
      await _client.from('users').update({
        'current_mood': event.mood,
        'mood_updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', myId);
    } catch (e) {
      // In case of error, reload the dashboard state
      add(const LoadDashboard());
    }
  }

  void _onPartnerMoodChanged(
      PartnerMoodChanged event, Emitter<DashboardState> emit) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(partnerMood: event.mood));
    }
  }

  Future<void> _onSendNudge(
      SendNudge event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      if (_nudgeChannel != null) {
        await _nudgeChannel!.sendBroadcastMessage(
          event: 'nudge',
          payload: {'sender_id': _client.auth.currentUser?.id},
        );
      }
    } catch (_) {
      // Silent error ignore for broadcast failures
    }
  }

  void _onNudgeReceived(NudgeReceived event, Emitter<DashboardState> emit) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(
        nudgeTrigger: currentState.nudgeTrigger + 1,
      ));
    }
  }

  Future<void> _onCreateCareRequest(
      CreateCareRequest event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Mock data bypass mode
        final newReq = {
          'id': 'mock-req-${DateTime.now().millisecondsSinceEpoch}',
          'couple_id': 'mock-couple-id',
          'sender_id': 'mock-user-id',
          'template_id': event.templateId,
          'status': 'Pending',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };
        _mockCareRequests.insert(0, newReq);
        emit(currentState.copyWith(activeRequests: List.from(_mockCareRequests)));
        return;
      }

      final profile = await _client
          .from('users')
          .select('couple_id')
          .eq('id', myId)
          .single();
      final coupleId = profile['couple_id'] as String?;

      if (coupleId != null) {
        await _client.from('care_requests').insert({
          'couple_id': coupleId,
          'sender_id': myId,
          'template_id': event.templateId,
          'status': 'Pending',
        });
        add(const LoadDashboard());
      }
    } catch (_) {}
  }

  Future<void> _onUpdateRequestStatus(
      UpdateRequestStatus event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Mock data bypass mode
        final index = _mockCareRequests.indexWhere((r) => r['id'] == event.requestId);
        if (index != -1) {
          if (event.newStatus == 'Completed' || event.newStatus == 'Canceled') {
            _mockCareRequests.removeAt(index);
          } else {
            _mockCareRequests[index] = {
              ..._mockCareRequests[index],
              'status': event.newStatus,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            };
          }
          emit(currentState.copyWith(activeRequests: List.from(_mockCareRequests)));
        }
        return;
      }

      await _client
          .from('care_requests')
          .update({
            'status': event.newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', event.requestId);

      add(const LoadDashboard());
    } catch (_) {}
  }

  void _onCareRequestsUpdated(
      CareRequestsUpdated event, Emitter<DashboardState> emit) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(activeRequests: event.requests));
    }
  }

  Future<void> _cleanupChannels() async {
    if (_partnerChannel != null) {
      await _client.removeChannel(_partnerChannel!);
      _partnerChannel = null;
    }
    if (_nudgeChannel != null) {
      await _client.removeChannel(_nudgeChannel!);
      _nudgeChannel = null;
    }
    if (_careRequestsChannel != null) {
      await _client.removeChannel(_careRequestsChannel!);
      _careRequestsChannel = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanupChannels();
    return super.close();
  }
}
