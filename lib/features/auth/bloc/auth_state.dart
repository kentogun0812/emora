// lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccessNeedsProfileSetup extends AuthState {
  final String userId;
  final String email;

  const AuthSuccessNeedsProfileSetup({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
}

class AuthSuccessUnpaired extends AuthState {
  final String userId;
  final String email;
  final String bioRole;

  const AuthSuccessUnpaired({
    required this.userId,
    required this.email,
    required this.bioRole,
  });

  @override
  List<Object?> get props => [userId, email, bioRole];
}

class AuthSuccessPaired extends AuthState {
  final String userId;
  final String email;
  final String coupleId;

  const AuthSuccessPaired({
    required this.userId,
    required this.email,
    required this.coupleId,
  });

  @override
  List<Object?> get props => [userId, email, coupleId];
}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String email;
  final bool shouldCreateUser;

  const AuthOtpSent({required this.email, required this.shouldCreateUser});

  @override
  List<Object?> get props => [email, shouldCreateUser];
}
