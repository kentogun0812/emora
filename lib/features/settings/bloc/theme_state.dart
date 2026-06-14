// lib/features/settings/bloc/theme_state.dart
import 'package:equatable/equatable.dart';
import '../../../core/constants/colors.dart';

class ThemeState extends Equatable {
  final String themeName;
  final bool isPremium;

  const ThemeState({
    required this.themeName,
    required this.isPremium,
  });

  ThemeColors get themeColors =>
      EmoraColors.themes[themeName] ?? EmoraColors.themes['Cozy Haven']!;

  ThemeState copyWith({
    String? themeName,
    bool? isPremium,
  }) {
    return ThemeState(
      themeName: themeName ?? this.themeName,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  List<Object?> get props => [themeName, isPremium];

  Map<String, dynamic> toJson() {
    return {
      'themeName': themeName,
      'isPremium': isPremium,
    };
  }

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(
      themeName: json['themeName'] as String? ?? 'Cozy Haven',
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
}
