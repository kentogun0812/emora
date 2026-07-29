// lib/features/auth/screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender; // 'Male' or 'Female'
  String? _selectedRelationshipStatus; // 'Dating' or 'Married'

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildGenderCard({
    required String gender,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.15) : EmoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.1),
                      blurRadius: 8,
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
                size: 32,
                color: isSelected ? activeColor : EmoraColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? EmoraColors.textDark : EmoraColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipCard({
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.15) : EmoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.1),
                      blurRadius: 8,
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
                size: 32,
                color: isSelected ? activeColor : EmoraColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? EmoraColors.textDark : EmoraColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: EmoraColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              // Dynamic Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: EmoraColors.bgGradient,
                ),
              ),
              // Dim glowing circles
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmoraColors.primary.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EmoraColors.secondary.withOpacity(0.15),
                  ),
                ),
              ),
              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              context.translate('profile_setup.title'),
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: EmoraColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.translate('profile_setup.subtitle'),
                              style: const TextStyle(
                                fontSize: 14,
                                color: EmoraColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: EmoraColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: EmoraColors.primary.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                style: const TextStyle(color: EmoraColors.textDark),
                                decoration: InputDecoration(
                                  hintText: context.translate('profile_setup.nickname_hint'),
                                  hintStyle: const TextStyle(color: EmoraColors.textMuted),
                                  prefixIcon: const Icon(Icons.person_outline, color: EmoraColors.primary),
                                  filled: true,
                                  fillColor: EmoraColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return context.translate('profile_setup.nickname_required');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

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
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: EmoraColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, color: EmoraColors.primary),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDate == null
                                            ? context.translate('profile_setup.dob_hint')
                                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedDate == null ? EmoraColors.textMuted : EmoraColors.textDark,
                                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Gender Selection
                              Text(
                                context.translate('profile_setup.gender'),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: EmoraColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildGenderCard(
                                    gender: 'Female',
                                    title: context.translate('profile_setup.gender_female'),
                                    icon: Icons.female,
                                    activeColor: const Color(0xFFFFB7B2),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildGenderCard(
                                    gender: 'Male',
                                    title: context.translate('profile_setup.gender_male'),
                                    icon: Icons.male,
                                    activeColor: const Color(0xFF8D99AE),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Relationship Status
                              Text(
                                context.translate('profile_setup.relationship'),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: EmoraColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRelationshipCard(
                                    status: 'Dating',
                                    title: context.translate('profile_setup.relationship_dating'),
                                    icon: Icons.favorite_border,
                                    activeColor: const Color(0xFFFFB7B2),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildRelationshipCard(
                                    status: 'Married',
                                    title: context.translate('profile_setup.relationship_married'),
                                    icon: Icons.people_outline,
                                    activeColor: const Color(0xFFE8AEB7),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Submit Button
                              if (isLoading)
                                const Center(
                                  child: CircularProgressIndicator(color: EmoraColors.primary),
                                )
                              else
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: EmoraColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
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
                                      if (_selectedGender == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(context.translate('profile_setup.gender_required')),
                                            backgroundColor: EmoraColors.primary,
                                          ),
                                        );
                                        return;
                                      }
                                      if (_selectedRelationshipStatus == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(context.translate('profile_setup.relationship_required')),
                                            backgroundColor: EmoraColors.primary,
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<AuthBloc>().add(CompleteProfileSetup(
                                        nickname: _nicknameController.text.trim(),
                                        dateOfBirth: _selectedDate!,
                                        bioRole: _selectedGender!,
                                        relationshipStatus: _selectedRelationshipStatus!,
                                      ));
                                    }
                                  },
                                  child: Text(
                                    context.translate('profile_setup.submit'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
