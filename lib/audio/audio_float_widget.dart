import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/audio/thumbnail.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/router.dart';

class AudioFloatWidget extends StatelessWidget {
  const AudioFloatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final con = context.read<PlayerStateController>();
    return InkWell(
      onTap: () => goContent(context),
      child: StreamBuilder(
        stream: con.stream.playlist,
        builder: (context, asyncSnapshot) {
          if (con.current == null || !con.showFloatWidget.value) {
            return SizedBox.shrink();
          }
          final current = con.current!;

          return StreamBuilder(
            stream: con.stream.playing,
            builder: (context, asyncSnapshot) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(222, 16, 15, 15),
                  borderRadius: .circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    spacing: 3,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Thumbnail(file: current),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: con.stream.position,
                          builder: (context, asyncSnapshot) {
                            return Column(
                              spacing: 2,
                              children: [
                                Text(
                                  current.autoTitle,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: .w400,
                                  ),
                                ),
                                LinearProgressIndicator(
                                  value:
                                      con.state.position.inSeconds /
                                      con.state.duration.inSeconds,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${con.state.position.formatClockLabel()}/${con.state.duration.formatClockLabel()}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: .w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          con.prev();
                        },
                        icon: Icon(Icons.skip_previous),
                      ),
                      IconButton(
                        onPressed: () {
                          con.toggle();
                        },
                        icon: Icon(
                          con.state.playing ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          con.next();
                        },
                        icon: Icon(Icons.skip_next),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
