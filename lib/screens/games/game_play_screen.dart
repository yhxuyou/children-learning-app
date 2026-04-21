import 'package:flutter/material.dart';
import '../../data/games_data.dart';
import '../../data/english_data.dart';
import '../../services/tts_service.dart';
import 'dart:math';

class GamePlayScreen extends StatefulWidget {
  final String gameId;

  const GamePlayScreen({super.key, required this.gameId});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  int _score = 0;
  int _currentQuestion = 0;
  final TtsService _ttsService = TtsService();
  
  // 单词配对游戏数据
  List<Map<String, dynamic>> _matchingPairs = [];
  List<Map<String, dynamic>> _shuffledPairs = [];
  Map<String, dynamic>? _selectedItem;
  
  // 单词接龙游戏数据
  String _currentWord = '';
  TextEditingController _wordController = TextEditingController();
  List<String> _wordChain = [];
  
  // 听力大挑战游戏数据
  String _targetWord = '';
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    setState(() {
      _score = 0;
      _currentQuestion = 0;
      _selectedItem = null;
      _wordController.clear();
      _wordChain.clear();
      _matchingPairs = [];
      _shuffledPairs = [];
      _targetWord = '';
      _options = [];

      switch (widget.gameId) {
        case 'english_word_match':
          _initializeMatchingGame();
          break;
        case 'english_word_chain':
          _initializeWordChainGame();
          break;
        case 'english_listening':
          _initializeListeningGame();
          break;
      }
    });
  }

  void _initializeMatchingGame() {
    // 从英语单词数据中随机选择6个单词
    final random = Random();
    final selectedWords = List.from(englishWordsData)..shuffle();
    selectedWords.length = 6;

    // 创建配对数据
    for (var word in selectedWords) {
      _matchingPairs.add({
        'id': word.word,
        'type': 'word',
        'content': word.word,
        'matchId': word.word,
      });
      _matchingPairs.add({
        'id': word.word,
        'type': 'image',
        'content': word.imageAsset,
        'matchId': word.word,
      });
    }

    // 打乱配对顺序
    _shuffledPairs = List.from(_matchingPairs)..shuffle();
  }

  void _initializeWordChainGame() {
    // 随机选择一个起始单词
    final random = Random();
    _currentWord = englishWordsData[random.nextInt(englishWordsData.length)].word;
    _wordChain.add(_currentWord);
  }

  void _initializeListeningGame() {
    // 随机选择一个目标单词和三个干扰选项
    final random = Random();
    final targetIndex = random.nextInt(englishWordsData.length);
    _targetWord = englishWordsData[targetIndex].word;

    // 生成选项
    _options = [_targetWord];
    while (_options.length < 4) {
      final randomWord = englishWordsData[random.nextInt(englishWordsData.length)].word;
      if (!_options.contains(randomWord)) {
        _options.add(randomWord);
      }
    }
    _options.shuffle();
  }

  void _handleMatchingItemSelect(Map<String, dynamic> item) {
    setState(() {
      if (_selectedItem == null) {
        // 第一次选择
        _selectedItem = item;
      } else {
        // 第二次选择，检查是否匹配
        if (_selectedItem!['matchId'] == item['matchId'] && _selectedItem!['type'] != item['type']) {
          // 匹配成功
          _score += 10;
          _shuffledPairs.removeWhere((p) => p['id'] == item['id']);
          _shuffledPairs.removeWhere((p) => p['id'] == _selectedItem!['id']);
          
          if (_shuffledPairs.isEmpty) {
            // 游戏结束
            _showGameOver();
          }
        }
        _selectedItem = null;
      }
    });
  }

  void _handleWordChainSubmit() {
    final inputWord = _wordController.text.trim().toLowerCase();
    if (inputWord.isEmpty) return;

    setState(() {
      // 检查单词是否以当前单词的最后一个字母开头
      if (inputWord.startsWith(_currentWord[_currentWord.length - 1])) {
        // 检查单词是否在英语单词数据中
        final isValidWord = englishWordsData.any((word) => word.word.toLowerCase() == inputWord);
        if (isValidWord) {
          // 检查单词是否已经在接龙中使用过
          if (!_wordChain.contains(inputWord)) {
            _score += 5;
            _wordChain.add(inputWord);
            _currentWord = inputWord;
            _wordController.clear();
          }
        }
      }
    });
  }

  void _handleListeningOptionSelect(String option) {
    setState(() {
      if (option == _targetWord) {
        _score += 15;
      }
      _currentQuestion++;

      if (_currentQuestion < 10) {
        _initializeListeningGame();
      } else {
        _showGameOver();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束！'),
        content: Text('你的得分：$_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('返回游戏中心'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text('重新开始'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = gamesData.firstWhere(
      (g) => g.id == widget.gameId,
      orElse: () => gamesData.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: Text(game.name),
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                game.iconAsset,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              Text(
                game.description,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '得分: ',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF66BB6A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // 根据游戏类型显示不同的游戏界面
              if (widget.gameId == 'english_word_match')
                _buildMatchingGame()
              else if (widget.gameId == 'english_word_chain')
                _buildWordChainGame()
              else if (widget.gameId == 'english_listening')
                _buildListeningGame(),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _initializeGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '重新开始',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingGame() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _shuffledPairs.length,
          itemBuilder: (context, index) {
            final item = _shuffledPairs[index];
            final isSelected = _selectedItem != null && _selectedItem!['id'] == item['id'];
            
            return GestureDetector(
              onTap: () => _handleMatchingItemSelect(item),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF66BB6A).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: const Color(0xFF66BB6A), width: 2) : null,
                ),
                child: Center(
                  child: item['type'] == 'image'
                      ? Text(item['content'], style: const TextStyle(fontSize: 32))
                      : Text(
                          item['content'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF42A5F5),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWordChainGame() {
    return Column(
      children: [
        Text(
          '当前单词: $_currentWord',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF42A5F5),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '接龙: ${_wordChain.join(' → ')}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _wordController,
          decoration: InputDecoration(
            hintText: '请输入以 ${_currentWord[_currentWord.length - 1]} 开头的单词',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (_) => _handleWordChainSubmit(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _handleWordChainSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
          ),
          child: const Text('提交'),
        ),
      ],
    );
  }

  Widget _buildListeningGame() {
    return Column(
      children: [
        Text(
          '第 ${_currentQuestion + 1}/10 题',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _ttsService.speakEnglish(_targetWord),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up),
              SizedBox(width: 8),
              Text('听发音', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: _options.map((option) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () => _handleListeningOptionSelect(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF66BB6A),
                  side: const BorderSide(color: Color(0xFF66BB6A), width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

