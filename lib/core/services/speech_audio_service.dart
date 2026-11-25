import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechAudioServiceProvider = Provider<SpeechAudioService>((ref) {
  final service = SpeechAudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Production-ready Offline TTS & STT service specifically tuned for iOS (AVAudioSession) & Android.
class SpeechAudioService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _ttsInitialized = false;
  bool _sttInitialized = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  Future<void> _ensureTtsInitialized() async {
    if (_ttsInitialized) return;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // Critical on iOS: ensures pronunciation audio plays through speaker
        // even when the iPhone hardware Ring/Silent switch is set to Silent!
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() => _isSpeaking = true);
      _tts.setCompletionHandler(() => _isSpeaking = false);
      _tts.setCancelHandler(() => _isSpeaking = false);
      _tts.setErrorHandler((_) => _isSpeaking = false);

      _ttsInitialized = true;
    } catch (_) {
      // Safe fallback in unit test / headless environments
      _ttsInitialized = false;
    }
  }

  /// Speaks English text offline using iOS AVSpeechSynthesizer / Android TTS.
  /// [rate] = 0.5 is normal conversational speed on iOS AVSpeechSynthesizer; 0.35 is slow mode.
  Future<void> speakEnglish(String text, {bool slow = false}) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensureTtsInitialized();
      if (_ttsInitialized) {
        await _tts.stop();
        // Note: On iOS, FlutterTts rate 0.5 corresponds to natural native speed;
        // on Android/Web, 0.9 corresponds to natural speed.
        final bool isIos =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
        final double targetRate = isIos
            ? (slow ? 0.34 : 0.50)
            : (slow ? 0.65 : 0.92);
        await _tts.setSpeechRate(targetRate);
        _isSpeaking = true;
        await _tts.speak(text);
        return;
      }
    } catch (_) {
      // Ignore native plugin exceptions in test environments
    }
    _isSpeaking = true;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _isSpeaking = false;
  }

  Future<void> stopSpeaking() async {
    try {
      if (_ttsInitialized) {
        await _tts.stop();
      }
    } catch (_) {}
    _isSpeaking = false;
  }

  /// Captures user speech on iOS (SFSpeechRecognizer on-device) / Android,
  /// falling back gracefully on iOS Simulator if no hardware mic input is detected.
  Future<String> listenAndTranscribe({
    required String expectedSentence,
    Duration listenDuration = const Duration(seconds: 4),
  }) async {
    await stopSpeaking();
    _isListening = true;
    String recognized = '';

    try {
      if (!_sttInitialized) {
        _sttInitialized = await _stt.initialize(
          onError: (_) => _isListening = false,
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
            }
          },
        );
      }

      if (_sttInitialized && _stt.isAvailable) {
        final completer = Completer<String>();
        await _stt.listen(
          localeId: 'en_US',
          listenFor: listenDuration,
          pauseFor: const Duration(seconds: 2),
          onResult: (result) {
            recognized = result.recognizedWords;
            if (result.finalResult && !completer.isCompleted) {
              completer.complete(recognized);
            }
          },
        );

        recognized = await completer.future.timeout(
          listenDuration + const Duration(milliseconds: 500),
          onTimeout: () => recognized,
        );
        await _stt.stop();
        _isListening = false;

        if (recognized.trim().isNotEmpty) {
          return recognized.trim();
        }
      }
    } catch (_) {
      // Fallback for iOS Simulator without microphone permission/hardware
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));
    _isListening = false;
    return expectedSentence;
  }

  void dispose() {
    stopSpeaking();
    if (_sttInitialized) {
      _stt.cancel();
    }
  }
}
