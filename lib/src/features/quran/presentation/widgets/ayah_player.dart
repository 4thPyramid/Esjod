import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:azkar/src/core/utils/core_theme.dart';
import 'package:flutter/material.dart';

class AyahPlayer extends StatelessWidget {
  final AssetsAudioPlayer audioPlayer;
  final void Function() pinning;
  const AyahPlayer(
      {super.key, required this.audioPlayer, required this.pinning});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: PlayerBuilder.realtimePlayingInfos(
          player: audioPlayer,
          builder: (context, real) => Column(
            children: [
              Slider(
                value: real.currentPosition.inSeconds.toDouble(),
                min: 0,
                thumbColor: secondaryColor,
                activeColor: secondaryColor,
                max: real.duration.inSeconds.toDouble(),
                onChanged: (value) {
                  audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      audioPlayer.previous();
                    },
                    icon: const Icon(
                      Icons.navigate_before,
                      color: whiteColor,
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await audioPlayer.playOrPause();
                      },
                      icon: PlayerBuilder.isPlaying(
                        player: audioPlayer,
                        builder: (context, isPlaying) => isPlaying
                            ? const Icon(
                                Icons.pause,
                                color: secondaryColor,
                              )
                            : const Icon(Icons.play_arrow, color: whiteColor),
                      )),
                  IconButton(
                    onPressed: () {
                      audioPlayer.next();
                    },
                    icon: const Icon(Icons.navigate_next, color: whiteColor),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (real.loopMode == LoopMode.playlist) {
                        await audioPlayer.setLoopMode(LoopMode.single);
                      } else {
                        await audioPlayer.setLoopMode(LoopMode.playlist);
                      }
                    },
                    icon: real.loopMode == LoopMode.single
                        ? const Icon(Icons.repeat_one, color: whiteColor)
                        : const Icon(Icons.repeat, color: whiteColor),
                  ),
                  IconButton(
                    onPressed: pinning,
                    icon: const Icon(
                      Icons.bookmark_outlined,
                      color: whiteColor,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
