// lib/features/calendar/widgets/period_log_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';

class PeriodLogSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? existingEndDate;
  final Function(DateTime startDate, DateTime? endDate) onSave;

  const PeriodLogSheet({
    Key? key,
    required this.initialDate,
    this.existingEndDate,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PeriodLogSheet> createState() => _PeriodLogSheetState();
}

class _PeriodLogSheetState extends State<PeriodLogSheet> {
  late DateTime _startDate;
  DateTime? _endDate;
  bool _hasEnded = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate;
    _endDate = widget.existingEndDate;
    _hasEnded = widget.existingEndDate != null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: EmoraColors.primary,
              onPrimary: Colors.white,
              onSurface: EmoraColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 4));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 4)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: EmoraColors.primary,
              onPrimary: Colors.white,
              onSurface: EmoraColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

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
              context.translate('calendar.period_log'),
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: EmoraColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Start Date Row
            InkWell(
              onTap: () => _selectStartDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: EmoraColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EmoraColors.secondary.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.translate('calendar.period_start'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: EmoraColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${_startDate.day}/${_startDate.month}/${_startDate.year}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: EmoraColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month, color: EmoraColors.primary, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Has Ended Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.translate('calendar.period_end'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: EmoraColors.textDark,
                  ),
                ),
                Switch(
                  value: _hasEnded,
                  activeColor: EmoraColors.primary,
                  activeTrackColor: EmoraColors.secondary,
                  inactiveThumbColor: EmoraColors.textMuted,
                  inactiveTrackColor: EmoraColors.background,
                  onChanged: (value) {
                    setState(() {
                      _hasEnded = value;
                      if (_hasEnded && _endDate == null) {
                        _endDate = _startDate.add(const Duration(days: 4));
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // End Date Row (conditionally visible)
            if (_hasEnded)
              InkWell(
                onTap: () => _selectEndDate(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: EmoraColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: EmoraColors.secondary.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('calendar.period_end'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: EmoraColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _endDate != null
                                ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                                : "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_month, color: EmoraColors.primary, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Buttons
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
                      widget.onSave(_startDate, _hasEnded ? _endDate : null);
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
    );
  }
}
