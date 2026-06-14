// lib/features/vent/bloc/vent_event.dart
import 'package:equatable/equatable.dart';

abstract class VentEvent extends Equatable {
  const VentEvent();

  @override
  List<Object?> get props => [];
}

class LoadVentRoom extends VentEvent {
  const LoadVentRoom();
}

class SendVentAction extends VentEvent {
  final String actionType;

  const SendVentAction(this.actionType);

  @override
  List<Object?> get props => [actionType];
}

class ReceiveVentAction extends VentEvent {
  final String actionType;

  const ReceiveVentAction(this.actionType);

  @override
  List<Object?> get props => [actionType];
}
