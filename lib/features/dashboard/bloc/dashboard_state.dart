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
  final List<Map<String, dynamic>> activeRequests;

  const DashboardLoaded({
    required this.myMood,
    required this.partnerMood,
    required this.partnerName,
    this.nudgeTrigger = 0,
    this.activeRequests = const [],
  });

  DashboardLoaded copyWith({
    String? myMood,
    String? partnerMood,
    String? partnerName,
    int? nudgeTrigger,
    List<Map<String, dynamic>>? activeRequests,
  }) {
    return DashboardLoaded(
      myMood: myMood ?? this.myMood,
      partnerMood: partnerMood ?? this.partnerMood,
      partnerName: partnerName ?? this.partnerName,
      nudgeTrigger: nudgeTrigger ?? this.nudgeTrigger,
      activeRequests: activeRequests ?? this.activeRequests,
    );
  }

  @override
  List<Object?> get props => [myMood, partnerMood, partnerName, nudgeTrigger, activeRequests];
}

class DashboardFailure extends DashboardState {
  final String errorMessage;

  const DashboardFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
