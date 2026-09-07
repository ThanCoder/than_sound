import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_float_widget.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';

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
        final pCon = ControllerManager.read<PlayerStateController>();
        return RefreshIndicator.adaptive(
          onRefresh: con.load,
          child: Stack(
            children: [
              CustomScrollView(
                controller: controller,
                slivers: [
                  AudioSliverList(
                    list: con.files,
                    onClicked: (file) async {
                      pCon.actions.setTracks(
                        con.files,
                        source: const FavouriteStateSource(),
                      );
                      pCon.actions.open(file);
                    },
                  ),
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
