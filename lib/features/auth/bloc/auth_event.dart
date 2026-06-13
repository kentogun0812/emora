// lib/features/auth/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequestedGoogle extends AuthEvent {}

class LoginRequestedApple extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
