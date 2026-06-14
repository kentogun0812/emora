// lib/features/settings/bloc/theme_bloc.dart
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeName: 'Cozy Haven', isPremium: false)) {
    on<ChangeTheme>((event, emit) {
      if (state.isPremium || event.themeName == 'Cozy Haven') {
        emit(state.copyWith(themeName: event.themeName));
      }
    });

    on<UpgradeToPremium>((event, emit) {
      emit(state.copyWith(isPremium: true));
    });

    on<ResetToFree>((event, emit) {
      emit(state.copyWith(isPremium: false, themeName: 'Cozy Haven'));
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      return ThemeState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return state.toJson();
  }
}
