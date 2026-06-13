// lib/features/dashboard/widgets/care_request_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';

class CareRequestSheet extends StatelessWidget {
  final ValueChanged<String> onTemplateSelected;

  const CareRequestSheet({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);

  static const List<Map<String, String>> templates = [
    {
      'id': 'bring_water',
      'emoji': '☕',
    },
    {
      'id': 'buy_food',
      'emoji': '🍜',
    },
    {
      'id': 'watch_kids',
      'emoji': '👶',
    },
    {
      'id': 'clean_house',
      'emoji': '🏠',
    },
    {
      'id': 'need_hug',
      'emoji': '🤗',
    },
    {
      'id': 'need_space',
      'emoji': '🧘',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: EmoraColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.translate('care_requests.send_title'),
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EmoraColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Templates Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final id = template['id']!;
                final emoji = template['emoji']!;
                final label = context.translate('care_requests.$id');

                // Determine border colors or background accents based on template
                final isSpace = id == 'need_space';
                final itemColor = isSpace ? EmoraColors.tertiary : EmoraColors.primary;

                return GestureDetector(
                  onTap: () {
                    onTemplateSelected(id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: EmoraColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: EmoraColors.secondary.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label.replaceFirst(emoji, '').trim(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
