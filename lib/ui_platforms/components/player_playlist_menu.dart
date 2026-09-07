import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/ui/audio/list_gps_button.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/ui/partials/sort_provider.dart';

class PlayerPlaylistMenu extends StatefulWidget {
  const PlayerPlaylistMenu({super.key});

  @override
  State<PlayerPlaylistMenu> createState() => _PlayerPlaylistMenuState();
}

class _PlayerPlaylistMenuState extends State<PlayerPlaylistMenu> {
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
          right: 15,
          bottom: 50,
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
          if (con.state.current != null)
            Expanded(
              child: Text(
                'T: ${con.state.current!.autoTitle}',
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
      stream: con.stream.playOrder,
      builder: (context, asyncSnapshot) {
        return AudioSliverList(
          list: con.state.playOrder,
          onClicked: (file) async {
            final con = ControllerManager.read<PlayerStateController>();
            con.actions.open(file);
          },
        );
      },
    );
  }

  void goListGps() {
    try {
      final con = ControllerManager.read<PlayerStateController>();
      final current = con.state.current;
      if (current == null) return;
      final index = con.state.files.indexWhere((e) => e.id == current.id);
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
