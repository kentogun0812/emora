// lib/features/dashboard/widgets/baby_hub_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../../baby/bloc/baby_bloc.dart';
import '../../baby/bloc/baby_state.dart';

class BabyHubCard extends StatelessWidget {
  const BabyHubCard({super.key});

  String _calculateAgeString(DateTime dob) {
    final now = DateTime.now();
    final difference = now.difference(dob);
    if (difference.isNegative) return 'Chưa sinh';

    int years = now.year - dob.year;
    int months = now.month - dob.month;
    int days = now.day - dob.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final parts = <String>[];
    if (years > 0) parts.add('$years tuổi');
    if (months > 0) parts.add('$months tháng');
    if (days > 0 || parts.isEmpty) parts.add('$days ngày');

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BabyBloc, BabyState>(
      builder: (context, state) {
        if (state is BabyLoading || state is BabyInitial) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: EmoraColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: EmoraColors.primary),
            ),
          );
        }

        if (state is BabyFailure) {
          return const SizedBox.shrink();
        }

        if (state is BabyLoaded) {
          final baby = state.babyProfile;
          if (baby == null) {
            // Render Setup Profile Call-to-action
            return Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: EmoraColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: EmoraColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: EmoraColors.secondary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('👶', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.translate('baby.title'),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.translate('baby.no_baby_desc'),
                              style: const TextStyle(
                                fontSize: 13,
                                color: EmoraColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EmoraColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, EmoraRoutes.babySetup);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      context.translate('baby.create_profile'),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Baby Profile details & vaccine stats
          final ageString = _calculateAgeString(baby.dob);
          final totalVaccines = state.vaccinations.length;
          final doneVaccines = state.vaccinations.where((v) => v.status == 'Done').length;
          final overdueVaccines = state.vaccinations
              .where((v) => v.status == 'Pending' && v.plannedDate.isBefore(DateTime.now()))
              .length;

          final progressValue = totalVaccines > 0 ? doneVaccines / totalVaccines : 0.0;

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, EmoraRoutes.vaccineTracker);
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: EmoraColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: EmoraColors.secondary.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EmoraColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar Bubble
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: EmoraColors.secondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      baby.emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              baby.name,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: EmoraColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ageString,
                          style: const TextStyle(
                            fontSize: 13,
                            color: EmoraColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Vaccine progress summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiêm chủng: $doneVaccines/$totalVaccines mũi',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                            ),
                            if (overdueVaccines > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '⚠️ $overdueVaccines trễ lịch',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: EmoraColors.background,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              EmoraColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
