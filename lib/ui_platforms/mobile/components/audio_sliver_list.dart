import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_list_item.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioSliverList extends StatelessWidget {
  final List<AudioFile> list;
  final void Function(AudioFile) onClicked;
  const AudioSliverList({
    super.key,
    required this.list,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList.builder(
      itemCount: list.length,
      itemExtent: audioSliverListItemHeight,
      itemBuilder: (context, index) => listItem(context, list[index]),
    );
  }

  Widget listItem(BuildContext context, AudioFile file) {
    return AudioListItem(
      file: file,
      onClicked: onClicked,
      onMenuClicked: (file) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              AudioItemMenu(file: file, showDeleteAction: true),
        );
      },
    );
  }
}
