// lib/features/pairing/bloc/pairing_bloc.dart
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_handler.dart';
import 'pairing_event.dart';
import 'pairing_state.dart';

class PairingBloc extends Bloc<PairingEvent, PairingState> {
  final SupabaseClient _client = SupabaseHandler.client;

  PairingBloc() : super(PairingInitial()) {
    on<LoadPairingInfo>(_onLoadPairingInfo);
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
  }

  Future<void> _onLoadPairingInfo(
      LoadPairingInfo event, Emitter<PairingState> emit) async {
    emit(PairingLoading());
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        emit(const PairingFailure('User is not authenticated.'));
        return;
      }

      // Check if the old pairing code is still valid
      final response = await _client
          .from('pairing_codes')
          .select()
          .eq('creator_id', currentUserId)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .maybeSingle();

      String myCode;
      if (response != null) {
        myCode = response['code'];
      } else {
        // Generate a new random 6-digit code
        myCode = (Random().nextInt(900000) + 100000).toString();
        final expiresAt = DateTime.now().add(const Duration(minutes: 15)).toUtc();

        // Delete old expired codes first (if any)
        await _client.from('pairing_codes').delete().eq('creator_id', currentUserId);

        // Save the new code
        await _client.from('pairing_codes').insert({
          'code': myCode,
          'creator_id': currentUserId,
          'expires_at': expiresAt.toIso8601String(),
        });
      }

      emit(PairingInfoLoaded(
        myCode: myCode,
        qrData: 'emora://pair?code=$myCode',
      ));
    } catch (e) {
      emit(PairingFailure(e.toString()));
    }
  }

  Future<void> _onConnectRequested(
      ConnectRequested event, Emitter<PairingState> emit) async {
    emit(PairingConnecting());
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        emit(const PairingFailure('User is not authenticated.'));
        return;
      }

      // Query to check the code in DB
      final codeData = await _client
          .from('pairing_codes')
          .select()
          .eq('code', event.code)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .maybeSingle();

      if (codeData == null) {
        emit(const PairingFailure('pairing.error_invalid_code'));
        return;
      }

      final creatorId = codeData['creator_id'];

      // User cannot connect with themselves
      if (creatorId == currentUserId) {
        emit(const PairingFailure('pairing.error_self_code'));
        return;
      }

      // Create a new Couple record
      final coupleResponse = await _client
          .from('couples')
          .insert({
            'user_a_id': creatorId,
            'user_b_id': currentUserId,
            'status': 'Connected',
            'relationship_status': 'Dating',
          })
          .select('id')
          .single();

      final coupleId = coupleResponse['id'];

      // Update couple_id & partner_id for both users
      // Update Creator (User A)
      await _client.from('users').update({
        'partner_id': currentUserId,
        'couple_id': coupleId,
      }).eq('id', creatorId);

      // Update Code Inputter (User B)
      await _client.from('users').update({
        'partner_id': creatorId,
        'couple_id': coupleId,
      }).eq('id', currentUserId);

      // Delete the used pairing code
      await _client.from('pairing_codes').delete().eq('code', event.code);

      emit(PairingSuccess());
    } catch (e) {
      emit(PairingFailure(e.toString()));
    }
  }

  Future<void> _onDisconnectRequested(
      DisconnectRequested event, Emitter<PairingState> emit) async {
    emit(PairingLoading());
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) return;

      final userData = await _client
          .from('users')
          .select('couple_id, partner_id')
          .eq('id', currentUserId)
          .single();

      final coupleId = userData['couple_id'];
      final partnerId = userData['partner_id'];

      if (coupleId != null) {
        // Update Couple status to Disconnected
        await _client
            .from('couples')
            .update({'status': 'Disconnected'})
            .eq('id', coupleId);

        // Clear partner_id and couple_id for both users
        await _client.from('users').update({
          'partner_id': null,
          'couple_id': null,
        }).eq('id', currentUserId);

        if (partnerId != null) {
          await _client.from('users').update({
            'partner_id': null,
            'couple_id': null,
          }).eq('id', partnerId);
        }
      }
      emit(PairingInitial());
    } catch (e) {
      emit(PairingFailure(e.toString()));
    }
  }
}
