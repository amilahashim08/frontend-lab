import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/services/tts_platform_service.dart';

/// Text-to-speech for Learn + Interview (Jarvis-style: clear, deep, full volume).
class LearnNarration {
  LearnNarration._();
  static final LearnNarration instance = LearnNarration._();

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> speaking = ValueNotifier(false);

  bool _ready = false;
  bool _platformSetupDone = false;
  bool _available = true;
  bool _lessonInProgress = false;
  String _status = 'Not initialized';

  String get status => _status;
  bool get isSpeaking => speaking.value;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  void _setSpeaking(bool value) {
    if (speaking.value == value) return;
    speaking.value = value;
  }

  Future<void> _ensurePlatformSetup() async {
    if (_platformSetupDone) return;
    _platformSetupDone = true;
    if (!TtsPlatformService.isAndroid) return;
    final info = await TtsPlatformService.autoSetup();
    final engine = info['selectedEngine']?.toString() ?? '';
    if (engine.isNotEmpty) {
      _status = 'Engine: $engine';
    }
    await TtsPlatformService.boostVolume();
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    try {
      await _ensurePlatformSetup();
      await _tts.awaitSpeakCompletion(true);
      await _tts.setQueueMode(0);

      _tts.setStartHandler(() => _setSpeaking(true));
      _tts.setCompletionHandler(() {
        if (!_lessonInProgress) _setSpeaking(false);
      });
      _tts.setCancelHandler(() {
        _lessonInProgress = false;
        _setSpeaking(false);
      });
      _tts.setErrorHandler((message) {
        _lessonInProgress = false;
        _status = 'TTS error: $message';
        _setSpeaking(false);
      });

      if (_isAndroid) {
        await _pickAndroidEngine();
      }

      await _configureJarvisVoice();
      await _ensureEnglishVoiceData();
      _available = true;
      _status = 'Jarvis voice ready';
    } catch (e) {
      _available = false;
      _status = 'TTS init failed: $e';
    }
    _ready = true;
  }

  Future<void> _pickAndroidEngine() async {
    final engines = await _tts.getEngines;
    if (engines is! List || engines.isEmpty) return;

    final defaultEngine = await _tts.getDefaultEngine;
    final defaultName = defaultEngine?.toString().toLowerCase() ?? '';
    if (defaultName.contains('google')) return;

    final engine = engines
        .map((e) => e.toString())
        .firstWhere(
          (e) => e.toLowerCase().contains('google'),
          orElse: () => engines.first.toString(),
        );
    if (engine != defaultName) {
      await _tts.setEngine(engine);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> _ensureEnglishVoiceData() async {
    if (!_isAndroid) return;
    for (final locale in const ['en-US', 'en-GB', 'en']) {
      try {
        if (await _tts.isLanguageAvailable(locale) == true) return;
      } catch (_) {}
    }
    await TtsPlatformService.installVoiceDataIfNeeded();
  }

  /// Deep, deliberate, full-volume delivery (Jarvis-like).
  Future<void> _configureJarvisVoice() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.82);
    await _tts.setSpeechRate(0.44);

    const locales = ['en-GB', 'en-US', 'en'];
    for (final locale in locales) {
      try {
        if (await _tts.isLanguageAvailable(locale) == true) {
          await _tts.setLanguage(locale);
          break;
        }
      } catch (_) {}
    }

    try {
      final voices = await _tts.getVoices;
      if (voices is! List || voices.isEmpty) return;

      Map<String, String>? picked;
      var bestScore = -1;
      for (final raw in voices) {
        if (raw is! Map) continue;
        final name = '${raw['name'] ?? ''}'.toLowerCase();
        final locale = '${raw['locale'] ?? ''}'.toLowerCase();
        if (!locale.contains('en')) continue;

        final voice = raw.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );

        final score = (locale.contains('gb') ? 3 : 0) +
            (name.contains('male') ? 2 : 0) +
            (name.contains('gb') ? 1 : 0);
        if (score > bestScore) {
          picked = voice;
          bestScore = score;
        }
      }
      if (picked != null) {
        final set = await _tts.setVoice(picked);
        if (set == 1) {
          _status = 'Voice: ${picked['name'] ?? 'en'}';
        }
      }
    } catch (_) {}
  }

  /// Android flutter_tts may return 0 after stop() or while the engine is busy.
  bool _isSpeakOk(dynamic result) {
    if (result is! int) return true;
    return result == 1;
  }

  Future<dynamic> _invokeSpeak(String line, {required bool focus}) async {
    if (_isAndroid) {
      return _tts.speak(line, focus: focus);
    }
    return _tts.speak(line);
  }

  Future<bool> _speakWithRetry(String text, {int attempts = 3}) async {
    final line = text.trim();
    if (line.isEmpty) return false;

    for (var i = 0; i < attempts; i++) {
      if (i > 0) {
        await _tts.stop();
        await Future<void>.delayed(Duration(milliseconds: 180 * i));
        await _tts.setVolume(1.0);
      }

      try {
        final result = await _invokeSpeak(line, focus: true);
        if (_isSpeakOk(result)) return true;
      } catch (e) {
        _status = 'Speak failed: $e';
      }
    }

    if (_isAndroid && line.length <= 400) {
      final nativeOk = await TtsPlatformService.testSpeak(line);
      if (nativeOk) {
        _status = 'Speaking via system voice';
        return true;
      }
    }
    return false;
  }

  Future<bool> speak(String text) async {
    await _ensureReady();
    if (!_available || text.trim().isEmpty) return false;
    return _speakWithRetry(text);
  }

  Future<void> _preparePlayback() async {
    _lessonInProgress = false;
    await _tts.stop();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    await TtsPlatformService.boostVolume();
    await _tts.setVolume(1.0);
    await _tts.setQueueMode(0);
  }

  Future<bool> speakLesson({
    required String title,
    required String summary,
    required List<String> bullets,
    required List<String> steps,
  }) async {
    await _ensureReady();
    if (!_available) return false;

    final script = <String>[
      'Alright. Let me explain $title.',
      summary,
      if (bullets.isNotEmpty) 'Here are the key points.',
      ...bullets,
      if (steps.isNotEmpty) 'Diagram steps.',
      ...steps.map((s) => 'Step: $s'),
    ].where((s) => s.trim().isNotEmpty).join(' ');

    if (script.trim().isEmpty) return false;

    await _preparePlayback();

    _lessonInProgress = true;
    _setSpeaking(true);

    try {
      final maxLen = await _maxChunkLength();
      if (script.length <= maxLen) {
        final ok = await _speakWithRetry(script);
        if (!ok) {
          _status = 'Playback stopped — check device media volume.';
        }
        return ok;
      }

      final chunks = _chunkScript(script, maxLen);
      for (final chunk in chunks) {
        if (!_lessonInProgress) return false;
        final ok = await _speakWithRetry(chunk);
        if (!ok) {
          _status = 'Playback stopped — check device media volume.';
          return false;
        }
      }
      return true;
    } finally {
      _lessonInProgress = false;
      _setSpeaking(false);
    }
  }

  Future<int> _maxChunkLength() async {
    try {
      final len = await _tts.getMaxSpeechInputLength;
      if (len is int && len > 400) return len - 80;
    } catch (_) {}
    return 3200;
  }

  List<String> _chunkScript(String script, int maxLen) {
    final sentences = script
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return const [];

    final chunks = <String>[];
    var current = '';
    for (final sentence in sentences) {
      if (current.isEmpty) {
        current = sentence;
        continue;
      }
      if ((current.length + 1 + sentence.length) <= maxLen) {
        current = '$current $sentence';
      } else {
        chunks.add(current);
        current = sentence;
      }
    }
    if (current.isNotEmpty) chunks.add(current);
    return chunks;
  }

  Future<void> stop() async {
    _lessonInProgress = false;
    _setSpeaking(false);
    await _tts.stop();
  }

  /// Tap speaker again while playing → stop.
  Future<bool> toggleLesson({
    required String title,
    required String summary,
    required List<String> bullets,
    required List<String> steps,
  }) async {
    if (isSpeaking) {
      await stop();
      return false;
    }
    return speakLesson(
      title: title,
      summary: summary,
      bullets: bullets,
      steps: steps,
    );
  }
}
