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

class CreateCareRequest extends DashboardEvent {
  final String templateId;

  const CreateCareRequest(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

class UpdateRequestStatus extends DashboardEvent {
  final String requestId;
  final String newStatus;

  const UpdateRequestStatus({required this.requestId, required this.newStatus});

  @override
  List<Object?> get props => [requestId, newStatus];
}

class CareRequestsUpdated extends DashboardEvent {
  final List<Map<String, dynamic>> requests;

  const CareRequestsUpdated(this.requests);

  @override
  List<Object?> get props => [requests];
}

class UpdateProfile extends DashboardEvent {
  final String nickname;
  final DateTime dateOfBirth;
  final String bioRole;
  final String callSign;
  final String partnerCallSign;
  final String relationshipStatus;

  const UpdateProfile({
    required this.nickname,
    required this.dateOfBirth,
    required this.bioRole,
    required this.callSign,
    required this.partnerCallSign,
    required this.relationshipStatus,
  });

  @override
  List<Object?> get props => [nickname, dateOfBirth, bioRole, callSign, partnerCallSign, relationshipStatus];
}
