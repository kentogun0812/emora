// lib/features/dashboard/widgets/mood_selector_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';

class MoodSelectorSheet extends StatelessWidget {
  final String currentMood;
  final ValueChanged<String> onMoodSelected;

  const MoodSelectorSheet({
    Key? key,
    required this.currentMood,
    required this.onMoodSelected,
  }) : super(key: key);

  static const Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Calm': '😌',
    'Tired': '😫',
    'Sad': '😢',
    'Irritated': '😡',
    'NeedAffection': '🥰',
    'NeedSpace': '🧘',
  };

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
              context.translate('mood.title'),
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EmoraColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Moods Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.6,
              ),
              itemCount: moodEmojis.keys.length,
              itemBuilder: (context, index) {
                final key = moodEmojis.keys.elementAt(index);
                final emoji = moodEmojis[key]!;
                final label = context.translate('mood.$key');
                final isSelected = key == currentMood;
                final moodColor = EmoraColors.moodColors[key] ?? EmoraColors.secondary;

                return GestureDetector(
                  onTap: () {
                    onMoodSelected(key);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? moodColor : moodColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: EmoraColors.primary, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: moodColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
