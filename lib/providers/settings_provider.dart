import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  int _dailyTimeLimit = 30;
  bool _soundEnabled = true;
  String _difficultyLevel = 'medium';
  bool _parentalLockEnabled = false;

  int get dailyTimeLimit => _dailyTimeLimit;
  bool get soundEnabled => _soundEnabled;
  String get difficultyLevel => _difficultyLevel;
  bool get parentalLockEnabled => _parentalLockEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyTimeLimit = prefs.getInt('daily_time_limit') ?? 30;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _difficultyLevel = prefs.getString('difficulty_level') ?? 'medium';
    _parentalLockEnabled = prefs.getBool('parental_lock_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setDailyTimeLimit(int minutes) async {
    _dailyTimeLimit = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_time_limit', minutes);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
    notifyListeners();
  }

  Future<void> setDifficultyLevel(String level) async {
    _difficultyLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty_level', level);
    notifyListeners();
  }

  Future<void> setParentalLockEnabled(bool enabled) async {
    _parentalLockEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parental_lock_enabled', enabled);
    notifyListeners();
  }
}
