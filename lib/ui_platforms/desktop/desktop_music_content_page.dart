import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/extensions/audio_file_extensions.dart';
import 'package:than_sound/core/extensions/dur_ext.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';

class DesktopMusicContentPage extends StatefulWidget {
  const DesktopMusicContentPage({super.key});

  @override
  State<DesktopMusicContentPage> createState() =>
      _DesktopMusicContentPageState();
}

class _DesktopMusicContentPageState extends State<DesktopMusicContentPage> {
  final PlayerStateController playerController =
      ControllerManager.read<PlayerStateController>();
  Player get player => playerController.player;

  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerController.current,
      builder: (context, current, child) {
        if (current == null) {
          return SizedBox.shrink();
        }
        return SizedBox(
          width: 400,
          child: Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: .blur(sigmaX: 5, sigmaY: 5),
                  child: AudioThumbnail(file: current),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: col.surfaceContainer.withValues(alpha: .45),
                ),
              ),

              _body(current),
            ],
          ),
        );
      },
    );
  }

  Padding _body(AudioFile current) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          Text(
            current.autoTitle,
            maxLines: 2,
            overflow: .ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: .w700,
              color: col.onSurface,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: ClipRRect(
                  borderRadius: .circular(15),
                  child: AudioThumbnail(file: current),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(current.meta.artist),
                    Text(current.meta.album),
                    Text(current.meta.genre),
                    Text(current.yearLabel),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          // controls
          Row(
            mainAxisAlignment: .center,
            children: [
              IconButton(
                onPressed: () {
                  playerController.audioHandler.skipToPrevious();
                },
                icon: Icon(Icons.skip_previous_outlined, size: 35),
              ),
              StreamBuilder(
                stream: playerController.audioHandler.player.stream.playing,
                builder: (context, asyncSnapshot) {
                  final playing =
                      playerController.audioHandler.player.state.playing;
                  return IconButton(
                    onPressed: () {
                      if (playing) {
                        playerController.audioHandler.pause();
                      } else {
                        playerController.audioHandler.play();
                      }
                    },
                    icon: Icon(
                      playing
                          ? Icons.pause_circle_filled_outlined
                          : Icons.play_circle_fill_outlined,
                      size: 60,
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  playerController.audioHandler.skipToNext();
                },
                icon: Icon(Icons.skip_next_outlined, size: 35),
              ),
            ],
          ),
          SizedBox(height: 20),
          // slider
          StreamBuilder(
            stream: player.stream.position,
            builder: (context, asyncSnapshot) {
              return Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(thumbShape: .noThumb),
                    child: CSlider(
                      max: player.state.duration.inSeconds.toDouble(),
                      value: player.state.position.inSeconds.toDouble(),
                      onChangeEnd: (value) {
                        playerController.audioHandler.seek(
                          Duration(seconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(player.state.position.formatMusicTimer()),
                      Spacer(),
                      Text(player.state.duration.formatMusicTimer()),
                    ],
                  ),
                ],
              );
            },
          ),

          // SizedBox(height: 10),
        ],
      ),
    );
  }
}
