// lib/features/calendar/widgets/relations_journal_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';

class RelationsJournalSheet extends StatefulWidget {
  final DateTime date;
  final String? initialProtectionType;
  final String? initialNotes;
  final Function(String protectionType, String? notes) onSave;

  const RelationsJournalSheet({
    Key? key,
    required this.date,
    this.initialProtectionType,
    this.initialNotes,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RelationsJournalSheet> createState() => _RelationsJournalSheetState();
}

class _RelationsJournalSheetState extends State<RelationsJournalSheet> {
  String _protectionType = 'Protected';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialProtectionType != null) {
      _protectionType = widget.initialProtectionType!;
    }
    if (widget.initialNotes != null) {
      _notesController.text = widget.initialNotes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 28, bottom: 40),
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
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
                context.translate('calendar.relation_journal'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: EmoraColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "${widget.date.day}/${widget.date.month}/${widget.date.year}",
                style: const TextStyle(
                  fontSize: 14,
                  color: EmoraColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Selection Row
              Row(
                children: [
                  // Protected Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _protectionType = 'Protected';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 90,
                        decoration: BoxDecoration(
                          color: _protectionType == 'Protected'
                              ? EmoraColors.tertiary.withOpacity(0.25)
                              : EmoraColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _protectionType == 'Protected'
                                ? EmoraColors.tertiary
                                : EmoraColors.secondary.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: _protectionType == 'Protected'
                              ? [
                                  BoxShadow(
                                    color: EmoraColors.tertiary.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '🛡️',
                              style: TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.translate('calendar.relation_protected').replaceAll('🛡️ ', ''),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _protectionType == 'Protected'
                                    ? EmoraColors.textDark
                                    : EmoraColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Unprotected Option
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _protectionType = 'Unprotected';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 90,
                        decoration: BoxDecoration(
                          color: _protectionType == 'Unprotected'
                              ? EmoraColors.primary.withOpacity(0.25)
                              : EmoraColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _protectionType == 'Unprotected'
                                ? EmoraColors.primary
                                : EmoraColors.secondary.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: _protectionType == 'Unprotected'
                              ? [
                                  BoxShadow(
                                    color: EmoraColors.primary.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '⚠️',
                              style: TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.translate('calendar.relation_unprotected').replaceAll('⚠️ ', ''),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _protectionType == 'Unprotected'
                                    ? EmoraColors.textDark
                                    : EmoraColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes Text Field
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: context.translate('calendar.notes_hint'),
                  hintStyle: const TextStyle(color: EmoraColors.textMuted, fontSize: 14),
                  filled: true,
                  fillColor: EmoraColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: EmoraColors.secondary.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: EmoraColors.primary),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: EmoraColors.textDark),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save and Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: EmoraColors.textMuted,
                        side: const BorderSide(color: EmoraColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        context.translate('common.cancel'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EmoraColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        widget.onSave(_protectionType, _notesController.text.trim().isEmpty ? null : _notesController.text.trim());
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.translate('common.save'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
