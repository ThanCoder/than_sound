import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/custom_widgets/icon_menu_list_tile.dart';
import 'package:than_sound/ui_platforms/pages/art_cover_manager_page.dart';
import 'package:than_sound/ui_platforms/pages/audio_info_page.dart';

class DesktopAudioItemMenu extends StatefulWidget {
  final AudioFile file;
  const DesktopAudioItemMenu({super.key, required this.file});

  @override
  State<DesktopAudioItemMenu> createState() => _DesktopAudioItemMenuState();
}

class _DesktopAudioItemMenuState extends State<DesktopAudioItemMenu> {
  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
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
            leadIcon: Icon(Icons.audiotrack_outlined),
            trailingIcon: Icon(Icons.arrow_right),
            onTap: () {
              context.pop();
              context.pushMaterialPageRoute(
                builder: (mainCtx) => AudioInfoPage(file: widget.file),
              );
            },
          ),
          IconMenuListTile(
            title: 'Cover Art',
            subTitle: 'Manage Audio Cover Art',
            leadIcon: Icon(Icons.art_track),
            trailingIcon: Icon(Icons.arrow_right),
            onTap: () {
              context.pop();
              context.pushMaterialPageRoute(
                builder: (mainCtx) => ArtCoverManagerPage(file: widget.file),
              );
            },
          ),
        ],
      ),
    );
  }
}
