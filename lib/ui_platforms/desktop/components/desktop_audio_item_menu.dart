import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/custom_widgets/icon_menu_list_tile.dart';

class DesktopAudioItemMenu extends StatefulWidget {
  final AudioFile file;
  const DesktopAudioItemMenu({super.key, required this.file});

  @override
  State<DesktopAudioItemMenu> createState() => _DesktopAudioItemMenuState();
}

class _DesktopAudioItemMenuState extends State<DesktopAudioItemMenu> {
  late final col = context.colorScheme;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      backgroundColor: col.surfaceContainer,
      title: Text(
        widget.file.autoTitle,
        maxLines: 2,
        overflow: .ellipsis,
        style: TextStyle(color: col.primary, fontWeight: .bold, fontSize: 19),
      ),
      content: Column(
        spacing: 5,
        children: [
          IconMenuListTile(
            title: 'Audio Info',
            subTitle: 'view audio metadata and file infomation...',
            leadIcon: Icons.audiotrack_outlined,
            trailingIcon: Icons.arrow_right,
          ),
          IconMenuListTile(
            title: 'Info',
            subTitle: '',
            leadIcon: Icons.info,
            trailingIcon: Icons.arrow_right,
          ),
        ],
      ),
    );
  }
}
