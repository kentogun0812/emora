// lib/features/dashboard/widgets/active_requests_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/dashboard_bloc.dart';

class ActiveRequestsList extends StatelessWidget {
  final List<Map<String, dynamic>> activeRequests;
  final String? myId;

  const ActiveRequestsList({
    Key? key,
    required this.activeRequests,
    this.myId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activeRequests.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: EmoraColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: EmoraColors.secondary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: EmoraColors.primary, size: 40),
            const SizedBox(height: 12),
            Text(
              context.translate('care_requests.no_active'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: EmoraColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final currentUserId = myId ?? 'mock-user-id';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.translate('care_requests.title'),
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: EmoraColors.textDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EmoraColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${activeRequests.length} yêu cầu",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: EmoraColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final request = activeRequests[index];
            final reqId = request['id'] as String;
            final templateId = request['template_id'] as String;
            final status = request['status'] as String;
            final senderId = request['sender_id'] as String?;

            final isSentByMe = senderId == currentUserId;
            final templateText = context.translate('care_requests.$templateId');

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EmoraColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: EmoraColors.primary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: status == 'Accepted'
                      ? EmoraColors.primary.withOpacity(0.4)
                      : EmoraColors.secondary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sender & Template Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSentByMe
                                  ? context.translate('care_requests.sent_by_me')
                                  : context.translate('care_requests.sent_by_partner'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              templateText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Label
                      _buildStatusChip(context, status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isSentByMe)
                        // User can cancel their own pending/accepted request
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: EmoraColors.primary,
                            side: const BorderSide(color: EmoraColors.primary, width: 1.2),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.close, size: 14),
                          label: Text(
                            context.translate('care_requests.action_cancel'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            context.read<DashboardBloc>().add(
                                  UpdateRequestStatus(requestId: reqId, newStatus: 'Canceled'),
                                );
                          },
                        )
                      else ...[
                        // Partner requests A actions
                        if (status == 'Pending')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EmoraColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: Text(
                              context.translate('care_requests.action_accept'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              context.read<DashboardBloc>().add(
                                    UpdateRequestStatus(requestId: reqId, newStatus: 'Accepted'),
                                  );
                            },
                          ),
                        if (status == 'Accepted') ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EmoraColors.textMuted,
                              side: const BorderSide(color: EmoraColors.secondary, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              context.translate('care_requests.action_reset'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              context.read<DashboardBloc>().add(
                                    UpdateRequestStatus(requestId: reqId, newStatus: 'Pending'),
                                  );
                            },
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EmoraColors.tertiary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.done, size: 16),
                            label: Text(
                              context.translate('care_requests.action_complete'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              context.read<DashboardBloc>().add(
                                    UpdateRequestStatus(requestId: reqId, newStatus: 'Completed'),
                                  );
                            },
                          ),
                        ]
                      ]
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    Color textColor;
    String labelKey;

    switch (status) {
      case 'Pending':
        chipColor = EmoraColors.secondary.withOpacity(0.3);
        textColor = EmoraColors.primary;
        labelKey = 'care_requests.status_pending';
        break;
      case 'Accepted':
        chipColor = EmoraColors.tertiary.withOpacity(0.2);
        textColor = EmoraColors.tertiary;
        labelKey = 'care_requests.status_accepted';
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        labelKey = 'care_requests.status_pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.translate(labelKey),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
