import '../models/english_word.dart';
import '../services/csv_service.dart';

// 初始化为空列表，在App启动时加载
List<EnglishWord> englishWordsData = [];

// 默认英语单词数据（作为备份）
final List<EnglishWord> defaultEnglishWordsData = [
  EnglishWord(
    word: 'apple',
    pronunciation: '/ˈæpəl/',
    meaning: '苹果',
    imageAsset: '🍎',
    category: 'fruits',
    examples: ['I eat an apple every day.', 'The apple is red.'],
  ),
  EnglishWord(
    word: 'banana',
    pronunciation: '/bəˈnænə/',
    meaning: '香蕉',
    imageAsset: '🍌',
    category: 'fruits',
    examples: ['I like bananas.', 'The banana is yellow.'],
  ),
  EnglishWord(
    word: 'cat',
    pronunciation: '/kæt/',
    meaning: '猫',
    imageAsset: '🐱',
    category: 'animals',
    examples: ['The cat is sleeping.', 'I have a cute cat.'],
  ),
  EnglishWord(
    word: 'dog',
    pronunciation: '/dɔːɡ/',
    meaning: '狗',
    imageAsset: '🐕',
    category: 'animals',
    examples: ['The dog is barking.', 'I love dogs.'],
  ),
  EnglishWord(
    word: 'sun',
    pronunciation: '/sʌn/',
    meaning: '太阳',
    imageAsset: '☀️',
    category: 'nature',
    examples: ['The sun is bright.', 'I love the sunny day.'],
  ),
  EnglishWord(
    word: 'moon',
    pronunciation: '/muːn/',
    meaning: '月亮',
    imageAsset: '🌙',
    category: 'nature',
    examples: ['The moon is round tonight.', 'I saw the moon last night.'],
  ),
  EnglishWord(
    word: 'book',
    pronunciation: '/bʊk/',
    meaning: '书',
    imageAsset: '📚',
    category: 'objects',
    examples: ['I read a book every day.', 'This is my favorite book.'],
  ),
  EnglishWord(
    word: 'house',
    pronunciation: '/haʊs/',
    meaning: '房子',
    imageAsset: '🏠',
    category: 'places',
    examples: ['My house has three rooms.', 'The house is beautiful.'],
  ),
  EnglishWord(
    word: 'water',
    pronunciation: '/ˈwɔːtər/',
    meaning: '水',
    imageAsset: '💧',
    category: 'liquids',
    examples: ['I drink water every day.', 'The water is cold.'],
  ),
  EnglishWord(
    word: 'milk',
    pronunciation: '/mɪlk/',
    meaning: '牛奶',
    imageAsset: '🥛',
    category: 'liquids',
    examples: ['I drink milk in the morning.', 'The milk is fresh.'],
  ),
];

// 加载英语单词数据
Future<void> loadEnglishWordsData() async {
  print('Starting to load English words from CSV...');
  final loadedWords = await CsvService.loadEnglishWords();
  print('Loaded ${loadedWords.length} words from CSV');
  if (loadedWords.isNotEmpty) {
    englishWordsData = loadedWords;
    print('Successfully loaded ${englishWordsData.length} words from CSV');
  } else {
    // 如果CSV加载失败，使用默认数据
    englishWordsData = defaultEnglishWordsData;
    print('CSV load failed, using default ${englishWordsData.length} words');
  }
}
