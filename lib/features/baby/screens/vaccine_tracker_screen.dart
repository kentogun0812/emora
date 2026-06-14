// lib/features/baby/screens/vaccine_tracker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/baby_bloc.dart';
import '../bloc/baby_event.dart';
import '../bloc/baby_state.dart';

class VaccineTrackerScreen extends StatefulWidget {
  const VaccineTrackerScreen({super.key});

  @override
  State<VaccineTrackerScreen> createState() => _VaccineTrackerScreenState();
}

class _VaccineTrackerScreenState extends State<VaccineTrackerScreen> {
  String _selectedFilter = 'all'; // 'all', 'overdue', 'pending', 'done'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmoraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: EmoraColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('baby.vaccination_tracker'),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: EmoraColors.primary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BabyBloc, BabyState>(
        builder: (context, state) {
          if (state is BabyLoading || state is BabyInitial) {
            return const Center(
              child: CircularProgressIndicator(color: EmoraColors.primary),
            );
          }

          if (state is BabyFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: EmoraColors.primary),
                    const SizedBox(height: 16),
                    Text(state.errorMessage, style: const TextStyle(color: EmoraColors.textDark)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BabyBloc>().add(const LoadBabyProfile());
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is BabyLoaded) {
            final baby = state.babyProfile;
            if (baby == null) {
              return const Center(
                child: Text('Vui lòng thiết lập hồ sơ bé trước.'),
              );
            }

            final filteredVaccines = _getFilteredVaccines(state.vaccinations);
            final groupedVaccines = _groupVaccinesByMilestone(filteredVaccines);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Baby Header Mini-Card
                _buildBabyHeader(baby, state.vaccinations),

                // 2. Filter Chips
                _buildFilterChips(state.vaccinations),

                // 3. Timeline List
                Expanded(
                  child: filteredVaccines.isEmpty
                      ? const Center(
                          child: Text(
                            'Không có mũi tiêm nào phù hợp.',
                            style: TextStyle(color: EmoraColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                          itemCount: groupedVaccines.keys.length,
                          itemBuilder: (context, index) {
                            final milestone = groupedVaccines.keys.elementAt(index);
                            final list = groupedVaccines[milestone]!;
                            return _buildMilestoneSection(milestone, list);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBabyHeader(BabyProfile baby, List<BabyVaccination> vaccs) {
    final completed = vaccs.where((v) => v.status == 'Done').length;
    final total = vaccs.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EmoraColors.primary.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: EmoraColors.secondary.withOpacity(0.25),
            child: Text(baby.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ngày sinh: ${baby.dob.day}/${baby.dob.month}/${baby.dob.year}',
                  style: const TextStyle(fontSize: 12, color: EmoraColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EmoraColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completed/$total mũi',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: EmoraColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<BabyVaccination> vaccs) {
    final overdueCount = vaccs.where((v) => v.status == 'Pending' && v.plannedDate.isBefore(DateTime.now())).length;
    final pendingCount = vaccs.where((v) => v.status == 'Pending').length;
    final doneCount = vaccs.where((v) => v.status == 'Done').length;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('all', context.translate('baby.all'), vaccs.length),
          _buildFilterChip('overdue', context.translate('baby.overdue'), overdueCount, color: Colors.red),
          _buildFilterChip('pending', context.translate('baby.pending'), pendingCount, color: Colors.orange),
          _buildFilterChip('done', context.translate('baby.done'), doneCount, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, int count, {Color? color}) {
    final isSelected = _selectedFilter == filter;
    final chipColor = color ?? EmoraColors.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : EmoraColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.3) : chipColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : chipColor,
                ),
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
          HapticFeedback.lightImpact();
        },
        backgroundColor: EmoraColors.surface,
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.transparent : EmoraColors.secondary.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
    );
  }

  List<BabyVaccination> _getFilteredVaccines(List<BabyVaccination> list) {
    switch (_selectedFilter) {
      case 'overdue':
        return list.where((v) => v.status == 'Pending' && v.plannedDate.isBefore(DateTime.now())).toList();
      case 'pending':
        return list.where((v) => v.status == 'Pending').toList();
      case 'done':
        return list.where((v) => v.status == 'Done').toList();
      default:
        return list;
    }
  }

  Map<int, List<BabyVaccination>> _groupVaccinesByMilestone(List<BabyVaccination> list) {
    final Map<int, List<BabyVaccination>> map = {};
    for (var v in list) {
      final key = v.recommendedAgeMonths;
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(v);
    }
    return map;
  }

  Widget _buildMilestoneSection(int months, List<BabyVaccination> list) {
    final milestoneLabel = months == 0 ? "Sơ sinh" : "$months tháng tuổi";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: EmoraColors.secondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestoneLabel,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.primary,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(
                  indent: 10,
                  color: EmoraColors.secondary,
                  thickness: 1,
                ),
              )
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, idx) {
            final v = list[idx];
            return _buildVaccineCard(v);
          },
        ),
      ],
    );
  }

  Widget _buildVaccineCard(BabyVaccination v) {
    final isDone = v.status == 'Done';
    final isOverdue = v.status == 'Pending' && v.plannedDate.isBefore(DateTime.now());

    Color statusColor = EmoraColors.textMuted;
    IconData statusIcon = Icons.radio_button_off;
    if (isDone) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning_amber_rounded;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: EmoraColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showVaccineDetailSheet(context, v),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.vaccineName,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: EmoraColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      v.diseasePrevention,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EmoraColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 12, color: EmoraColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Dự kiến: ${v.plannedDate.day}/${v.plannedDate.month}/${v.plannedDate.year}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOverdue ? Colors.red : EmoraColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: EmoraColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showVaccineDetailSheet(BuildContext context, BabyVaccination v) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _VaccineDetailSheet(vaccination: v);
      },
    );
  }
}

class _VaccineDetailSheet extends StatefulWidget {
  final BabyVaccination vaccination;

  const _VaccineDetailSheet({required this.vaccination});

  @override
  State<_VaccineDetailSheet> createState() => _VaccineDetailSheetState();
}

class _VaccineDetailSheetState extends State<_VaccineDetailSheet> {
  late String _status;
  late DateTime _plannedDate;
  DateTime? _administeredDate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.vaccination.status;
    _plannedDate = widget.vaccination.plannedDate;
    _administeredDate = widget.vaccination.administeredDate ?? DateTime.now();
    _notesController.text = widget.vaccination.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPlannedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plannedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _plannedDate) {
      setState(() {
        _plannedDate = picked;
      });
    }
  }

  Future<void> _selectAdministeredDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _administeredDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _administeredDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _status == 'Done';

    return Container(
      decoration: const BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handlebar
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

            // Header Info
            Text(
              widget.vaccination.vaccineName,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: EmoraColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "${context.translate('baby.disease')}: ${widget.vaccination.diseasePrevention}",
              style: const TextStyle(fontSize: 13, color: EmoraColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 1. Status Toggle
            Text(
              context.translate('baby.status'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusBtn('Pending', context.translate('baby.pending'), Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusBtn('Done', context.translate('baby.done'), Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Date Pickers
            if (isDone) ...[
              Text(
                context.translate('baby.administered_date'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectAdministeredDate(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: EmoraColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _administeredDate != null
                            ? "${_administeredDate!.day}/${_administeredDate!.month}/${_administeredDate!.year}"
                            : context.translate('baby.not_set'),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: EmoraColors.primary),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                context.translate('baby.planned_date'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectPlannedDate(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: EmoraColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_plannedDate.day}/${_plannedDate.month}/${_plannedDate.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
                      ),
                      const Icon(Icons.edit_calendar, size: 16, color: EmoraColors.primary),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 3. Notes Field
            Text(
              context.translate('baby.notes'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: EmoraColors.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: EmoraColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: context.translate('baby.notes_placeholder'),
                hintStyle: const TextStyle(color: EmoraColors.textMuted, fontSize: 13),
                fillColor: EmoraColors.background,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),

            // 4. Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmoraColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: () {
                if (isDone) {
                  context.read<BabyBloc>().add(
                        UpdateVaccination(
                          vaccinationId: widget.vaccination.id,
                          status: 'Done',
                          administeredDate: _administeredDate,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        ),
                      );
                } else {
                  context.read<BabyBloc>().add(
                        UpdateVaccination(
                          vaccinationId: widget.vaccination.id,
                          status: 'Pending',
                          administeredDate: null,
                          notes: null,
                        ),
                      );
                  // If planned date changed
                  if (_plannedDate != widget.vaccination.plannedDate) {
                    context.read<BabyBloc>().add(
                          ChangeVaccinePlannedDate(
                            vaccinationId: widget.vaccination.id,
                            plannedDate: _plannedDate,
                          ),
                        );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Lưu thay đổi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBtn(String status, String label, Color color) {
    final isSelected = _status == status;
    return InkWell(
      onTap: () {
        setState(() {
          _status = status;
        });
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : EmoraColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : EmoraColors.textMuted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
