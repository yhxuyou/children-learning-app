import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/english_data.dart';

class ParentCenterScreen extends StatefulWidget {
  const ParentCenterScreen({super.key});

  @override
  State<ParentCenterScreen> createState() => _ParentCenterScreenState();
}

class _ParentCenterScreenState extends State<ParentCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadProgress();
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('家长中心', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFAB47BC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<LearningProvider, SettingsProvider>(
        builder: (context, learningProvider, settingsProvider, child) {
          final progress = learningProvider.progress;
          final settings = settingsProvider;
          final totalWords = englishWordsData.length;
          final learnedWords = progress.masteredEnglishWords.length;
          final unlearnedWords = totalWords - learnedWords;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 英语学习报告',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAB47BC),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => _showWordList(context, '所有单词', englishWordsData.map((w) => w.word).toList()),
                            child: _buildStatItem(
                              '总单词数',
                              '$totalWords',
                              '📚',
                              Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showWordList(context, '已学单词', progress.masteredEnglishWords),
                            child: _buildStatItem(
                              '已学单词',
                              '$learnedWords',
                              '✅',
                              Colors.green,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final unlearnedWordList = englishWordsData
                                  .where((w) => !progress.masteredEnglishWords.contains(w.word))
                                  .map((w) => w.word)
                                  .toList();
                              _showWordList(context, '未学单词', unlearnedWordList);
                            },
                            child: _buildStatItem(
                              '未学单词',
                              '$unlearnedWords',
                              '📖',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(
                            '学习时长',
                            '${progress.totalStudyTime}分钟',
                            '⏰',
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '⚙️ 设置',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAB47BC),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.timer, color: Color(0xFFAB47BC)),
                        title: const Text('每日使用时间限制'),
                        trailing: Text(
                          '${settings.dailyTimeLimit}分钟',
                          style: const TextStyle(color: Color(0xFFAB47BC)),
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up, color: Color(0xFFAB47BC)),
                        title: const Text('声音'),
                        value: settings.soundEnabled,
                        onChanged: (value) {
                          settingsProvider.setSoundEnabled(value);
                        },
                        activeColor: const Color(0xFFAB47BC),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.speed, color: Color(0xFFAB47BC)),
                        title: const Text('难度级别'),
                        trailing: DropdownButton<String>(
                          value: settings.difficultyLevel,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'easy', child: Text('简单')),
                            DropdownMenuItem(value: 'medium', child: Text('中等')),
                            DropdownMenuItem(value: 'hard', child: Text('困难')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              settingsProvider.setDifficultyLevel(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '🏆 已学单词',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAB47BC),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '已掌握的单词:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: progress.masteredEnglishWords.isEmpty
                            ? [const Text('暂无', style: TextStyle(color: Colors.black38))]
                            : progress.masteredEnglishWords
                                .map((w) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF42A5F5).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        w,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF42A5F5),
                                        ),
                                      ),
                                    ))
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void _showWordList(BuildContext context, String title, List<String> words) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words.isEmpty
                  ? [const Text('暂无数据', style: TextStyle(color: Colors.black38))]
                  : words
                      .map((w) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF42A5F5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              w,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF42A5F5),
                              ),
                            ),
                          ))
                      .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
