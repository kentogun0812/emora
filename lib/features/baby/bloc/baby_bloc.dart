// lib/features/baby/bloc/baby_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_handler.dart';
import 'baby_event.dart';
import 'baby_state.dart';

class BabyBloc extends Bloc<BabyEvent, BabyState> {
  final SupabaseClient _client = SupabaseHandler.client;
  RealtimeChannel? _vaccineChannel;

  // In-memory cache for bypass mode
  BabyProfile? _mockBabyProfile;
  List<BabyVaccination> _mockVaccinations = [];

  BabyBloc() : super(const BabyInitial()) {
    on<LoadBabyProfile>(_onLoadBabyProfile);
    on<SaveBabyProfile>(_onSaveBabyProfile);
    on<UpdateVaccination>(_onUpdateVaccination);
    on<ChangeVaccinePlannedDate>(_onChangeVaccinePlannedDate);
    on<RealtimeVaccinationsReceived>(_onRealtimeVaccinationsReceived);
  }

  Future<void> _onLoadBabyProfile(
      LoadBabyProfile event, Emitter<BabyState> emit) async {
    emit(const BabyLoading());
    try {
      final myId = _client.auth.currentUser?.id;
      if (myId == null) {
        // Bypass Mode: Setup mock data if not already initialized
        if (_mockBabyProfile == null) {
          final dob = DateTime.now().subtract(const Duration(days: 95)); // ~3 months old
          _mockBabyProfile = BabyProfile(
            id: 'mock-baby-id',
            coupleId: 'mock-couple-id',
            name: 'Bé Đậu',
            gender: 'Male',
            dob: dob,
            emoji: '👶',
          );
          _mockVaccinations = _generateMockVaccinations('mock-baby-id', dob);
        }
        emit(BabyLoaded(
          babyProfile: _mockBabyProfile,
          vaccinations: List.from(_mockVaccinations),
        ));
        return;
      }

      // Online Mode: Fetch user profile info
      final myProfile = await _client
          .from('users')
          .select('couple_id')
          .eq('id', myId)
          .single();

      final coupleId = myProfile['couple_id'] as String?;
      if (coupleId == null) {
        emit(const BabyLoaded(babyProfile: null, vaccinations: []));
        return;
      }

      // Fetch Baby Profile
      final List<dynamic> babyProfilesData = await _client
          .from('baby_profiles')
          .select()
          .eq('couple_id', coupleId);

      if (babyProfilesData.isEmpty) {
        emit(const BabyLoaded(babyProfile: null, vaccinations: []));
        return;
      }

      final babyJson = babyProfilesData.first as Map<String, dynamic>;
      final babyProfile = BabyProfile.fromJson(babyJson);

      // Fetch Vaccinations
      final vaccinationsData = await _client
          .from('baby_vaccinations')
          .select()
          .eq('baby_id', babyProfile.id)
          .order('recommended_age_months', ascending: true)
          .order('planned_date', ascending: true);

      final List<BabyVaccination> vaccinations = (vaccinationsData as List)
          .map((v) => BabyVaccination.fromJson(v as Map<String, dynamic>))
          .toList();

      // Setup Realtime Sync
      await _cleanupChannel();
      _vaccineChannel = _client.channel('baby_vaccinations_changes');
      _vaccineChannel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'baby_vaccinations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'baby_id',
          value: babyProfile.id,
        ),
        callback: (payload) {
          add(const LoadBabyProfile());
        },
      );
      _vaccineChannel?.subscribe();

      emit(BabyLoaded(
        babyProfile: babyProfile,
        vaccinations: vaccinations,
      ));
    } catch (e) {
      emit(BabyFailure(e.toString()));
    }
  }

  Future<void> _onSaveBabyProfile(
      SaveBabyProfile event, Emitter<BabyState> emit) async {
    final myId = _client.auth.currentUser?.id;

    try {
      if (myId == null) {
        // Bypass Mode
        _mockBabyProfile = BabyProfile(
          id: _mockBabyProfile?.id ?? 'mock-baby-id',
          coupleId: 'mock-couple-id',
          name: event.name,
          gender: event.gender,
          dob: event.dob,
          emoji: event.emoji,
        );
        // Re-generate vaccinations schedule with new DOB, keeping status 'Done' where matches name
        final oldVaccs = List<BabyVaccination>.from(_mockVaccinations);
        _mockVaccinations = _generateMockVaccinations(_mockBabyProfile!.id, event.dob);
        for (int i = 0; i < _mockVaccinations.length; i++) {
          final match = oldVaccs.firstWhere(
            (o) => o.vaccineName == _mockVaccinations[i].vaccineName,
            orElse: () => _mockVaccinations[i],
          );
          if (match.status == 'Done') {
            _mockVaccinations[i] = _mockVaccinations[i].copyWith(
              status: 'Done',
              administeredDate: match.administeredDate ?? event.dob.add(Duration(days: 30 * match.recommendedAgeMonths)),
              notes: match.notes,
            );
          }
        }
        emit(BabyLoaded(
          babyProfile: _mockBabyProfile,
          vaccinations: List.from(_mockVaccinations),
        ));
        return;
      }

      // Online Mode
      emit(const BabyLoading());

      final myProfile = await _client
          .from('users')
          .select('couple_id')
          .eq('id', myId)
          .single();

      final coupleId = myProfile['couple_id'] as String?;
      if (coupleId == null) {
        emit(const BabyFailure('Chưa ghép đôi cặp đôi.'));
        return;
      }

      // Check if baby profile exists
      final List<dynamic> checkProfile = await _client
          .from('baby_profiles')
          .select('id, date_of_birth')
          .eq('couple_id', coupleId);

      String babyId = '';
      DateTime? oldDob;
      if (checkProfile.isNotEmpty) {
        final existing = checkProfile.first as Map<String, dynamic>;
        babyId = existing['id'] as String;
        oldDob = DateTime.parse(existing['date_of_birth'] as String);

        // Update profile
        await _client.from('baby_profiles').update({
          'name': event.name,
          'gender': event.gender,
          'date_of_birth': event.dob.toIso8601String().split('T')[0],
          'emoji': event.emoji,
        }).eq('id', babyId);
      } else {
        // Create profile
        final newProfile = await _client.from('baby_profiles').insert({
          'couple_id': coupleId,
          'name': event.name,
          'gender': event.gender,
          'date_of_birth': event.dob.toIso8601String().split('T')[0],
          'emoji': event.emoji,
        }).select('id').single();
        babyId = newProfile['id'] as String;
      }

      // If DOB changed, update planned_dates for Pending vaccines
      if (oldDob != null && (oldDob.year != event.dob.year || oldDob.month != event.dob.month || oldDob.day != event.dob.day)) {
        final List<dynamic> vaccinationsData = await _client
            .from('baby_vaccinations')
            .select('id, recommended_age_months, status')
            .eq('baby_id', babyId);

        for (var item in vaccinationsData) {
          final status = item['status'] as String;
          if (status == 'Pending') {
            final id = item['id'] as String;
            final ageMonths = item['recommended_age_months'] as int;
            // Add months interval in Dart side
            final plannedDate = DateTime(
              event.dob.year,
              event.dob.month + ageMonths,
              event.dob.day,
            );
            await _client.from('baby_vaccinations').update({
              'planned_date': plannedDate.toIso8601String().split('T')[0],
            }).eq('id', id);
          }
        }
      }

      add(const LoadBabyProfile());
    } catch (e) {
      emit(BabyFailure(e.toString()));
    }
  }

  Future<void> _onUpdateVaccination(
      UpdateVaccination event, Emitter<BabyState> emit) async {
    final currentState = state;
    if (currentState is! BabyLoaded) return;

    final myId = _client.auth.currentUser?.id;

    try {
      if (myId == null) {
        // Bypass Mode
        final index = _mockVaccinations.indexWhere((v) => v.id == event.vaccinationId);
        if (index != -1) {
          _mockVaccinations[index] = _mockVaccinations[index].copyWith(
            status: event.status,
            administeredDate: event.administeredDate,
            notes: event.notes,
          );
        }
        emit(BabyLoaded(
          babyProfile: _mockBabyProfile,
          vaccinations: List.from(_mockVaccinations),
        ));
        return;
      }

      // Online Mode
      final updates = {
        'status': event.status,
        'administered_date': event.administeredDate?.toIso8601String().split('T')[0],
        'notes': event.notes,
        'updated_by': myId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('baby_vaccinations')
          .update(updates)
          .eq('id', event.vaccinationId);

      // Reload
      add(const LoadBabyProfile());
    } catch (_) {}
  }

  Future<void> _onChangeVaccinePlannedDate(
      ChangeVaccinePlannedDate event, Emitter<BabyState> emit) async {
    final currentState = state;
    if (currentState is! BabyLoaded) return;

    final myId = _client.auth.currentUser?.id;

    try {
      if (myId == null) {
        // Bypass Mode
        final index = _mockVaccinations.indexWhere((v) => v.id == event.vaccinationId);
        if (index != -1) {
          _mockVaccinations[index] = _mockVaccinations[index].copyWith(
            plannedDate: event.plannedDate,
          );
        }
        emit(BabyLoaded(
          babyProfile: _mockBabyProfile,
          vaccinations: List.from(_mockVaccinations),
        ));
        return;
      }

      // Online Mode
      await _client.from('baby_vaccinations').update({
        'planned_date': event.plannedDate.toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', event.vaccinationId);

      add(const LoadBabyProfile());
    } catch (_) {}
  }

  void _onRealtimeVaccinationsReceived(
      RealtimeVaccinationsReceived event, Emitter<BabyState> emit) {
    final currentState = state;
    if (currentState is BabyLoaded) {
      final updatedVaccinations = event.vaccinations
          .map((v) => BabyVaccination.fromJson(v))
          .toList();
      emit(currentState.copyWith(vaccinations: updatedVaccinations));
    }
  }

  // Generate mock vaccination schedule
  List<BabyVaccination> _generateMockVaccinations(String babyId, DateTime dob) {
    final List<Map<String, dynamic>> vaccines = [
      {'name': 'BCG', 'disease': 'Lao (Tuberculosis)', 'age': 0},
      {'name': 'Hepatitis B (1st dose)', 'disease': 'Viêm gan B (Hepatitis B)', 'age': 0},
      {'name': '6-in-1 (1st dose)', 'disease': 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 'age': 2},
      {'name': 'Rotavirus (1st dose)', 'disease': 'Tiêu chảy do Rotavirus', 'age': 2},
      {'name': 'Pneumococcal (1st dose)', 'disease': 'Phế cầu (Pneumococcus)', 'age': 2},
      {'name': '6-in-1 (2nd dose)', 'disease': 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 'age': 3},
      {'name': 'Rotavirus (2nd dose)', 'disease': 'Tiêu chảy do Rotavirus', 'age': 3},
      {'name': '6-in-1 (3rd dose)', 'disease': 'Bạch hầu, Ho gà, Uốn ván, Bại liệt, Hib, Viêm gan B', 'age': 4},
      {'name': 'Pneumococcal (2nd dose)', 'disease': 'Phế cầu (Pneumococcus)', 'age': 4},
      {'name': 'Influenza (1st dose)', 'disease': 'Cúm mùa (Influenza)', 'age': 6},
      {'name': 'Meningococcal BC (1st dose)', 'disease': 'Viêm màng não mô cầu BC', 'age': 6},
      {'name': 'Measles (1st dose)', 'disease': 'Sởi (Measles)', 'age': 9},
      {'name': 'Japanese Encephalitis (1st dose)', 'disease': 'Viêm não Nhật Bản', 'age': 9},
      {'name': 'MMR (1st dose)', 'disease': 'Sởi, Quai bị, Rubella', 'age': 12},
      {'name': 'Varicella (1st dose)', 'disease': 'Thủy đậu (Chickenpox)', 'age': 12},
    ];

    final List<BabyVaccination> results = [];
    for (int i = 0; i < vaccines.length; i++) {
      final v = vaccines[i];
      final age = v['age'] as int;
      final planned = DateTime(dob.year, dob.month + age, dob.day);
      final isDone = planned.isBefore(DateTime.now().subtract(const Duration(days: 15)));

      results.add(BabyVaccination(
        id: 'mock-vaccine-$i',
        babyId: babyId,
        vaccineName: v['name'] as String,
        diseasePrevention: v['disease'] as String,
        recommendedAgeMonths: age,
        plannedDate: planned,
        status: isDone ? 'Done' : 'Pending',
        administeredDate: isDone ? planned : null,
        notes: isDone ? 'Đã tiêm tại Trạm Y tế Phường' : null,
      ));
    }
    return results;
  }

  Future<void> _cleanupChannel() async {
    if (_vaccineChannel != null) {
      await _client.removeChannel(_vaccineChannel!);
      _vaccineChannel = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanupChannel();
    return super.close();
  }
}
