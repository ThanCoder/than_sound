import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class Thumbnail extends StatelessWidget {
  final AudioFile file;
  const Thumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final con = context.read<PlayerStateController>();
    var playing = false;
    var isCurrent = (con.current != null && con.current!.id == file.id);

    if (con.current != null && con.current!.id == file.id) {
      playing = con.state.playing;
    }
    return ClipRRect(
      borderRadius: .circular(4),
      child: imageWidget,

      // Stack(
      //   children: [
      //     Positioned.fill(child: imageWidget),
      //     if (isCurrent)
      //       Container(
      //         decoration: BoxDecoration(
      //           color: const Color.fromARGB(72, 0, 0, 0),
      //         ),
      //         child: Center(
      //           child: Icon(
      //             playing ? Icons.play_circle : Icons.pause_circle,
      //             size: 90,
      //             color: const Color.fromARGB(119, 33, 149, 243),
      //           ),
      //         ),
      //       ),

      //     // Positioned(child: child)
      //   ],
      // ),
    );
  }

  Widget get imageWidget {
    final f = File(file.cacheCoverPath);
    if (!f.existsSync()) {
      return Icon(Icons.music_note, size: 50);
    }
    return Image.file(
      f,
      fit: .cover,
      errorBuilder: (context, error, stackTrace) {
        return Text(error.toString());
      },
    );
  }
}
