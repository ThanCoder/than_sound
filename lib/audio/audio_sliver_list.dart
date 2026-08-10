import 'package:flutter/material.dart';
import 'package:than_sound/audio/list_item.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioSliverList extends StatelessWidget {
  final List<AudioFile> list;
  const AudioSliverList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => listItem(context, list[index]),
    );
  }

  Widget listItem(BuildContext context, AudioFile file) {
    return ListItem(
      file: file,
      onClicked: (file) async{
        final con = context.read<PlayerStateController>();
        if (con.files.isEmpty) {
          await con.setTracks(context.read<AllFileStateController>().files);
        }
        // con.open(file);
        con.openById(file.id);
      },
    );
  }
}
