import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme =
      Hive.box('settings').get('isDarkTheme', defaultValue: false);

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    Hive.box('settings').put('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }
}
