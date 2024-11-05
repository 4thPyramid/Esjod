import 'package:assets_audio_player/assets_audio_player.dart';

Future launchSystemAlertWindowsDialog() async {
  final AssetsAudioPlayer audioP = AssetsAudioPlayer();
  audioP.open(
    Audio(
      'assets/saly.mp3',
    ),
  );
}
