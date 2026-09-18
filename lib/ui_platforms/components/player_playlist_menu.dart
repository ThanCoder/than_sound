import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/components/audio_list_item.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/components/list_gps_button.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/pages/partials/sort_provider.dart';

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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final pCon = ControllerManager.read<PlayerStateController>();

  void playAudio(AudioFile file) {
    pCon.actions.open(file);
  }

  void onMenu(AudioFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AudioItemMenu(file: file, showDeleteAction: true),
    );
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
    return StreamBuilder(
      stream: pCon.stream.playOrder,
      builder: (context, asyncSnapshot) {
        return SliverReorderableList(
          itemCount: pCon.state.playOrder.length,
          itemExtent: audioSliverListItemHeight,
          onReorderItem: (oldIndex, newIndex) {
            final item = pCon.state.playOrder.removeAt(oldIndex);
            pCon.state.playOrder.insert(newIndex, item);
            setState(() {});
          },
          itemBuilder: (context, index) {
            final item = pCon.state.playOrder[index];

            return ReorderableDelayedDragStartListener(
              key: ValueKey(item.id),
              index: index,
              child: AudioListItem(
                file: item,
                onClicked: (file) {
                  final con = ControllerManager.read<PlayerStateController>();
                  con.actions.open(file);
                },
                onMenuClicked: (file) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) =>
                        AudioItemMenu(file: file, showDeleteAction: true),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
