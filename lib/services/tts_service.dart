import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  late final Future<void> _initFuture;

  TtsService._internal() {
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.2);
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> speakChinese(String text) async {
    try {
      await _initFuture;
      await _flutterTts.stop();
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speakChinese error: $e');
    }
  }

  Future<void> speakEnglish(String text) async {
    try {
      await _initFuture;
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speakEnglish error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }
}
