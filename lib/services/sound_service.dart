import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static const double _backgroundVolume = 0.15;
  static const String _backgroundSound = 'sounds/ocean.mp3';
  static const String _clickSound = 'sounds/click.mp3';
  static const String _correctSound = 'sounds/correct.mp3';
  static const String _wrongSound = 'sounds/wrong.mp3';
  static const String _victorySound = 'sounds/victory.mp3';

  static final AudioPlayer _backgroundPlayer = AudioPlayer(
    playerId: 'grammar_bubbles_background',
  );
  static final AudioPlayer _effectPlayer = AudioPlayer(
    playerId: 'grammar_bubbles_effects',
  );

  static bool soundEnabled = true;
  static bool musicEnabled = true;

  static Future<void>? _initializing;
  static bool _initialized = false;
  static bool _backgroundPlaying = false;

  SoundService._();

  static Future<void> initialize() {
    if (_initialized) return Future.value();

    _initializing ??= _configurePlayers();
    return _initializing!;
  }

  static Future<void> _configurePlayers() async {
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_backgroundVolume);

      await _effectPlayer.setReleaseMode(ReleaseMode.stop);
      await _effectPlayer.setPlayerMode(PlayerMode.lowLatency);

      _initialized = true;
    } catch (error, stackTrace) {
      _logAudioError('initialize', error, stackTrace);
      _initializing = null;
    }
  }

  static Future<void> startBackground() async {
    if (!musicEnabled) {
      await stopBackground();
      return;
    }

    await initialize();
    if (_backgroundPlaying) return;

    try {
      await _backgroundPlayer.play(
        AssetSource(_backgroundSound),
        volume: _backgroundVolume,
      );
      _backgroundPlaying = true;
    } catch (error, stackTrace) {
      _backgroundPlaying = false;
      _logAudioError('startBackground', error, stackTrace);
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _backgroundPlayer.stop();
    } catch (error, stackTrace) {
      _logAudioError('stopBackground', error, stackTrace);
    } finally {
      _backgroundPlaying = false;
    }
  }

  static Future<void> playClick() => _playEffect(_clickSound);

  static Future<void> playCorrect() => _playEffect(_correctSound);

  static Future<void> playWrong() => _playEffect(_wrongSound);

  static Future<void> playVictory() => _playEffect(_victorySound);

  static Future<void> dispose() async {
    await _backgroundPlayer.dispose();
    await _effectPlayer.dispose();
    _initialized = false;
    _initializing = null;
    _backgroundPlaying = false;
  }

  static Future<void> _playEffect(String assetPath) async {
    if (!soundEnabled) return;

    await initialize();

    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(assetPath));
    } catch (error, stackTrace) {
      _logAudioError('playEffect', error, stackTrace);
    }
  }

  static void _logAudioError(
    String action,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;

    debugPrint('SoundService.$action failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
