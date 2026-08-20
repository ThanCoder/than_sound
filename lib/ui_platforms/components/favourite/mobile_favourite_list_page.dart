import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_float_widget.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_controller.dart';

class MobileFavouriteListPage extends StatefulWidget {
  const MobileFavouriteListPage({super.key});

  @override
  State<MobileFavouriteListPage> createState() => _MobileFavouriteListPageState();
}

class _MobileFavouriteListPageState extends State<MobileFavouriteListPage> {
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final controller = ScrollController();

  Future<void> init({bool usedCache = true}) async {
    // final con = ControllerManager.read<FavouriteController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favourite List")),
      body: bodyWidget,
    );
  }

  Widget get bodyWidget {
    final con = ControllerManager.read<FavouriteController>();
    return StreamBuilder(
      stream: con.eventStream,
      builder: (context, snapshot) {
        if (con.files.isEmpty) {
          return Center(
            child: RefreshButton(text: Text('List Empty!'), onClicked: init),
          );
        }
        final pCon = ControllerManager.read<PlayerStateController>();
        return RefreshIndicator.adaptive(
          onRefresh: () => init(usedCache: false),
          child: Stack(
            children: [
              CustomScrollView(
                controller: controller,
                slivers: [
                  AudioSliverList(
                    list: con.files,
                    onClicked: (file) async {
                      pCon.setTracks(con.files, source: .favouriteState);
                      pCon.open(file);
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: pCon.showFloatWidget,
                    builder: (context, value, child) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: pCon.showFloatWidget.value ? 130 : 90,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // floating widget
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: AudioFloatWidget(),
              ),
            ],
          ),
        );
      },
    );
  }

  
}
