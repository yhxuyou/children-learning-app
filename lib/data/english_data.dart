import '../models/english_word.dart';
import '../services/csv_service.dart';

// 初始化为空列表，在App启动时加载
List<EnglishWord> englishWordsData = [];

// 加载英语单词数据
Future<void> loadEnglishWordsData() async {
  englishWordsData = await CsvService.loadEnglishWords();
}

