import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_progress.dart';

class LearningProvider extends ChangeNotifier {
  LearningProgress _progress = LearningProgress(
    odId: 'default',
    chineseWordsLearned: 0,
    englishWordsLearned: 0,
    totalStudyTime: 0,
    masteredChineseChars: [],
    masteredEnglishWords: [],
    weakAreas: {},
  );

  LearningProgress get progress => _progress;

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('learning_progress');
    if (progressJson != null) {
      _progress = LearningProgress.fromJson(json.decode(progressJson));
      notifyListeners();
    }
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learning_progress', json.encode(_progress.toJson()));
  }

  void markChineseCharLearned(String char) {
    if (!_progress.masteredChineseChars.contains(char)) {
      _progress = LearningProgress(
        odId: _progress.odId,
        chineseWordsLearned: _progress.chineseWordsLearned + 1,
        englishWordsLearned: _progress.englishWordsLearned,
        totalStudyTime: _progress.totalStudyTime,
        masteredChineseChars: [..._progress.masteredChineseChars, char],
        masteredEnglishWords: _progress.masteredEnglishWords,
        weakAreas: _progress.weakAreas,
      );
      saveProgress();
      notifyListeners();
    }
  }

  void markEnglishWordLearned(String word) {
    if (!_progress.masteredEnglishWords.contains(word)) {
      _progress = LearningProgress(
        odId: _progress.odId,
        chineseWordsLearned: _progress.chineseWordsLearned,
        englishWordsLearned: _progress.englishWordsLearned + 1,
        totalStudyTime: _progress.totalStudyTime,
        masteredChineseChars: _progress.masteredChineseChars,
        masteredEnglishWords: [..._progress.masteredEnglishWords, word],
        weakAreas: _progress.weakAreas,
      );
      saveProgress();
      notifyListeners();
    }
  }

  void addStudyTime(int minutes) {
    _progress = LearningProgress(
      odId: _progress.odId,
      chineseWordsLearned: _progress.chineseWordsLearned,
      englishWordsLearned: _progress.englishWordsLearned,
      totalStudyTime: _progress.totalStudyTime + minutes,
      masteredChineseChars: _progress.masteredChineseChars,
      masteredEnglishWords: _progress.masteredEnglishWords,
      weakAreas: _progress.weakAreas,
    );
    saveProgress();
    notifyListeners();
  }
}
