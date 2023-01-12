import 'package:flutter/material.dart';
import 'theme_preference.dart';
class ThemeModel extends ChangeNotifier {
  bool _themeDark;
  ThemePreferences _preferences;
  bool get themeDark => _themeDark;

  ThemeModel() {
    _themeDark = false;
    _preferences = ThemePreferences();
    getPreferences();
  }
  set themeDark(bool value){
    _themeDark = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  getPreferences() async {
    _themeDark = await _preferences.getTheme();
    notifyListeners();
  }
}