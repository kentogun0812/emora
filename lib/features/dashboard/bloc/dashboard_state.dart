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
  final String nickname;
  final String dateOfBirth;
  final String myBioRole;
  final String myCallSign;
  final String partnerCallSign;
  final String partnerBioRole;
  final bool isPartnerInPeriod;
  final bool isPartnerInPms;
  final String relationshipStatus;
  final bool isPaired;

  const DashboardLoaded({
    required this.myMood,
    required this.partnerMood,
    required this.partnerName,
    this.nudgeTrigger = 0,
    this.activeRequests = const [],
    this.nickname = '',
    this.dateOfBirth = '',
    this.myBioRole = 'Other',
    this.myCallSign = 'Đối phương',
    this.partnerCallSign = 'Bạn',
    this.partnerBioRole = 'Other',
    this.isPartnerInPeriod = false,
    this.isPartnerInPms = false,
    this.relationshipStatus = 'Dating',
    this.isPaired = false,
  });

  DashboardLoaded copyWith({
    String? myMood,
    String? partnerMood,
    String? partnerName,
    int? nudgeTrigger,
    List<Map<String, dynamic>>? activeRequests,
    String? nickname,
    String? dateOfBirth,
    String? myBioRole,
    String? myCallSign,
    String? partnerCallSign,
    String? partnerBioRole,
    bool? isPartnerInPeriod,
    bool? isPartnerInPms,
    String? relationshipStatus,
    bool? isPaired,
  }) {
    return DashboardLoaded(
      myMood: myMood ?? this.myMood,
      partnerMood: partnerMood ?? this.partnerMood,
      partnerName: partnerName ?? this.partnerName,
      nudgeTrigger: nudgeTrigger ?? this.nudgeTrigger,
      activeRequests: activeRequests ?? this.activeRequests,
      nickname: nickname ?? this.nickname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      myBioRole: myBioRole ?? this.myBioRole,
      myCallSign: myCallSign ?? this.myCallSign,
      partnerCallSign: partnerCallSign ?? this.partnerCallSign,
      partnerBioRole: partnerBioRole ?? this.partnerBioRole,
      isPartnerInPeriod: isPartnerInPeriod ?? this.isPartnerInPeriod,
      isPartnerInPms: isPartnerInPms ?? this.isPartnerInPms,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      isPaired: isPaired ?? this.isPaired,
    );
  }

  @override
  List<Object?> get props => [
        myMood,
        partnerMood,
        partnerName,
        nudgeTrigger,
        activeRequests,
        nickname,
        dateOfBirth,
        myBioRole,
        myCallSign,
        partnerCallSign,
        partnerBioRole,
        isPartnerInPeriod,
        isPartnerInPms,
        relationshipStatus,
        isPaired,
      ];
}

class DashboardFailure extends DashboardState {
  final String errorMessage;

  const DashboardFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
