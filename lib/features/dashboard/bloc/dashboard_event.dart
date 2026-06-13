// lib/features/dashboard/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class UpdateMyMood extends DashboardEvent {
  final String mood;

  const UpdateMyMood(this.mood);

  @override
  List<Object?> get props => [mood];
}

class PartnerMoodChanged extends DashboardEvent {
  final String mood;

  const PartnerMoodChanged(this.mood);

  @override
  List<Object?> get props => [mood];
}

class SendNudge extends DashboardEvent {
  const SendNudge();
}

class NudgeReceived extends DashboardEvent {
  const NudgeReceived();
}
