import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/audio/audio_sliver_list.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({super.key});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  Future<void> init() async {
    final con = context.read<AllFileStateController>();
    await con.scanFromStorage();
    if (!mounted) return;
    context.read<PlayerStateController>().setTracks(con.files);
  }

  @override
  Widget build(BuildContext context) {
    final con = context.read<AllFileStateController>();
    return StreamBuilder(
      stream: con.stream,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("ThanAudio"),
            actions: [
              if (Platform.isLinux)
                IconButton(onPressed: init, icon: Icon(Icons.refresh)),
            ],
          ),
          body: bodyWidget,
        );
      },
    );
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

    return RefreshIndicator.adaptive(
      onRefresh: init,
      child: CustomScrollView(
        slivers: [
          if (state.isLoading && con.files.isNotEmpty)
            SliverToBoxAdapter(child: LinearProgressIndicator()),

          AudioSliverList(list: con.files),
        ],
      ),
    );
  }
}
