// lib/features/dashboard/widgets/empathy_hints_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';

class EmpathyHintsCard extends StatelessWidget {
  final String partnerName;
  final String partnerMood;
  final String partnerBioRole;
  final bool isPartnerInPeriod;
  final bool isPartnerInPms;

  const EmpathyHintsCard({
    Key? key,
    required this.partnerName,
    required this.partnerMood,
    required this.partnerBioRole,
    required this.isPartnerInPeriod,
    required this.isPartnerInPms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String hintKey = 'default_hint';
    IconData cardIcon = Icons.favorite_border;
    Color iconColor = EmoraColors.primary;
    Color cardBgColor = EmoraColors.primary.withOpacity(0.08);

    if (partnerBioRole == 'Female' && isPartnerInPeriod) {
      hintKey = 'period_hint';
      cardIcon = Icons.spa;
      iconColor = const Color(0xFFFFB7B2);
      cardBgColor = const Color(0xFFFFB7B2).withOpacity(0.12);
    } else if (partnerBioRole == 'Female' && isPartnerInPms) {
      hintKey = 'pms_hint';
      cardIcon = Icons.healing;
      iconColor = const Color(0xFFFF7A59);
      cardBgColor = const Color(0xFFFF7A59).withOpacity(0.1);
    } else if (partnerMood == 'Tired') {
      hintKey = 'tired_hint';
      cardIcon = Icons.battery_alert;
      iconColor = const Color(0xFF8D99AE);
      cardBgColor = const Color(0xFF8D99AE).withOpacity(0.1);
    } else if (partnerMood == 'Irritated') {
      hintKey = 'irritated_hint';
      cardIcon = Icons.sentiment_very_dissatisfied;
      iconColor = const Color(0xFFF0A0A0);
      cardBgColor = const Color(0xFFF0A0A0).withOpacity(0.12);
    } else if (partnerMood == 'Sad') {
      hintKey = 'sad_hint';
      cardIcon = Icons.sentiment_dissatisfied;
      iconColor = const Color(0xFFC5D3E8);
      cardBgColor = const Color(0xFFC5D3E8).withOpacity(0.12);
    }

    final hintText = context.translate('empathy.$hintKey').replaceAll('{partner}', partnerName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: iconColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: cardBgColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          cardIcon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.translate('empathy.title'),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: EmoraColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EmoraColors.primary, EmoraColors.tertiary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'AI Hint',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                hintText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: EmoraColors.textDark,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
