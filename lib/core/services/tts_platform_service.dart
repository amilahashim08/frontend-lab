import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only helpers: max volume + TTS engine setup (no manual Settings).
class TtsPlatformService {
  TtsPlatformService._();
  static const _channel = MethodChannel('frontend_lab/tts_setup');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Boost volume and select Google TTS — does not open system voice-install UI.
  static Future<Map<String, dynamic>> autoSetup() async {
    if (!isAndroid) return {'skipped': true};
    try {
      await _channel.invokeMethod<bool>('boostVolume');
      final raw = await _channel.invokeMethod<dynamic>('setupTts', {
        'installVoiceData': false,
      });
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), v));
      }
      return {'ok': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Opens Android voice-data installer (only when English voices are missing).
  static Future<void> installVoiceDataIfNeeded() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('installTtsVoiceData');
    } catch (_) {}
  }

  static Future<bool> testSpeak([String? text]) async {
    if (!isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('testSpeak', {
        'text': text ?? 'Voice is working. Frontend Lab is ready.',
      });
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> boostVolume() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('boostVolume');
    } catch (_) {}
  }
}
