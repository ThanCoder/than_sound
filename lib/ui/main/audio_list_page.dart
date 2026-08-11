import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_widgets/t_widgets.dart' hide SortButton;
import 'package:than_sound/ui/audio/audio_sliver_list.dart';
import 'package:than_sound/ui/audio/list_gps_button.dart';
import 'package:than_sound/core/const_keys.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui/partials/sort_provider.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({super.key});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  final controller = ScrollController();

  Future<void> init({bool usedCache = true}) async {
    final con = context.read<AllFileStateController>();
    await con.scanFromStorage(usedCache: usedCache);
    if (!mounted) return;

    context.read<PlayerStateController>().setTracks(con.files);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = context.read<AllFileStateController>();
    final pCon = context.read<PlayerStateController>();
    return StreamBuilder(
      stream: con.stream,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          appBar: AppBar(title: Text("ThanAudio"), actions: actions),
          body: Stack(
            children: [
              Positioned.fill(child: bodyWidget),
              if (pCon.current.value != null)
                Positioned(
                  right: 10,
                  bottom: pCon.showFloatWidget.value ? 130 : 70,
                  child: ListGpsButton(onClicked: goListGps),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> get actions {
    final con = context.read<AllFileStateController>();

    return [
      if (Platform.isLinux)
        IconButton(
          onPressed: () => init(usedCache: false),
          icon: Icon(Icons.refresh),
        ),
      SortButton(
        value: con.state.currentSort,
        list: con.sortList,
        onApply: (item) {
          con.setSort(item);
        },
      ),
    ];
  }

  Widget get bodyWidget {
    final con = context.read<AllFileStateController>();
    final state = con.state;
    if (state.isLoading && con.files.isEmpty) {
      return Center(child: TLoaderRandom());
    }
    if (con.state.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          con.state.errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    if (con.files.isEmpty) {
      return Center(
        child: RefreshButton(text: Text('List Empty!'), onClicked: init),
      );
    }
    final pCon = context.read<PlayerStateController>();
    return RefreshIndicator.adaptive(
      onRefresh: () => init(usedCache: false),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          if (state.isLoading && con.files.isNotEmpty)
            SliverToBoxAdapter(child: LinearProgressIndicator()),
          SliverToBoxAdapter(child: headerWidget),
          AudioSliverList(
            list: con.files,
            onClicked: (file) async {
              await pCon.setTracks(
                context.read<AllFileStateController>().files,
                source: .allFileState,
              );
              // print('item: $file');
              pCon.open(file);
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: pCon.showFloatWidget.value ? 130 : 90),
          ),
        ],
      ),
    );
  }

  Widget get headerWidget {
    final con = context.read<AllFileStateController>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/music-svgrepo-com.svg',
            width: 25,
            height: 25,
          ),
          Text(
            '${con.files.length}',
            style: TextStyle(fontSize: 18, fontWeight: .bold),
          ),
        ],
      ),
    );
  }

  void goListGps() {
    try {
      final con = context.read<PlayerStateController>();
      final current = con.current.value;
      if (current == null) return;
      final allCon = context.read<AllFileStateController>();
      final index = allCon.files.indexWhere((e) => e.id == current.id);
      if (index == -1) return;
      final size = MediaQuery.of(context).size;
      final offset = (audioSliverListItemHeight * index) - (size.height * 0.3);

      controller.animateTo(
        offset.clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        ),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
