class LearningProgress {
  final String odId;
  final int chineseWordsLearned;
  final int englishWordsLearned;
  final int totalStudyTime;
  final List<String> masteredChineseChars;
  final List<String> masteredEnglishWords;
  final Map<String, int> weakAreas;

  LearningProgress({
    required this.odId,
    required this.chineseWordsLearned,
    required this.englishWordsLearned,
    required this.totalStudyTime,
    required this.masteredChineseChars,
    required this.masteredEnglishWords,
    required this.weakAreas,
  });

  Map<String, dynamic> toJson() => {
        'odId': odId,
        'chineseWordsLearned': chineseWordsLearned,
        'englishWordsLearned': englishWordsLearned,
        'totalStudyTime': totalStudyTime,
        'masteredChineseChars': masteredChineseChars,
        'masteredEnglishWords': masteredEnglishWords,
        'weakAreas': weakAreas,
      };

  factory LearningProgress.fromJson(Map<String, dynamic> json) => LearningProgress(
        odId: json['odId'] ?? '',
        chineseWordsLearned: json['chineseWordsLearned'] ?? 0,
        englishWordsLearned: json['englishWordsLearned'] ?? 0,
        totalStudyTime: json['totalStudyTime'] ?? 0,
        masteredChineseChars: List<String>.from(json['masteredChineseChars'] ?? []),
        masteredEnglishWords: List<String>.from(json['masteredEnglishWords'] ?? []),
        weakAreas: Map<String, int>.from(json['weakAreas'] ?? {}),
      );
}
