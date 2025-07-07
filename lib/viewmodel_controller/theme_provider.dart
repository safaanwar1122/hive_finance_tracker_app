import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  ThemeProvider() {
    loadTheme();
  }
  toggleTheme(bool value) async {
    _isDark = value;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', value);
  }

  loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }
}
