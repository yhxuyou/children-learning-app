import 'package:flutter/material.dart';
import '../../data/chinese_data.dart';
import '../../services/tts_service.dart';

class ChineseDetailScreen extends StatefulWidget {
  final String character;

  const ChineseDetailScreen({super.key, required this.character});

  @override
  State<ChineseDetailScreen> createState() => _ChineseDetailScreenState();
}

class _ChineseDetailScreenState extends State<ChineseDetailScreen> {
  final TtsService _ttsService = TtsService();
  int _currentStrokeIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final charData = chineseCharactersData.firstWhere(
      (c) => c.character == widget.character,
      orElse: () => chineseCharactersData.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text('学习 ${widget.character}'),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    widget.character,
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7043),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    charData.pinyin,
                    style: const TextStyle(fontSize: 24, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    charData.meaning,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '笔画演示',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      charData.strokes[_currentStrokeIndex],
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color(0xFFFF7043),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '第 ${_currentStrokeIndex + 1} 笔 / 共 ${charData.strokes.length} 笔',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentStrokeIndex > 0
                      ? () {
                          setState(() {
                            _currentStrokeIndex--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('上一笔'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF7043),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _currentStrokeIndex < charData.strokes.length - 1
                      ? () {
                          setState(() {
                            _currentStrokeIndex++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('下一笔'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _ttsService.speakChinese(widget.character);
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('听发音'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '书写练习',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7043),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF7043).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  '在这里书写汉字',
                  style: TextStyle(color: Colors.black38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
