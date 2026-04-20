import '../models/game.dart';

final List<Game> gamesData = [
  Game(
    id: 'chinese_puzzle',
    name: '汉字拼图',
    description: '把汉字的各个部分拼在一起',
    type: 'chinese',
    difficulty: 1,
    iconAsset: '🧩',
  ),
  Game(
    id: 'chinese_matching',
    name: '汉字连线',
    description: '把汉字和它的意思连起来',
    type: 'chinese',
    difficulty: 1,
    iconAsset: '🔗',
  ),
  Game(
    id: 'chinese_word_hunt',
    name: '汉字消消乐',
    description: '找出相同的汉字',
    type: 'chinese',
    difficulty: 2,
    iconAsset: '⚡',
  ),
  Game(
    id: 'english_word_match',
    name: '单词配对',
    description: '把单词和图片配对',
    type: 'english',
    difficulty: 1,
    iconAsset: '🎴',
  ),
  Game(
    id: 'english_word_chain',
    name: '单词接龙',
    description: '用最后一个字母接龙',
    type: 'english',
    difficulty: 2,
    iconAsset: '🔤',
  ),
  Game(
    id: 'english_listening',
    name: '听力大挑战',
    description: '听发音选单词',
    type: 'english',
    difficulty: 3,
    iconAsset: '👂',
  ),
];
