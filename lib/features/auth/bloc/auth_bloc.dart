// lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../core/network/supabase_handler.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _client = SupabaseHandler.client;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequestedGoogle>(_onLoginRequestedGoogle);
    on<LoginRequestedApple>(_onLoginRequestedApple);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final user = session.user;
      final userId = user.id;

      // Query couple_id from public.users to determine pairing status
      final response = await _client
          .from('users')
          .select('couple_id')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['couple_id'] != null) {
        emit(AuthSuccessPaired(
          userId: userId,
          email: user.email ?? '',
          coupleId: response['couple_id'],
        ));
      } else {
        emit(AuthSuccessUnpaired(
          userId: userId,
          email: user.email ?? '',
        ));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLoginRequestedGoogle(
      LoginRequestedGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Perform Google OAuth login via Supabase Auth SDK
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.emora://login-callback',
      );
      if (!success) {
        emit(const AuthFailure('OAuth flow initialization failed.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLoginRequestedApple(
      LoginRequestedApple event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Perform Apple OAuth login via Supabase Auth SDK
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.emora://login-callback',
      );
      if (!success) {
        emit(const AuthFailure('OAuth flow initialization failed.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _client.auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
