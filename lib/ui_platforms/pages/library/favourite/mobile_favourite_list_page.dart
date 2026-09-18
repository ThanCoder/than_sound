import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/platform_util.dart';
import 'package:than_sound/ui_platforms/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_now_playing_page.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_float_widget.dart';
import 'package:than_sound/ui_platforms/components/audio_list_item.dart';
import 'package:than_sound/ui_platforms/pages/library/favourite/favourite_controller.dart';

class MobileFavouriteListPage extends StatefulWidget {
  const MobileFavouriteListPage({super.key});

  @override
  State<MobileFavouriteListPage> createState() =>
      _MobileFavouriteListPageState();
}

class _MobileFavouriteListPageState extends State<MobileFavouriteListPage> {
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final controller = ScrollController();
  final con = ControllerManager.read<FavouriteController>();
  final pCon = ControllerManager.read<PlayerStateController>();

  void playAudio(AudioFile file) {
    final current = pCon.state.current;
    if (current != null && current.id == file.id && pCon.state.playing) {
      if (PlatformUtil.isDesktopNotifier.value) {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => DesktopNowPlayingPage(),
        );
      }
      return;
    }
    pCon.actions.setTracks(con.files, source: const FavouriteStateSource());
    pCon.actions.open(file);
    pCon.actions.setShowFloatingWidget(true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourite List"),
        actions: [
          if (TPlatform.isDesktop)
            IconButton(
              onPressed: () {
                con.init();
              },
              icon: Icon(Icons.refresh_outlined),
            ),
        ],
      ),
      body: bodyWidget,
    );
  }

  Widget get bodyWidget {
    return StreamBuilder(
      stream: con.event,
      builder: (context, snapshot) {
        if (con.files.isEmpty) {
          return Center(
            child: RefreshButton(
              text: Text('List Empty!'),
              onClicked: con.load,
            ),
          );
        }

        return _scrollView();
      },
    );
  }

  RefreshIndicator _scrollView() {
    return RefreshIndicator.adaptive(
      onRefresh: con.load,
      child: Stack(
        children: [
          CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: controller,
            slivers: [
              _listWidget(),
              StreamBuilder(
                stream: pCon.stream.showFloatingWidgetChanged,
                builder: (context, snapshot) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: pCon.state.showFloatWidget ? 130 : 90,
                    ),
                  );
                },
              ),
            ],
          ),
          // floating widget
          ValueListenableBuilder(
            valueListenable: PlatformUtil.isDesktopNotifier,
            builder: (context, isDesktop, child) {
              if (isDesktop) {
                return SizedBox.shrink();
              }
              return Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: AudioFloatWidget(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _listWidget() {
    return SliverReorderableList(
      itemCount: con.files.length,
      itemExtent: audioSliverListItemHeight,
      onReorderItem: (oldIndex, newIndex) {
        final item = con.files.removeAt(oldIndex);
        con.files.insert(newIndex, item);
        con.save();
        pCon.actions.setSource(NoneAudioSource());
        setState(() {});
      },
      itemBuilder: (context, index) {
        final item = con.files[index];
        if (PlatformUtil.isDesktopNotifier.value) {
          return Row(
            key: ValueKey(item.id),
            children: [
              Expanded(
                child: AudioListItem(
                  file: item,
                  onClicked: playAudio,
                  onMenuClicked: onMenu,
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Icon(Icons.drag_handle),
              ),
              SizedBox(width: 10),
            ],
          );
        }

        return ReorderableDelayedDragStartListener(
          key: ValueKey(item.id),
          index: index,
          child: AudioListItem(
            file: item,
            onClicked: playAudio,
            onMenuClicked: onMenu,
          ),
        );
      },
    );
  }
}
