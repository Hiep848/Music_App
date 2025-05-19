import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode>{
  
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode themeMode) {
    emit(themeMode);
  }
  
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    if (json['themeMode'] == 'dark') {
      return ThemeMode.dark;
    } else if (json['themeMode'] == 'light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    if (state == ThemeMode.dark) {
      return {'themeMode': 'dark'};
    } else if (state == ThemeMode.light) {
      return {'themeMode': 'light'};
    } else {
      return {'themeMode': 'system'};
    }
  }
  
}