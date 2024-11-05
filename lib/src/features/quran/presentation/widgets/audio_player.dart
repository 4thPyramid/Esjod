import 'package:assets_audio_player/assets_audio_player.dart';

class AudioP {
  static final AudioP _notificationService = AudioP._internal();

  factory AudioP() {
    return _notificationService;
  }
  AudioP._internal();
  static AssetsAudioPlayer get player => AssetsAudioPlayer.withId('0');
}
