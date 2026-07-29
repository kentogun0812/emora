// lib/features/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../core/network/supabase_handler.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _client = SupabaseHandler.client;
  StreamSubscription? _authSubscription;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequestedApple>(_onLoginRequestedApple);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionChanged>(_onSessionChanged);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<CompleteProfileSetup>(_onCompleteProfileSetup);

    // Listen to Supabase auth state changes (OAuth redirects, logout, token refreshes)
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      add(SessionChanged(data.session));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<AuthState> _determineAuthState(User user) async {
    final response = await _client
        .from('users')
        .select('couple_id, nickname, date_of_birth, bio_role, relationship_status')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return AuthSuccessNeedsProfileSetup(
        userId: user.id,
        email: user.email ?? '',
      );
    }

    final hasProfile = response['nickname'] != null &&
        response['date_of_birth'] != null &&
        response['bio_role'] != null &&
        response['bio_role'] != 'Other' &&
        response['relationship_status'] != null;

    if (!hasProfile) {
      return AuthSuccessNeedsProfileSetup(
        userId: user.id,
        email: user.email ?? '',
      );
    }

    if (response['couple_id'] != null) {
      return AuthSuccessPaired(
        userId: user.id,
        email: user.email ?? '',
        coupleId: response['couple_id'],
      );
    }

    return AuthSuccessUnpaired(
      userId: user.id,
      email: user.email ?? '',
      bioRole: response['bio_role'] ?? 'Other',
    );
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final nextState = await _determineAuthState(session.user);
      emit(nextState);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSessionChanged(
      SessionChanged event, Emitter<AuthState> emit) async {
    final session = event.session;
    if (session == null) {
      emit(AuthUnauthenticated());
      return;
    }

    // Skip redundant processing if session belongs to currently authenticated user
    final currentState = state;
    if (currentState is AuthSuccessPaired && currentState.userId == session.user.id) {
      return;
    }
    if (currentState is AuthSuccessUnpaired && currentState.userId == session.user.id) {
      return;
    }
    if (currentState is AuthSuccessNeedsProfileSetup && currentState.userId == session.user.id) {
      return;
    }

    emit(AuthLoading());
    try {
      final nextState = await _determineAuthState(session.user);
      emit(nextState);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onCompleteProfileSetup(
      CompleteProfileSetup event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        emit(const AuthFailure('User is not authenticated.'));
        return;
      }

      final callSign = event.bioRole == 'Male' ? 'Anh' : (event.bioRole == 'Female' ? 'Em' : 'Tôi');
      final partnerCallSign = event.bioRole == 'Male' ? 'Em' : (event.bioRole == 'Female' ? 'Anh' : 'Đối phương');

      await _client.from('users').update({
        'nickname': event.nickname,
        'date_of_birth': event.dateOfBirth.toIso8601String().split('T')[0],
        'bio_role': event.bioRole,
        'relationship_status': event.relationshipStatus,
        'call_sign': callSign,
        'partner_call_sign': partnerCallSign,
      }).eq('id', currentUserId);

      final user = _client.auth.currentUser;
      if (user != null) {
        final nextState = await _determineAuthState(user);
        emit(nextState);
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSendOtpRequested(
      SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _client.auth.signInWithOtp(
        email: event.email,
        shouldCreateUser: event.shouldCreateUser,
      );
      emit(AuthOtpSent(email: event.email, shouldCreateUser: event.shouldCreateUser));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
      VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _client.auth.verifyOTP(
        type: event.type,
        email: event.email,
        token: event.token,
      );
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
