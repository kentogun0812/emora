// lib/features/dashboard/bloc/dashboard_state.dart
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final String myMood;
  final String partnerMood;
  final String partnerName;
  final int nudgeTrigger; // Counter to trigger floating hearts in UI

  const DashboardLoaded({
    required this.myMood,
    required this.partnerMood,
    required this.partnerName,
    this.nudgeTrigger = 0,
  });

  DashboardLoaded copyWith({
    String? myMood,
    String? partnerMood,
    String? partnerName,
    int? nudgeTrigger,
  }) {
    return DashboardLoaded(
      myMood: myMood ?? this.myMood,
      partnerMood: partnerMood ?? this.partnerMood,
      partnerName: partnerName ?? this.partnerName,
      nudgeTrigger: nudgeTrigger ?? this.nudgeTrigger,
    );
  }

  @override
  List<Object?> get props => [myMood, partnerMood, partnerName, nudgeTrigger];
}

class DashboardFailure extends DashboardState {
  final String errorMessage;

  const DashboardFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
