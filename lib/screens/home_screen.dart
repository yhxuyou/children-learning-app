import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '🎉 欢迎来到',
                    style: TextStyle(fontSize: 24, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '儿童英语乐园',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '一起快乐学习英语吧！',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    context,
                    title: '英语学习',
                    subtitle: '掌握英语单词',
                    icon: '🔤',
                    color: const Color(0xFF42A5F5),
                    onTap: () => context.push('/english'),
                  ),
                  _buildModuleCard(
                    context,
                    title: '游戏中心',
                    subtitle: '边玩边学习',
                    icon: '🎮',
                    color: const Color(0xFF66BB6A),
                    onTap: () => context.push('/games'),
                  ),
                  _buildModuleCard(
                    context,
                    title: '家长中心',
                    subtitle: '查看学习进度',
                    icon: '👨‍👩‍👧',
                    color: const Color(0xFFAB47BC),
                    onTap: () => context.push('/parent'),
                  ),
                  _buildModuleCard(
                    context,
                    title: '更多功能',
                    subtitle: '即将上线',
                    icon: '✨',
                    color: const Color(0xFFFFCA28),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/ai-companion'),
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Text(
                      'AI学习伙伴',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
