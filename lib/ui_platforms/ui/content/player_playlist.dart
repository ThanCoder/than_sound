import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/ui/audio/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/ui/audio/list_gps_button.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';

class PlayerPlaylist extends StatefulWidget {
  const PlayerPlaylist({super.key});

  @override
  State<PlayerPlaylist> createState() => _PlayerPlaylistState();
}

class _PlayerPlaylistState extends State<PlayerPlaylist> {
  final controller = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        goListGps();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(child: headerWidget()),
            listWidget(),
          ],
        ),

        Positioned(
          right: 5,
          bottom: 5,
          child: ListGpsButton(onClicked: goListGps),
        ),
      ],
    );
  }

  Padding headerWidget() {
    final con = ControllerManager.read<PlayerStateController>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CurrentMusicVisualizerWidget(),
          SizedBox(width: 10),
          if (con.current.value != null)
            Expanded(
              child: Text(
                'T: ${con.current.value!.autoTitle}',
                maxLines: 2,
                overflow: .ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: .bold,
                  fontStyle: .italic,
                ),
              ),
            ),
          Spacer(),
          SortButton(
            value: .dateSortItem,
            list: [.dateSortItem, .nameSortItem, .sizeSortItem],
          ),
        ],
      ),
    );
  }

  StreamBuilder listWidget() {
    final con = ControllerManager.read<PlayerStateController>();
    return StreamBuilder(
      stream: con.stream.playbackState,
      builder: (context, asyncSnapshot) {
        return AudioSliverList(
          list: con.files,
          onClicked: (file) async {
            final con = ControllerManager.read<PlayerStateController>();
            con.open(file);
          },
        );
      },
    );
  }

  void goListGps() {
    try {
      final con = ControllerManager.read<PlayerStateController>();
      final current = con.current.value;
      if (current == null) return;
      final index = con.files.indexWhere((e) => e.id == current.id);
      if (index == -1) return;
      final size = MediaQuery.of(context).size;
      final offset = (audioSliverListItemHeight * index) - (size.height * 0.3);
      if (!controller.hasClients) return;
      controller.animateTo(
        offset.clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        ),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
