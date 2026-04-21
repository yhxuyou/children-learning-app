import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/english_word.dart';

class CsvService {
  static Future<List<EnglishWord>> loadEnglishWords() async {
    try {
      // 读取CSV文件内容
      final csvContent = await rootBundle.loadString('assets/english_words.csv');
      
      // 解析CSV内容
      final lines = csvContent.split('\n');
      if (lines.isEmpty) {
        return [];
      }
      
      // 跳过标题行
      final words = <EnglishWord>[];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        // 解析CSV行
        final parts = _parseCsvLine(line);
        if (parts.length >= 6) {
          final word = parts[0];
          final pronunciation = parts[1];
          final meaning = parts[2];
          final imageAsset = parts[3];
          final category = parts[4];
          
          // 解析examples字段
          final examplesStr = parts[5];
          final examples = examplesStr.split(',').map((e) => e.trim()).toList();
          
          words.add(EnglishWord(
            word: word,
            pronunciation: pronunciation,
            meaning: meaning,
            imageAsset: imageAsset,
            category: category,
            examples: examples,
          ));
        }
      }
      
      return words;
    } catch (e) {
      print('Error loading CSV: $e');
      return [];
    }
  }
  
  // 解析CSV行，处理包含逗号的字段
  static List<String> _parseCsvLine(String line) {
    final parts = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        // 检查是否是转义的引号（两个连续引号）
        if (i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // 跳过下一个引号
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        parts.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    parts.add(buffer.toString());
    return parts;
  }
}
