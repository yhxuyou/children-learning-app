import 'package:flutter/material.dart';
import '../../data/games_data.dart';
import '../../data/english_data.dart';
import '../../services/tts_service.dart';
import '../../services/sound_effect_service.dart';
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
  final SoundEffectService _soundEffectService = SoundEffectService();
  
  // 单词配对游戏数据
  List<Map<String, dynamic>> _matchingPairs = [];
  List<Map<String, dynamic>> _shuffledPairs = [];
  Map<String, dynamic>? _selectedItem;
  DateTime? _selectedTime;
  bool _showHint = false;
  bool _hintBlinkOn = false; // 控制虚线框闪烁
  Set<String> _matchedPairs = {}; // 记录已配对的项
  
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
      _hintBlinkOn = false;
      _matchedPairs.clear();
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
        'id': 'word_${word.word}',
        'type': 'word',
        'content': word.word,
        'matchId': word.word,
      });
      _matchingPairs.add({
        'id': 'image_${word.word}',
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
    if (_matchedPairs.contains(item['id'])) return;
    
    _soundEffectService.playClickSound();
    
    setState(() {
      if (_selectedItem == null) {
        _selectedItem = item;
        _selectedTime = DateTime.now();
        _showHint = false;
        _hintBlinkOn = false;
        
        Future.delayed(const Duration(seconds: 20), () {
          if (_selectedItem != null && _selectedItem!['id'] == item['id']) {
            _startHintBlink();
          }
        });
      } else {
        if (_selectedItem!['matchId'] == item['matchId'] && _selectedItem!['type'] != item['type']) {
          _score += 10;
          _soundEffectService.playSuccessSound();
          _matchedPairs.add(item['id']);
          _matchedPairs.add(_selectedItem!['id']);
          
          _shuffledPairs.removeWhere((p) => p['id'] == item['id'] && !_matchedPairs.contains(p['id']));
          _shuffledPairs.removeWhere((p) => p['id'] == _selectedItem!['id'] && !_matchedPairs.contains(p['id']));
          
          if (_shuffledPairs.isEmpty || _matchingPairs.length <= _matchedPairs.length) {
            _showGameOver();
          }
        } else {
          _soundEffectService.playErrorSound();
        }
        _selectedItem = null;
        _selectedTime = null;
        _showHint = false;
        _hintBlinkOn = false;
      }
    });
  }

  void _startHintBlink() {
    if (_selectedItem == null) return;
    
    // 每隔500毫秒切换闪烁状态
    _hintBlinkOn = !_hintBlinkOn;
    setState(() {});
    
    // 继续闪烁直到选中其他项或配对成功
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_selectedItem != null) {
        _startHintBlink();
      }
    });
  }

  void _handleWordChainSubmit() {
    final inputWord = _wordController.text.trim().toLowerCase();
    if (inputWord.isEmpty) return;

    setState(() {
      if (inputWord.startsWith(_currentWord[_currentWord.length - 1])) {
        final isValidWord = englishWordsData.any((word) => word.word.toLowerCase() == inputWord);
        if (isValidWord) {
          if (!_wordChain.contains(inputWord)) {
            _score += 5;
            _soundEffectService.playSuccessSound();
            _wordChain.add(inputWord);
            _currentWord = inputWord;
            _wordController.clear();
          }
        } else {
          _soundEffectService.playErrorSound();
        }
      } else {
        _soundEffectService.playErrorSound();
      }
    });
  }

  void _handleListeningOptionSelect(String option) {
    if (option == _targetWord) {
      _soundEffectService.playSuccessSound();
    } else {
      _soundEffectService.playErrorSound();
    }
    
    setState(() {
      if (option == _targetWord) {
        _score += 15;
        
        if (_incorrectWords.isEmpty && _currentQuestion >= 9) {
          if (_listeningMode < 2) {
            _showContinueDialog();
          } else {
            _showListeningGameComplete();
          }
        } else {
          _currentQuestion++;
          _initializeListeningGame();
        }
      } else {
        if (!_incorrectWords.contains(_targetWord)) {
          _incorrectWords.add(_targetWord);
        }
        _initializeListeningGame();
      }
    });
  }

  void _handleListeningSubmit() {
    final input = _listeningController.text.trim().toLowerCase();
    setState(() {
      if (input == _targetWord.toLowerCase()) {
        _soundEffectService.playSuccessSound();
        _score += 20;
        
        if (_incorrectWords.isEmpty && _currentQuestion >= 9) {
          _showListeningGameComplete();
        } else {
          _currentQuestion++;
          _initializeListeningGame();
        }
      } else {
        _soundEffectService.playErrorSound();
        if (!_incorrectWords.contains(_targetWord)) {
          _incorrectWords.add(_targetWord);
        }
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
                onPressed: () {
                  _soundEffectService.playClickSound();
                  _initializeGame();
                },
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
        const Text(
          '点击图片或单词进行配对',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF66BB6A),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
            final isMatched = _matchedPairs.contains(item['id']);
            final isHint = _showHint && _selectedItem != null && item['matchId'] == _selectedItem!['matchId'] && item['id'] != _selectedItem!['id'];
            final isHintBlink = _hintBlinkOn && _selectedItem != null && item['matchId'] == _selectedItem!['matchId'] && item['id'] != _selectedItem!['id'];
            
            return GestureDetector(
              onTap: isMatched ? null : () => _handleMatchingItemSelect(item),
              child: AnimatedOpacity(
                opacity: isMatched ? 0.3 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: isMatched 
                        ? Colors.grey.withOpacity(0.05)
                        : isSelected 
                            ? const Color(0xFF66BB6A).withOpacity(0.2) 
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: const Color(0xFF66BB6A), width: 2)
                        : isHintBlink
                            ? Border.all(
                                color: const Color(0xFF42A5F5),
                                width: 2,
                                style: BorderStyle.solid,
                              )
                            : isHint
                                ? Border.all(color: const Color(0xFF42A5F5), width: 2, style: BorderStyle.solid)
                                : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                    boxShadow: isHintBlink
                        ? [
                            BoxShadow(
                              color: const Color(0xFF42A5F5).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
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
                            textAlign: TextAlign.center,
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
          onPressed: () {
            _soundEffectService.playClickSound();
            _handleWordChainSubmit();
          },
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
          _listeningMode == 0 ? '听发音选图片' : _listeningMode == 1 ? '听发音选单词' : '听发音写单词',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF42A5F5),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _soundEffectService.playClickSound();
            _ttsService.speakEnglish(_targetWord);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Icon(Icons.volume_up, size: 40),
        ),
        const SizedBox(height: 24),
        
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
              crossAxisCount: 1, // 改为单列显示
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3, // 增加宽高比，使按钮更宽
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
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
                      option,
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF66BB6A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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

