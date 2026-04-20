import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/chinese_data.dart';
import '../../services/tts_service.dart';

class ChineseLearningScreen extends StatefulWidget {
  const ChineseLearningScreen({super.key});

  @override
  State<ChineseLearningScreen> createState() => _ChineseLearningScreenState();
}

class _ChineseLearningScreenState extends State<ChineseLearningScreen> {
  final TtsService _ttsService = TtsService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final characters = chineseCharactersData;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('汉字学习', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: const Color(0xFFFF7043),
                ),
                GestureDetector(
                  onTap: () {
                    _ttsService.speakChinese(characters[_currentIndex].character);
                  },
                  child: Container(
                    width: 120,
                    height: 120,
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
                    child: Center(
                      child: Text(
                        characters[_currentIndex].character,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7043),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _currentIndex < characters.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: const Color(0xFFFF7043),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('拼音', characters[_currentIndex].pinyin),
                    _buildInfoItem('释义', characters[_currentIndex].meaning),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  '笔画: ${characters[_currentIndex].strokes.join(" → ")}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  '组词',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: characters[_currentIndex].words.map((word) {
                    return GestureDetector(
                      onTap: () => _ttsService.speakChinese(word),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7043).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF7043).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFFF7043),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  '例句',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                  ),
                ),
                const SizedBox(height: 8),
                ...characters[_currentIndex].sentences.map((sentence) {
                  return GestureDetector(
                    onTap: () => _ttsService.speakChinese(sentence),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('🔊', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sentence,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                context.push('/chinese/${characters[_currentIndex].character}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '开始练习',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF7043),
          ),
        ),
      ],
    );
  }
}
