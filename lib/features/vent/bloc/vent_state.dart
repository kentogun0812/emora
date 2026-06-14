// lib/features/vent/bloc/vent_state.dart
import 'package:equatable/equatable.dart';

abstract class VentState extends Equatable {
  const VentState();

  @override
  List<Object?> get props => [];
}

class VentInitial extends VentState {
  const VentInitial();
}

class VentLoading extends VentState {
  const VentLoading();
}

class VentLoaded extends VentState {
  final String partnerName;
  final String partnerMood;
  final String? lastReceivedAction;
  final int actionTriggerCounter; // Used to trigger animation key changes in UI
  final String? myId;
  final String? partnerId;
  final String? coupleId;

  const VentLoaded({
    required this.partnerName,
    required this.partnerMood,
    this.lastReceivedAction,
    this.actionTriggerCounter = 0,
    this.myId,
    this.partnerId,
    this.coupleId,
  });

  VentLoaded copyWith({
    String? partnerName,
    String? partnerMood,
    String? lastReceivedAction,
    int? actionTriggerCounter,
    String? myId,
    String? partnerId,
    String? coupleId,
  }) {
    return VentLoaded(
      partnerName: partnerName ?? this.partnerName,
      partnerMood: partnerMood ?? this.partnerMood,
      lastReceivedAction: lastReceivedAction ?? this.lastReceivedAction,
      actionTriggerCounter: actionTriggerCounter ?? this.actionTriggerCounter,
      myId: myId ?? this.myId,
      partnerId: partnerId ?? this.partnerId,
      coupleId: coupleId ?? this.coupleId,
    );
  }

  @override
  List<Object?> get props => [
        partnerName,
        partnerMood,
        lastReceivedAction,
        actionTriggerCounter,
        myId,
        partnerId,
        coupleId,
      ];
}

class VentFailure extends VentState {
  final String errorMessage;

  const VentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
