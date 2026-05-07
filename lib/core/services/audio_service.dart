import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';



class AudioService {
  final AudioPlayer _oneShot = AudioPlayer();
  bool _contextSet = false;

  Future<void> _ensureContext() async {
    if (_contextSet) return;
    _contextSet = true;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      debugPrint('[AudioService] audio context set');
    } catch (e) {
      debugPrint('[AudioService] context set failed: $e');
    }
  }

  Future<void> _playAsset(String fileName) async {
    debugPrint('[AudioService] play sounds/$fileName');
    await _ensureContext();
    try {
      await _oneShot.play(AssetSource('sounds/$fileName'));
      debugPrint('[AudioService] play OK: $fileName');
      return;
    } catch (e) {
      debugPrint('[AudioService] play FAILED $fileName: $e');
    }
    try {
      await SystemSound.play(SystemSoundType.click);
      debugPrint('[AudioService] system click fallback');
    } catch (_) {}
  }

  Future<void> _vibrate({int duration = 200}) async {
    try {
      final has = await Vibration.hasVibrator();
      if (has == true) {
        Vibration.vibrate(duration: duration);
      }
    } catch (_) {}
  }

  Future<void> playRequest() async {
    await _vibrate(duration: 100);
    await _playAsset('request.wav');
  }

  Future<void> playDriverFound() async {
    await _vibrate(duration: 250);
    await _playAsset('found.wav');
  }

  Future<void> playArrived() async {
    await _vibrate(duration: 150);
    await _playAsset('arrived.wav');
  }

  Future<void> playStart() async {
    await _vibrate(duration: 150);
    await _playAsset('start.wav');
  }

  Future<void> playComplete() async {
    await _vibrate(duration: 300);
    await _playAsset('complete.wav');
  }

  Future<void> dispose() async {
    await _oneShot.dispose();
  }
}
