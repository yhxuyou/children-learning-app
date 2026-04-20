import 'package:flutter/material.dart';
import '../../services/tts_service.dart';

class AiCompanionScreen extends StatefulWidget {
  const AiCompanionScreen({super.key});

  @override
  State<AiCompanionScreen> createState() => _AiCompanionScreenState();
}

class _AiCompanionScreenState extends State<AiCompanionScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final List<String> _aiReplies = [
    '你好呀！今天想学什么呢？',
    '太棒了！你真是个爱学习的好孩子！',
    '汉字很有趣哦，让我来教你！',
    '英语单词一点都不难，相信自己！',
    '休息一下也很重要哦，要劳逸结合！',
    '你的发音越来越好了！',
    '这道题你做对了，真厉害！',
    '没关系，我们再来一次！',
  ];

  @override
  void initState() {
    super.initState();
    _addAiMessage('你好！我是你的AI学习伙伴 🤖\n有什么我可以帮助你的吗？');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addAiMessage(String message) {
    setState(() {
      _messages.add({'role': 'ai', 'content': message});
    });
    _ttsService.speakChinese(message);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      final reply = _aiReplies[DateTime.now().second % _aiReplies.length];
      _addAiMessage(reply);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('AI学习伙伴', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isAi = message['role'] == 'ai';

                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isAi ? Colors.white : const Color(0xFFFF7043),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAi ? 0 : 20),
                        bottomRight: Radius.circular(isAi ? 20 : 0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAi) ...[
                          const Text('🤖', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isAi ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ),
                        if (!isAi) ...[
                          const SizedBox(width: 8),
                          const Text('👧', style: TextStyle(fontSize: 24)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '输入你想说的话...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFF8E1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
