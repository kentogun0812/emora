// lib/features/settings/bloc/theme_event.dart
import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final String themeName;

  const ChangeTheme(this.themeName);

  @override
  List<Object?> get props => [themeName];
}

class UpgradeToPremium extends ThemeEvent {
  const UpgradeToPremium();
}

class ResetToFree extends ThemeEvent {
  const ResetToFree();
}
