import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/english_data.dart';
import '../../services/tts_service.dart';

class EnglishLearningScreen extends StatefulWidget {
  const EnglishLearningScreen({super.key});

  @override
  State<EnglishLearningScreen> createState() => _EnglishLearningScreenState();
}

class _EnglishLearningScreenState extends State<EnglishLearningScreen> {
  final TtsService _ttsService = TtsService();
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
  }

  List<EnglishWord> _getFilteredWords() {
    if (_selectedCategory == 'all') {
      return englishWordsData;
    }
    return englishWordsData
        .where((word) => word.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = _getFilteredWords();

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('英语学习', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF42A5F5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(categoryNames[category] ?? category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF42A5F5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF42A5F5) : Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final word = filteredWords[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/english/${word.word}');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF42A5F5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              word.imageAsset,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    word.word,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF42A5F5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    word.pronunciation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                word.meaning,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _ttsService.speakEnglish(word.word);
                          },
                          icon: const Icon(
                            Icons.volume_up,
                            color: Color(0xFF42A5F5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
