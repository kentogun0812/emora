// lib/features/pairing/bloc/pairing_state.dart
import 'package:equatable/equatable.dart';

abstract class PairingState extends Equatable {
  const PairingState();

  @override
  List<Object?> get props => [];
}

class PairingInitial extends PairingState {}

class PairingLoading extends PairingState {}

class PairingInfoLoaded extends PairingState {
  final String myCode;
  final String qrData;

  const PairingInfoLoaded({required this.myCode, required this.qrData});

  @override
  List<Object?> get props => [myCode, qrData];
}

class PairingConnecting extends PairingState {}

class PairingSuccess extends PairingState {}

class PairingFailure extends PairingState {
  final String errorMessage;

  const PairingFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
