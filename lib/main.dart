import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/router.dart';
import 'providers/learning_provider.dart';
import 'providers/settings_provider.dart';
import 'data/english_data.dart';

void main() async {
  // 加载英语单词数据
  await loadEnglishWordsData();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const ChildrenLearningApp(),
    ),
  );
}

class ChildrenLearningApp extends StatelessWidget {
  const ChildrenLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '儿童学习乐园',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
