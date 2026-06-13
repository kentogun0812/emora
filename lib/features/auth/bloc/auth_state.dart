// lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccessUnpaired extends AuthState {
  final String userId;
  final String email;

  const AuthSuccessUnpaired({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
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
