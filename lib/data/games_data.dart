import '../models/game.dart';

final List<Game> gamesData = [
  Game(
    id: 'english_word_match',
    name: '单词配对',
    description: '',
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

