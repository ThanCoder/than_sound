import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/pages/audio_folder/audio_folder_view_page.dart';

class AudioFolderPage extends StatefulWidget {
  const new({super.key});

  @override
  State<AudioFolderPage> createState() => _AudioFolderPageState();
}

class _AudioFolderPageState extends State<AudioFolderPage> {
  final con = ControllerManager.read<AllFileStateController>();
  ColorScheme get col => Theme.of(context).colorScheme;

  void goFolderView(String title) {
    context.pushMaterialPageRoute(
      builder: (mainCtx) => AudioFolderViewPage(title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Folders')),
      body: _body,
    );
  }

  Widget get _body {
    return StreamBuilder(
      stream: con.resetEvent,
      builder: (context, asyncSnapshot) {
        final folders = con.folders;
        return ListView.separated(
          itemCount: folders.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final fo = folders.entries.elementAt(index);
            final title = fo.key;
            final files = fo.value;
            return listItem(title, files);
          },
        );
      },
    );

    // return GridView.builder(
    //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //     maxCrossAxisExtent: 160,
    //     mainAxisExtent: 120,
    //     mainAxisSpacing: 4,
    //     crossAxisSpacing: 4,
    //   ),
    //   itemCount: folders.length,
    //   itemBuilder: (context, index) {
    //     final fo = folders.entries.elementAt(index);
    //     final title = fo.key;
    //     final files = fo.value;

    //     return gridItem(title, files);
    //   },
    // );
  }

  Widget listItem(String title, List<AudioFile> files) {
    return GestureDetector(
      onTap: () => goFolderView(title),
      child: Container(
        decoration: BoxDecoration(
          color: col.surfaceContainer,
          borderRadius: .circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 80),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 2,
                children: [Text(title), Text('Count: ${files.length}')],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gridItem(String title, List<AudioFile> files) {
    return Stack(
      fit: .expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: col.surfaceContainer,
            borderRadius: .circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.folder_outlined, size: 80),
              Expanded(child: Text(title)),
            ],
          ),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: .symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(
              color: col.primary,
              borderRadius: .circular(15),
            ),
            child: Text(
              files.length.toString().padLeft(2, '0'),
              style: TextStyle(color: col.onPrimary, fontWeight: .w700),
            ),
          ),
        ),
      ],
    );
  }
}
