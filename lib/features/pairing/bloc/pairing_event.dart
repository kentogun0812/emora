// lib/features/pairing/bloc/pairing_event.dart
import 'package:equatable/equatable.dart';

abstract class PairingEvent extends Equatable {
  const PairingEvent();

  @override
  List<Object?> get props => [];
}

class LoadPairingInfo extends PairingEvent {}

class ConnectRequested extends PairingEvent {
  final String code;

  const ConnectRequested(this.code);

  @override
  List<Object?> get props => [code];
}

class DisconnectRequested extends PairingEvent {}
