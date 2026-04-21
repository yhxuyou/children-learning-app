import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundEffectService {
  static final SoundEffectService _instance = SoundEffectService._internal();
  factory SoundEffectService() => _instance;

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  bool _initialized = false;

  SoundEffectService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _clickPlayer.setReleaseMode(ReleaseMode.stop);
      await _successPlayer.setReleaseMode(ReleaseMode.stop);
      await _errorPlayer.setReleaseMode(ReleaseMode.stop);
      _initialized = true;
    } catch (e) {
      debugPrint('SoundEffectService init error: $e');
    }
  }

  Future<void> playClickSound() async {
    try {
      await initialize();
      await _clickPlayer.stop();
      await _clickPlayer.setSource(UrlSource('https://assets.mixkit.co/sfx/preview/mixkit-modern-technology-select-3124.mp3'));
      await _clickPlayer.setVolume(0.5);
      await _clickPlayer.resume();
    } catch (e) {
      debugPrint('Play click sound error: $e');
    }
  }

  Future<void> playSuccessSound() async {
    try {
      await initialize();
      await _successPlayer.stop();
      await _successPlayer.setSource(UrlSource('https://assets.mixkit.co/sfx/preview/mixkit-arcade-game-jump-coin-216.mp3'));
      await _successPlayer.setVolume(0.6);
      await _successPlayer.resume();
    } catch (e) {
      debugPrint('Play success sound error: $e');
    }
  }

  Future<void> playErrorSound() async {
    try {
      await initialize();
      await _errorPlayer.stop();
      await _errorPlayer.setSource(UrlSource('https://assets.mixkit.co/sfx/preview/mixkit-wrong-answer-fail-notification-946.mp3'));
      await _errorPlayer.setVolume(0.5);
      await _errorPlayer.resume();
    } catch (e) {
      debugPrint('Play error sound error: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _clickPlayer.dispose();
      await _successPlayer.dispose();
      await _errorPlayer.dispose();
    } catch (e) {
      debugPrint('SoundEffectService dispose error: $e');
    }
  }
}
