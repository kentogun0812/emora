// lib/features/vent/bloc/vent_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_handler.dart';
import 'vent_event.dart';
import 'vent_state.dart';

class VentBloc extends Bloc<VentEvent, VentState> {
  final SupabaseClient _client = SupabaseHandler.client;
  RealtimeChannel? _ventChannel;

  VentBloc() : super(const VentInitial()) {
    on<LoadVentRoom>(_onLoadVentRoom);
    on<SendVentAction>(_onSendVentAction);
    on<ReceiveVentAction>(_onReceiveVentAction);
  }

  Future<void> _onLoadVentRoom(
      LoadVentRoom event, Emitter<VentState> emit) async {
    emit(const VentLoading());
    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Bypass mock mode
        emit(const VentLoaded(
          partnerName: 'Mock Partner',
          partnerMood: 'Calm',
          myId: null,
          partnerId: null,
          coupleId: null,
        ));
        return;
      }

      // Fetch user profile info
      final myProfile = await _client
          .from('users')
          .select('couple_id, partner_id')
          .eq('id', myId)
          .single();

      final coupleId = myProfile['couple_id'] as String?;
      final partnerId = myProfile['partner_id'] as String?;

      String partnerName = 'Partner';
      String partnerMood = 'Calm';

      if (partnerId != null) {
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
      }

      // Clean up previous channel
      await _cleanupChannel();

      // Subscribe to Supabase Realtime Broadcast channel
      if (coupleId != null) {
        _ventChannel = _client.channel('couple_venting_$coupleId');
        _ventChannel?.onBroadcast(
          event: 'vent_action',
          callback: (payload) {
            final action = payload['action'] as String?;
            final sender = payload['sender_id'] as String?;
            if (action != null && sender != myId) {
              add(ReceiveVentAction(action));
            }
          },
        );
        _ventChannel?.subscribe();
      }

      emit(VentLoaded(
        partnerName: partnerName,
        partnerMood: partnerMood,
        myId: myId,
        partnerId: partnerId,
        coupleId: coupleId,
      ));
    } catch (e) {
      emit(VentFailure(e.toString()));
    }
  }

  Future<void> _onSendVentAction(
      SendVentAction event, Emitter<VentState> emit) async {
    final currentState = state;
    if (currentState is! VentLoaded) return;

    try {
      if (currentState.myId == null) {
        // Simulated response in bypass mode after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(ReceiveVentAction(event.actionType));
          }
        });
        return;
      }

      if (_ventChannel != null) {
        await _ventChannel!.sendBroadcastMessage(
          event: 'vent_action',
          payload: {
            'action': event.actionType,
            'sender_id': currentState.myId,
          },
        );
      }
    } catch (_) {}
  }

  void _onReceiveVentAction(
      ReceiveVentAction event, Emitter<VentState> emit) {
    final currentState = state;
    if (currentState is VentLoaded) {
      emit(currentState.copyWith(
        lastReceivedAction: event.actionType,
        actionTriggerCounter: currentState.actionTriggerCounter + 1,
      ));
    }
  }

  Future<void> _cleanupChannel() async {
    if (_ventChannel != null) {
      await _client.removeChannel(_ventChannel!);
      _ventChannel = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanupChannel();
    return super.close();
  }
}
