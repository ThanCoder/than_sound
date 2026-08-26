import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/extensions/audio_file_extensions.dart';
import 'package:than_sound/core/extensions/dur_ext.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_item_menu.dart';

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

  void showItemMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => AudioItemMenu(
        file: playerController.current.value!,
        showContentAnimation: true,
      ),
    );
  }

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

  Widget _body(AudioFile current) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: .center,
          children: [
            Text(
              current.autoTitle,
              maxLines: 2,
              overflow: .ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: .w700,
                color: col.onSurface,
              ),
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: .start,
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
                      Text(
                        current.meta.artist,
                        style: TextStyle(color: col.onSurface),
                      ),
                      Text(
                        current.meta.album,
                        style: TextStyle(color: col.onSurface),
                      ),
                      Text(
                        current.meta.genre,
                        style: TextStyle(color: col.onSurface),
                      ),
                      Text(
                        current.yearLabel,
                        style: TextStyle(color: col.onSurface),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: col.surfaceContainer.withValues(
                      alpha: .45,
                    ),
                    foregroundColor: col.onSurfaceVariant,
                  ),
                  onPressed: showItemMenu,
                  icon: Icon(Icons.more_horiz_outlined),
                ),
              ],
            ),
            SizedBox(height: 40),

            // controls
            _controls(),
            SizedBox(height: 20),
            // slider
            _slider(),

            // SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  StreamBuilder<Duration> _slider() {
    return StreamBuilder(
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
                Text(
                  player.state.position.formatMusicTimer(),
                  style: TextStyle(color: col.onSurface, fontWeight: .w600),
                ),
                Spacer(),
                Text(
                  player.state.duration.formatMusicTimer(),
                  style: TextStyle(color: col.onSurface, fontWeight: .w600),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Row _controls() {
    return Row(
      mainAxisAlignment: .center,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: col.primaryContainer,
            foregroundColor: col.onPrimaryContainer,
          ),
          onPressed: () {
            playerController.audioHandler.skipToPrevious();
          },
          icon: Icon(Icons.skip_previous_outlined, size: 30),
        ),
        SizedBox(width: 30),
        StreamBuilder(
          stream: playerController.audioHandler.player.stream.playing,
          builder: (context, asyncSnapshot) {
            final playing = playerController.audioHandler.player.state.playing;
            return IconButton(
              style: IconButton.styleFrom(
                backgroundColor: col.primary,
                foregroundColor: col.onPrimary,
              ),
              onPressed: () {
                if (playing) {
                  playerController.audioHandler.pause();
                } else {
                  playerController.audioHandler.play();
                }
              },
              icon: Icon(
                playing ? Icons.pause : Icons.play_arrow_outlined,
                size: 45,
              ),
            );
          },
        ),
        SizedBox(width: 30),

        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: col.primaryContainer,
            foregroundColor: col.onPrimaryContainer,
          ),
          onPressed: () {
            playerController.audioHandler.skipToNext();
          },
          icon: Icon(Icons.skip_next_outlined, size: 30),
        ),
      ],
    );
  }
}
