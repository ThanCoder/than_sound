import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/funcs.dart';
import 'package:than_sound/ui_platforms/components/audio_sliver_list.dart';

class AudioFolderViewPage extends StatefulWidget {
  const new({super.key, required this.title});
  final String title;

  @override
  State<AudioFolderViewPage> createState() => _AudioFolderViewPageState();
}

class _AudioFolderViewPageState extends State<AudioFolderViewPage> {
  final con = ControllerManager.read<AllFileStateController>();
  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: con.resetEvent,
            builder: (context, asyncSnapshot) {
              final files = con.folders[widget.title] ?? [];
              return AudioSliverList(
                list: files,
                onClicked: (file) {
                  openConfirmAndPlay(
                    context,
                    file: file,
                    source: LibStateSource(widget.title),
                    sourceFiles: files,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
