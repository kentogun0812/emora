// lib/features/baby/screens/baby_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/localization.dart';
import '../bloc/baby_bloc.dart';
import '../bloc/baby_event.dart';
import '../bloc/baby_state.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';

class BabySetupScreen extends StatefulWidget {
  const BabySetupScreen({super.key});

  @override
  State<BabySetupScreen> createState() => _BabySetupScreenState();
}

class _BabySetupScreenState extends State<BabySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedGender = 'Unknown';
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '👶';

  final List<String> _emojis = ['👶', '🦁', '🐰', '🐻', '🐼', '🐥', '🐱', '🦄'];

  @override
  void initState() {
    super.initState();

    // Check relationship status restriction
    final dashboardState = context.read<DashboardBloc>().state;
    final isMarried = dashboardState is DashboardLoaded && dashboardState.relationshipStatus == 'Married';
    if (!isMarried) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Text('🔒 '),
                  Text(context.translate('baby.locked_title')),
                ],
              ),
              content: Text(context.translate('baby.locked_desc')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    Navigator.pop(context);
                  },
                  child: const Text('Đồng ý', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      });
      return;
    }

    // Pre-populate if baby profile already exists
    final babyState = context.read<BabyBloc>().state;
    if (babyState is BabyLoaded && babyState.babyProfile != null) {
      final baby = babyState.babyProfile!;
      _nameController.text = baby.name;
      _selectedGender = baby.gender;
      _selectedDate = baby.dob;
      _selectedEmoji = baby.emoji;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 18),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: EmoraColors.primary,
              onPrimary: Colors.white,
              onSurface: EmoraColors.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: EmoraColors.primary,
              ),
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
          context.translate('baby.setup_title'),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: EmoraColors.primary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BabyBloc, BabyState>(
        listener: (context, state) {
          if (state is BabyLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('baby.success_save')),
                backgroundColor: EmoraColors.primary,
                duration: const Duration(seconds: 1),
              ),
            );
            Navigator.pop(context);
          } else if (state is BabyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BabyLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Emoji Avatar Picker
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: EmoraColors.secondary.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(color: EmoraColors.primary, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _selectedEmoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.translate('baby.avatar'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: EmoraColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Horizontal Emoji List
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: _emojis.length,
                            itemBuilder: (context, index) {
                              final emoji = _emojis[index];
                              final isSelected = emoji == _selectedEmoji;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedEmoji = emoji;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? EmoraColors.primary.withOpacity(0.15)
                                        : EmoraColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? EmoraColors.primary : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 2. Baby Name Input
                  Text(
                    context.translate('baby.name'),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: EmoraColors.textDark),
                    decoration: InputDecoration(
                      hintText: "Nhập tên bé...",
                      hintStyle: const TextStyle(color: EmoraColors.textMuted, fontSize: 14),
                      fillColor: EmoraColors.surface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: EmoraColors.primary, width: 1.5),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập tên của bé';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. Gender Selector
                  Text(
                    context.translate('baby.gender'),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderBtn('Male', '👦', context.translate('baby.gender_male')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGenderBtn('Female', '👧', context.translate('baby.gender_female')),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildGenderBtn('Unknown', '❓', context.translate('baby.gender_unknown')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Date of Birth Selector
                  Text(
                    context.translate('baby.dob'),
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: EmoraColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: EmoraColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: EmoraColors.textDark,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: EmoraColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 5. Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EmoraColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<BabyBloc>().add(
                                    SaveBabyProfile(
                                      name: _nameController.text.trim(),
                                      gender: _selectedGender,
                                      dob: _selectedDate,
                                      emoji: _selectedEmoji,
                                    ),
                                  );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            context.translate('baby.save_changes'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderBtn(String gender, String emoji, String label) {
    final isSelected = _selectedGender == gender;
    final activeColor = gender == 'Male'
        ? const Color(0xFFB8E0D2)
        : (gender == 'Female' ? const Color(0xFFFFB7B2) : EmoraColors.secondary);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.4) : EmoraColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? EmoraColors.textDark : EmoraColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
