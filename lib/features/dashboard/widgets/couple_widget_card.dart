// lib/features/dashboard/widgets/couple_widget_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/dashboard_bloc.dart';
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

    // Get my current mood from DashboardBloc state if possible
    String myMood = 'Calm';
    String myCallSign = 'Bạn';
    final dashboardBlocState = context.read<DashboardBloc>().state;
    if (dashboardBlocState is DashboardLoaded) {
      myMood = dashboardBlocState.myMood;
      myCallSign = dashboardBlocState.myCallSign.isNotEmpty ? dashboardBlocState.myCallSign : 'Bạn';
    }
    final myMoodColor = EmoraColors.moodColors[myMood] ?? EmoraColors.secondary;
    final myMoodEmoji = MoodSelectorSheet.moodEmojis[myMood] ?? '😊';
    final myMoodName = context.translate('mood.$myMood');

    // Find the latest request sent by partner (which we need to handle)
    Map<String, dynamic>? latestPartnerRequest;
    for (var req in activeRequests) {
      if (req['sender_id'] != currentUserId) {
        latestPartnerRequest = req;
        break;
      }
    }

    String requestMessage = "Không có yêu cầu nào";
    String requestStatus = "";
    Map<String, dynamic>? activeRequestToHandle = latestPartnerRequest;
    bool isPartnerSender = true;

    if (latestPartnerRequest != null) {
      final templateId = latestPartnerRequest['template_id'] as String;
      final status = latestPartnerRequest['status'] as String;
      requestMessage = context.translate('care_requests.$templateId');
      
      if (status == 'Pending') {
        requestStatus = context.translate('care_requests.status_pending');
      } else if (status == 'Accepted') {
        requestStatus = context.translate('care_requests.status_accepted');
      }
    } else {
      // If no partner request, look at my latest request
      final myRequest = activeRequests.firstWhere(
        (req) => req['sender_id'] == currentUserId,
        orElse: () => {},
      );
      if (myRequest.isNotEmpty) {
        activeRequestToHandle = myRequest;
        isPartnerSender = false;
        final templateId = myRequest['template_id'] as String;
        final status = myRequest['status'] as String;
        requestMessage = context.translate('care_requests.$templateId');
        
        if (status == 'Pending') {
          requestStatus = context.translate('care_requests.status_pending');
        } else if (status == 'Accepted') {
          requestStatus = context.translate('care_requests.status_accepted');
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: EmoraColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "SIMULATOR",
                style: TextStyle(
                  color: EmoraColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [partnerMoodColor.withOpacity(0.2), EmoraColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: partnerMoodColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: partnerMoodColor.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left: Partner & My Moods (Interactive)
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Partner mood column
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: partnerMoodColor.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: partnerMoodColor, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  partnerMoodEmoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                partnerName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: EmoraColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                partnerMoodName,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: EmoraColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // My mood column
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Open mood selector sheet for quick mood update
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => MoodSelectorSheet(
                                  currentMood: myMood,
                                  onMoodSelected: (newMood) {
                                    context
                                        .read<DashboardBloc>()
                                        .add(UpdateMyMood(newMood));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(context.translate('widget.status_updated')),
                                        backgroundColor: EmoraColors.primary,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: myMoodColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: myMoodColor.withOpacity(0.3), width: 1),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: myMoodColor.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: myMoodColor, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      myMoodEmoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    myCallSign,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: EmoraColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    myMoodName,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: EmoraColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Vertical Divider
              Container(
                width: 1.5,
                height: 80,
                color: EmoraColors.secondary.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              // Right: Latest Request Info with quick actions
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: EmoraColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isPartnerSender ? "Yêu cầu từ đối phương" : "Yêu cầu của bạn",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      requestMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: EmoraColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (requestStatus.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        requestStatus,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: EmoraColors.tertiary,
                        ),
                      ),
                    ],
                    // Action buttons
                    if (activeRequestToHandle != null && isPartnerSender) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (activeRequestToHandle['status'] == 'Pending')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EmoraColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<DashboardBloc>().add(
                                        UpdateRequestStatus(
                                          requestId: activeRequestToHandle!['id'],
                                          newStatus: 'Accepted',
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.translate('widget.status_updated')),
                                      backgroundColor: EmoraColors.primary,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.translate('widget.action_accept'),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          if (activeRequestToHandle['status'] == 'Accepted')
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EmoraColors.tertiary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<DashboardBloc>().add(
                                        UpdateRequestStatus(
                                          requestId: activeRequestToHandle!['id'],
                                          newStatus: 'Completed',
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.translate('widget.status_updated')),
                                      backgroundColor: EmoraColors.primary,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.translate('widget.action_complete'),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
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
