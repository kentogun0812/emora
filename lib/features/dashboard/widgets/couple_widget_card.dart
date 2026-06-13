// lib/features/dashboard/widgets/couple_widget_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import 'mood_selector_sheet.dart';

class CoupleWidgetCard extends StatelessWidget {
  final String partnerName;
  final String partnerMood;
  final List<Map<String, dynamic>> activeRequests;
  final String? myId;

  const CoupleWidgetCard({
    Key? key,
    required this.partnerName,
    required this.partnerMood,
    required this.activeRequests,
    this.myId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final partnerMoodColor = EmoraColors.moodColors[partnerMood] ?? EmoraColors.secondary;
    final partnerMoodEmoji = MoodSelectorSheet.moodEmojis[partnerMood] ?? '😊';
    final partnerMoodName = context.translate('mood.$partnerMood');

    final currentUserId = myId ?? 'mock-user-id';

    // Find the latest request sent by partner (which we need to handle)
    Map<String, dynamic>? latestPartnerRequest;
    for (var req in activeRequests) {
      if (req['sender_id'] != currentUserId) {
        latestPartnerRequest = req;
        break;
      }
    }

    String requestMessage = "Không có yêu cầu chăm sóc nào";
    String requestStatus = "";
    if (latestPartnerRequest != null) {
      final templateId = latestPartnerRequest['template_id'] as String;
      final status = latestPartnerRequest['status'] as String;
      requestMessage = context.translate('care_requests.$templateId');
      
      if (status == 'Pending') {
        requestStatus = " (${context.translate('care_requests.status_pending')})";
      } else if (status == 'Accepted') {
        requestStatus = " (${context.translate('care_requests.status_accepted')})";
      }
    } else {
      // If no partner request, look at my latest request
      final myRequest = activeRequests.firstWhere(
        (req) => req['sender_id'] == currentUserId,
        orElse: () => {},
      );
      if (myRequest.isNotEmpty) {
        final templateId = myRequest['template_id'] as String;
        final status = myRequest['status'] as String;
        requestMessage = context.translate('care_requests.$templateId');
        
        if (status == 'Pending') {
          requestStatus = " (${context.translate('care_requests.status_pending')})";
        } else if (status == 'Accepted') {
          requestStatus = " (${context.translate('care_requests.status_accepted')})";
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tiện ích màn hình chính (Widget Preview)",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: EmoraColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [partnerMoodColor.withOpacity(0.4), EmoraColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: partnerMoodColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: partnerMoodColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left: Partner Mood Avatar & State
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            partnerMoodEmoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: EmoraColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.favorite, size: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      partnerName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: EmoraColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      partnerMoodName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: EmoraColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Vertical Divider
              Container(
                width: 1.5,
                height: double.infinity,
                color: EmoraColors.secondary.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Right: Latest Request Info
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, size: 14, color: EmoraColors.primary),
                        SizedBox(width: 6),
                        Text(
                          "Yêu cầu mới nhất",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: EmoraColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      requestMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: EmoraColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (requestStatus.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        requestStatus.replaceAll('(', '').replaceAll(')', ''),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: EmoraColors.tertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
