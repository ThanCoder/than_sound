import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_audio_item_menu.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_controller.dart';

class DesktopFavouriteListPage extends StatefulWidget {
  const DesktopFavouriteListPage({super.key});

  @override
  State<DesktopFavouriteListPage> createState() =>
      _DesktopFavouriteListPageState();
}

class _DesktopFavouriteListPageState extends State<DesktopFavouriteListPage> {
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final controller = ScrollController();

  Future<void> init({bool usedCache = true}) async {
    // final con = ControllerManager.read<FavouriteController>();
  }

  final plC = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favourite List")),
      body: bodyWidget,
    );
  }

  final con = ControllerManager.read<FavouriteController>();
  Widget get bodyWidget {
    return StreamBuilder(
      stream: con.eventStream,
      builder: (context, snapshot) {
        if (con.files.isEmpty) {
          return Center(
            child: RefreshButton(text: Text('List Empty!'), onClicked: init),
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: () => init(usedCache: false),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    DesktopAudioSliverList(
                      files: con.files,
                      currentNotifier: plC.current,
                      onTap: onTap,
                      onSecondaryTap: onSecondaryTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onTap(AudioFile file) async {
    await plC.setTracks(con.files, source: .allFileState);
    if (plC.isCurrentFile(file)) {
      await plC.play();
    } else {
      await plC.open(file);
    }
    if (!plC.showFloatWidget.value) {
      plC.showFloatWidget.value = true;
    }
  }

  void onSecondaryTap(AudioFile file) {
    showDialog(
      context: context,
      builder: (context) => DesktopAudioItemMenu(file: file),
    );
  }
}
