import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:than_sound/audio/thumbnail.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class ListItem extends StatelessWidget {
  final AudioFile file;
  final void Function(AudioFile file) onClicked;
  const ListItem({super.key, required this.file, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    final con = context.read<PlayerStateController>();

    return ValueListenableBuilder(
      valueListenable: con.current,
      builder: (context, current, child) {
        final isCurrent = (current != null && current.id == file.id);
        return GestureDetector(
          onTap: () => onClicked(file),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                spacing: 4,
                children: [
                  SizedBox(width: 90, height: 90, child: Thumbnail(file: file)),
                  Expanded(child: contentTextWidget),
                  if (isCurrent)
                    StreamBuilder(
                      stream: con.stream.playing,
                      builder: (context, asyncSnapshot) {
                        return MiniMusicVisualizer(
                          color: Colors.red,
                          width: 4,
                          height: 15,
                          animate: con.state.playing,
                        );
                      },
                    ),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get contentTextWidget {
    return Column(
      spacing: 3,
      crossAxisAlignment: .start,
      children: [
        Text(
          'T: ${file.autoTitle}',
          maxLines: 1,
          overflow: .ellipsis,
          style: TextStyle(fontWeight: .w400, fontSize: 11),
        ),
        Row(
          spacing: 3,
          children: [
            Text(
              file.meta.formatLabel,
              maxLines: 2,
              overflow: .ellipsis,
              style: TextStyle(fontWeight: .w400, fontSize: 11),
            ),

            Text(
              file.meta.bitrateLabel,
              maxLines: 2,
              overflow: .ellipsis,
              style: TextStyle(fontWeight: .w400, fontSize: 11),
            ),
            Text(
              file.meta.bitrateMode,
              maxLines: 2,
              overflow: .ellipsis,
              style: TextStyle(fontWeight: .w400, fontSize: 11),
            ),
            Text(
              file.meta.sampleRateLabel,
              maxLines: 2,
              overflow: .ellipsis,
              style: TextStyle(fontWeight: .w400, fontSize: 11),
            ),
          ],
        ),
        Text(
          file.meta.duration.formatClockLabel(),
          maxLines: 2,
          overflow: .ellipsis,
          style: TextStyle(fontWeight: .w400, fontSize: 11),
        ),
      ],
    );
  }
}
