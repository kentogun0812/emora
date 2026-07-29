// lib/features/settings/widgets/profile_setup_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';

class ProfileSetupSheet extends StatefulWidget {
  final String initialNickname;
  final String initialDateOfBirth;
  final String initialBioRole;
  final String initialCallSign;
  final String initialPartnerCallSign;
  final String initialRelationshipStatus;

  const ProfileSetupSheet({
    Key? key,
    this.initialNickname = '',
    this.initialDateOfBirth = '',
    this.initialBioRole = 'Other',
    this.initialCallSign = '',
    this.initialPartnerCallSign = '',
    this.initialRelationshipStatus = 'Dating',
  }) : super(key: key);

  @override
  State<ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends State<ProfileSetupSheet> {
  late TextEditingController _nicknameController;
  DateTime? _selectedDate;
  late String _selectedBioRole;
  late TextEditingController _callSignController;
  late TextEditingController _partnerCallSignController;
  late String _selectedRelationshipStatus;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
    if (widget.initialDateOfBirth.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.initialDateOfBirth);
      } catch (_) {}
    }
    _selectedBioRole = widget.initialBioRole;
    _callSignController = TextEditingController(text: widget.initialCallSign);
    _partnerCallSignController = TextEditingController(text: widget.initialPartnerCallSign);
    _selectedRelationshipStatus = widget.initialRelationshipStatus;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _callSignController.dispose();
    _partnerCallSignController.dispose();
    super.dispose();
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String desc,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedBioRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedBioRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.2) : EmoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : EmoraColors.secondary.withOpacity(0.5),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? activeColor : EmoraColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? EmoraColors.textDark : EmoraColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 10,
                  color: EmoraColors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String status,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedRelationshipStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRelationshipStatus = status;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.2) : EmoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : EmoraColors.secondary.withOpacity(0.5),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? activeColor : EmoraColors.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? EmoraColors.textDark : EmoraColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
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
                  context.translate('profile.setup_title'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Nickname
                Text(
                  context.translate('profile_setup.nickname'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: context.translate('profile_setup.nickname_hint'),
                    filled: true,
                    fillColor: EmoraColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: EmoraColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.translate('profile_setup.nickname_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth
                Text(
                  context.translate('profile_setup.dob'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
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
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: EmoraColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: EmoraColors.primary, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? context.translate('profile_setup.dob_hint')
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedDate == null ? EmoraColors.textMuted : EmoraColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Bio Role selection
                Text(
                  context.translate('profile.bio_role'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRoleCard(
                      role: 'Female',
                      title: context.translate('profile.bio_role_female').split(' (')[0],
                      desc: context.translate('profile.bio_role_female').contains(' (') 
                          ? context.translate('profile.bio_role_female').split(' (')[1].replaceAll(')', '')
                          : 'Ghi chu kỳ',
                      icon: Icons.female,
                      activeColor: const Color(0xFFFFB7B2),
                    ),
                    const SizedBox(width: 12),
                    _buildRoleCard(
                      role: 'Male',
                      title: context.translate('profile.bio_role_male').split(' (')[0],
                      desc: context.translate('profile.bio_role_male').contains(' (') 
                          ? context.translate('profile.bio_role_male').split(' (')[1].replaceAll(')', '')
                          : 'Xem chu kỳ',
                      icon: Icons.male,
                      activeColor: const Color(0xFF8D99AE),
                    ),
                    const SizedBox(width: 12),
                    _buildRoleCard(
                      role: 'Other',
                      title: context.translate('profile.bio_role_other').split(' / ')[0],
                      desc: context.translate('profile.bio_role_other').contains(' / ') 
                          ? context.translate('profile.bio_role_other').split(' / ')[1]
                          : 'Khác',
                      icon: Icons.person_outline,
                      activeColor: const Color(0xFFB39DDB),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Call Signs Text Inputs
                Text(
                  context.translate('profile.call_sign'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _callSignController,
                  decoration: InputDecoration(
                    hintText: context.translate('profile.call_sign_hint'),
                    filled: true,
                    fillColor: EmoraColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: EmoraColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng điền danh xưng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Text(
                  context.translate('profile.partner_call_sign'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _partnerCallSignController,
                  decoration: InputDecoration(
                    hintText: context.translate('profile.partner_call_sign_hint'),
                    filled: true,
                    fillColor: EmoraColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: EmoraColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng điền danh xưng đối phương';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Relationship Status Selection
                Text(
                  context.translate('profile.relationship_status'),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: EmoraColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusCard(
                      status: 'Dating',
                      title: context.translate('profile.status_dating'),
                      icon: Icons.favorite_border,
                      activeColor: const Color(0xFFFFB7B2),
                    ),
                    const SizedBox(width: 16),
                    _buildStatusCard(
                      status: 'Married',
                      title: context.translate('profile.status_married'),
                      icon: Icons.people_outline,
                      activeColor: const Color(0xFFE8AEB7),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.translate('profile_setup.dob_required')),
                            backgroundColor: EmoraColors.primary,
                          ),
                        );
                        return;
                      }
                      context.read<DashboardBloc>().add(UpdateProfile(
                            nickname: _nicknameController.text.trim(),
                            dateOfBirth: _selectedDate!,
                            bioRole: _selectedBioRole,
                            callSign: _callSignController.text.trim(),
                            partnerCallSign: _partnerCallSignController.text.trim(),
                            relationshipStatus: _selectedRelationshipStatus,
                          ));
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.translate('profile.success_save')),
                          backgroundColor: EmoraColors.primary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EmoraColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    context.translate('common.save'),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
