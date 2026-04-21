import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/english_data.dart';
import '../../services/tts_service.dart';
import '../../providers/learning_provider.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TtsService _ttsService = TtsService();
  late List<dynamic> _reviewWords;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _reviewWords = List.from(englishWordsData)..shuffle();
    _totalCount = _reviewWords.length;
  }

  void _handleResponse(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _correctCount++;
        final learningProvider = context.read<LearningProvider>();
        final currentWord = _reviewWords[_currentIndex];
        learningProvider.markEnglishWordLearned(currentWord.word);
        _currentIndex++;

        if (_currentIndex >= _reviewWords.length) {
          _showResult();
        }
      } else {
        // 点击"不认识"，显示单词详情
        _showWordDetail();
      }
    });
  }

  void _showWordDetail() {
    final currentWord = _reviewWords[_currentIndex];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentWord.imageAsset,
              style: const TextStyle(fontSize: 48),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentWord.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF42A5F5),
              ),
            ),
            Text(
              currentWord.pronunciation,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF66BB6A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '中文含义：',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentWord.meaning,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF42A5F5),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (currentWord.examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '例句：',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...currentWord.examples.map((example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $example',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _ttsService.speakEnglish(currentWord.word);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up, color: Color(0xFF42A5F5)),
                SizedBox(width: 4),
                Text('听发音'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex++;
                if (_currentIndex >= _reviewWords.length) {
                  _showResult();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66BB6A),
            ),
            child: const Text('知道了，继续'),
          ),
        ],
      ),
    );
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('复习完成！'),
        content: Text('你答对了 $_correctCount 题，共 $_totalCount 题'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/');
            },
            child: const Text('返回首页'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _reviewWords.shuffle();
                _currentIndex = 0;
                _correctCount = 0;
              });
            },
            child: const Text('重新复习'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _reviewWords.length) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Center(
          child: const Text('复习完成！'),
        ),
      );
    }

    final currentWord = _reviewWords[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7043),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      '← 返回',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const Text(
                    '🏆 勋章墙',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),

            // 核心视觉区
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentWord.imageAsset,
                      style: const TextStyle(fontSize: 120),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentWord.word,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF42A5F5),
                      ),
                    ),
                    Text(
                      currentWord.pronunciation,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 主交互按钮
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  _ttsService.speakEnglish(currentWord.word);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      '点击听发音',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            // 二选一反馈按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _handleResponse(true),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF66BB6A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '👍 认识',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _handleResponse(false),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🤔 不认识',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            // 进度条
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalCount,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: index < _currentIndex
                              ? const Color(0xFFFF7043)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_currentIndex + 1}/$_totalCount',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
