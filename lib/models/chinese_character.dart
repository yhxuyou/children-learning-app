class ChineseCharacter {
  final String character;
  final String pinyin;
  final String meaning;
  final List<String> strokes;
  final List<String> words;
  final List<String> sentences;

  ChineseCharacter({
    required this.character,
    required this.pinyin,
    required this.meaning,
    required this.strokes,
    required this.words,
    required this.sentences,
  });
}
