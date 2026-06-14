// lib/features/baby/bloc/baby_event.dart
import 'package:equatable/equatable.dart';

abstract class BabyEvent extends Equatable {
  const BabyEvent();

  @override
  List<Object?> get props => [];
}

class LoadBabyProfile extends BabyEvent {
  const LoadBabyProfile();
}

class SaveBabyProfile extends BabyEvent {
  final String name;
  final String gender;
  final DateTime dob;
  final String emoji;

  const SaveBabyProfile({
    required this.name,
    required this.gender,
    required this.dob,
    required this.emoji,
  });

  @override
  List<Object?> get props => [name, gender, dob, emoji];
}

class UpdateVaccination extends BabyEvent {
  final String vaccinationId;
  final String status;
  final DateTime? administeredDate;
  final String? notes;

  const UpdateVaccination({
    required this.vaccinationId,
    required this.status,
    this.administeredDate,
    this.notes,
  });

  @override
  List<Object?> get props => [vaccinationId, status, administeredDate, notes];
}

class ChangeVaccinePlannedDate extends BabyEvent {
  final String vaccinationId;
  final DateTime plannedDate;

  const ChangeVaccinePlannedDate({
    required this.vaccinationId,
    required this.plannedDate,
  });

  @override
  List<Object?> get props => [vaccinationId, plannedDate];
}

class RealtimeVaccinationsReceived extends BabyEvent {
  final List<Map<String, dynamic>> vaccinations;

  const RealtimeVaccinationsReceived(this.vaccinations);

  @override
  List<Object?> get props => [vaccinations];
}
