// lib/features/baby/bloc/baby_state.dart
import 'package:equatable/equatable.dart';

class BabyProfile extends Equatable {
  final String id;
  final String coupleId;
  final String name;
  final String gender;
  final DateTime dob;
  final String emoji;

  const BabyProfile({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.gender,
    required this.dob,
    required this.emoji,
  });

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: json['id'] as String,
      coupleId: json['couple_id'] as String? ?? '',
      name: json['name'] as String,
      gender: json['gender'] as String,
      dob: DateTime.parse(json['date_of_birth'] as String),
      emoji: json['emoji'] as String? ?? '👶',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'name': name,
      'gender': gender,
      'date_of_birth': dob.toIso8601String().split('T')[0],
      'emoji': emoji,
    };
  }

  @override
  List<Object?> get props => [id, coupleId, name, gender, dob, emoji];
}

class BabyVaccination extends Equatable {
  final String id;
  final String babyId;
  final String vaccineName;
  final String diseasePrevention;
  final int recommendedAgeMonths;
  final DateTime plannedDate;
  final String status; // 'Pending', 'Done', 'Skipped'
  final DateTime? administeredDate;
  final String? notes;

  const BabyVaccination({
    required this.id,
    required this.babyId,
    required this.vaccineName,
    required this.diseasePrevention,
    required this.recommendedAgeMonths,
    required this.plannedDate,
    required this.status,
    this.administeredDate,
    this.notes,
  });

  factory BabyVaccination.fromJson(Map<String, dynamic> json) {
    return BabyVaccination(
      id: json['id'] as String,
      babyId: json['baby_id'] as String,
      vaccineName: json['vaccine_name'] as String,
      diseasePrevention: json['disease_prevention'] as String? ?? '',
      recommendedAgeMonths: json['recommended_age_months'] as int? ?? 0,
      plannedDate: DateTime.parse(json['planned_date'] as String),
      status: json['status'] as String? ?? 'Pending',
      administeredDate: json['administered_date'] != null
          ? DateTime.parse(json['administered_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  BabyVaccination copyWith({
    String? status,
    DateTime? administeredDate,
    String? notes,
    DateTime? plannedDate,
  }) {
    return BabyVaccination(
      id: id,
      babyId: babyId,
      vaccineName: vaccineName,
      diseasePrevention: diseasePrevention,
      recommendedAgeMonths: recommendedAgeMonths,
      plannedDate: plannedDate ?? this.plannedDate,
      status: status ?? this.status,
      administeredDate: administeredDate ?? this.administeredDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        babyId,
        vaccineName,
        diseasePrevention,
        recommendedAgeMonths,
        plannedDate,
        status,
        administeredDate,
        notes,
      ];
}

abstract class BabyState extends Equatable {
  const BabyState();

  @override
  List<Object?> get props => [];
}

class BabyInitial extends BabyState {
  const BabyInitial();
}

class BabyLoading extends BabyState {
  const BabyLoading();
}

class BabyLoaded extends BabyState {
  final BabyProfile? babyProfile;
  final List<BabyVaccination> vaccinations;

  const BabyLoaded({
    this.babyProfile,
    this.vaccinations = const [],
  });

  BabyLoaded copyWith({
    BabyProfile? babyProfile,
    List<BabyVaccination>? vaccinations,
    bool clearProfile = false,
  }) {
    return BabyLoaded(
      babyProfile: clearProfile ? null : (babyProfile ?? this.babyProfile),
      vaccinations: vaccinations ?? this.vaccinations,
    );
  }

  @override
  List<Object?> get props => [babyProfile, vaccinations];
}

class BabyFailure extends BabyState {
  final String errorMessage;

  const BabyFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
