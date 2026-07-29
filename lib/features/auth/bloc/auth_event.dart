// lib/features/auth/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequestedApple extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class SessionChanged extends AuthEvent {
  final Session? session;
  const SessionChanged(this.session);

  @override
  List<Object?> get props => [session];
}

class SendOtpRequested extends AuthEvent {
  final String email;
  final bool shouldCreateUser;
  const SendOtpRequested(this.email, {this.shouldCreateUser = true});

  @override
  List<Object?> get props => [email, shouldCreateUser];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String token;
  final OtpType type;
  const VerifyOtpRequested(this.email, this.token, {this.type = OtpType.email});

  @override
  List<Object?> get props => [email, token, type];
}

class CompleteProfileSetup extends AuthEvent {
  final String nickname;
  final DateTime dateOfBirth;
  final String bioRole;
  final String relationshipStatus;

  const CompleteProfileSetup({
    required this.nickname,
    required this.dateOfBirth,
    required this.bioRole,
    required this.relationshipStatus,
  });

  @override
  List<Object?> get props => [nickname, dateOfBirth, bioRole, relationshipStatus];
}
