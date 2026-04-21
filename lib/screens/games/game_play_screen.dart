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
  int? _selectedTime;
  bool _showHint = false;
  
  // 单词接龙游戏数据
  String _currentWord = '';
  TextEditingController _wordController = TextEditingController();
  List<String> _wordChain = [];
  
  // 听力大挑战游戏数据
  String _targetWord = '';
  List<String> _options = [];
  int _listeningMode = 0; // 0: 图片选择, 1: 单词选择, 2: 单词拼写
  List<String> _incorrectWords = [];
  TextEditingController _listeningController = TextEditingController();
  bool _listeningGameOver = false;

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
      _selectedTime = null;
      _showHint = false;
      _wordController.clear();
      _listeningController.clear();
      _wordChain.clear();
      _matchingPairs = [];
      _shuffledPairs = [];
      _targetWord = '';
      _options = [];
      _listeningMode = 0;
      _incorrectWords = [];
      _listeningGameOver = false;

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
    // 从英语单词数据中随机选择10个单词
    final random = Random();
    final selectedWords = List.from(englishWordsData)..shuffle();
    selectedWords.length = 10;

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
    // 随机选择一个目标单词
    final random = Random();
    String targetWord;
    
    // 如果有答错的单词，优先使用答错的单词
    if (_incorrectWords.isNotEmpty) {
      targetWord = _incorrectWords.removeAt(0);
    } else {
      // 从词库中随机选择
      final targetIndex = random.nextInt(englishWordsData.length);
      targetWord = englishWordsData[targetIndex].word;
    }
    
    _targetWord = targetWord;
    _options = [];

    switch (_listeningMode) {
      case 0: // 图片选择模式
        // 生成3个图片选项
        _options = [_targetWord];
        while (_options.length < 3) {
          final randomWord = englishWordsData[random.nextInt(englishWordsData.length)].word;
          if (!_options.contains(randomWord)) {
            _options.add(randomWord);
          }
        }
        _options.shuffle();
        break;
        
      case 1: // 单词选择模式
        // 生成3个单词选项
        _options = [_targetWord];
        while (_options.length < 3) {
          final randomWord = englishWordsData[random.nextInt(englishWordsData.length)].word;
          if (!_options.contains(randomWord)) {
            _options.add(randomWord);
          }
        }
        _options.shuffle();
        break;
        
      case 2: // 单词拼写模式
        // 不需要生成选项，用户自己输入
        _options = [];
        _listeningController.clear();
        break;
    }
  }

  void _handleMatchingItemSelect(Map<String, dynamic> item) {
    setState(() {
      if (_selectedItem == null) {
        // 第一次选择
        _selectedItem = item;
        _selectedTime = DateTime.now().millisecondsSinceEpoch;
        _showHint = false;
        
        // 启动定时器，20秒后显示提示
        Future.delayed(const Duration(seconds: 20), () {
          if (_selectedItem != null) {
            setState(() {
              _showHint = true;
            });
          }
        });
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
        _selectedTime = null;
        _showHint = false;
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
        
        // 检查是否还有题目
        if (_incorrectWords.isEmpty && _currentQuestion >= 9) {
          // 所有题目都答对了
          if (_listeningMode < 2) {
            // 询问是否继续挑战下一模式
            _showContinueDialog();
          } else {
            // 所有模式都完成了
            _showListeningGameComplete();
          }
        } else {
          // 继续当前模式
          _currentQuestion++;
          _initializeListeningGame();
        }
      } else {
        // 答错了，添加到答错列表
        if (!_incorrectWords.contains(_targetWord)) {
          _incorrectWords.add(_targetWord);
        }
        // 重新开始当前题目
        _initializeListeningGame();
      }
    });
  }

  void _handleListeningSubmit() {
    final input = _listeningController.text.trim().toLowerCase();
    setState(() {
      if (input == _targetWord.toLowerCase()) {
        _score += 20;
        
        // 检查是否还有题目
        if (_incorrectWords.isEmpty && _currentQuestion >= 9) {
          // 所有题目都答对了
          _showListeningGameComplete();
        } else {
          // 继续当前模式
          _currentQuestion++;
          _initializeListeningGame();
        }
      } else {
        // 答错了，添加到答错列表
        if (!_incorrectWords.contains(_targetWord)) {
          _incorrectWords.add(_targetWord);
        }
        // 重新开始当前题目
        _initializeListeningGame();
      }
    });
  }

  void _showContinueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('挑战成功！'),
        content: Text('你已经完成了${_listeningMode == 0 ? '图片选择' : '单词选择'}模式，是否继续挑战下一模式？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showGameOver();
            },
            child: const Text('返回游戏中心'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _listeningMode++;
                _currentQuestion = 0;
                _incorrectWords = [];
                _initializeListeningGame();
              });
            },
            child: const Text('继续挑战'),
          ),
        ],
      ),
    );
  }

  void _showListeningGameComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恭喜你！'),
        content: const Text('你已经完成了所有听力挑战，全部答对了！'),
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
              // 只在非单词配对游戏中显示logo和描述
              if (widget.gameId != 'english_word_match') ...[
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
              ],
              
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
            final isHint = _showHint && _selectedItem != null && item['matchId'] == _selectedItem!['matchId'] && item['id'] != _selectedItem!['id'];
            
            return GestureDetector(
              onTap: () => _handleMatchingItemSelect(item),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF66BB6A).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(color: const Color(0xFF66BB6A), width: 2)
                      : isHint
                          ? Border.all(color: const Color(0xFF42A5F5), width: 2, style: BorderStyle.dashed)
                          : null,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _listeningMode == 0 ? '图片选择模式' : _listeningMode == 1 ? '单词选择模式' : '单词拼写模式',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF42A5F5),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _ttsService.speakEnglish(_targetWord),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up, size: 24),
              SizedBox(width: 12),
              Text('听发音', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 48),
        
        // 根据不同模式显示不同界面
        if (_listeningMode == 0) // 图片选择模式
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              final wordData = englishWordsData.firstWhere((w) => w.word == option);
              return GestureDetector(
                onTap: () => _handleListeningOptionSelect(option),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      wordData.imageAsset,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              );
            },
          )
        else if (_listeningMode == 1) // 单词选择模式
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              return ElevatedButton(
                onPressed: () => _handleListeningOptionSelect(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF66BB6A),
                  side: const BorderSide(color: Color(0xFF66BB6A), width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            },
          )
        else if (_listeningMode == 2) // 单词拼写模式
          Column(
            children: [
              TextField(
                controller: _listeningController,
                decoration: InputDecoration(
                  hintText: '请输入你听到的单词',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _handleListeningSubmit(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleListeningSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('提交', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }
}

