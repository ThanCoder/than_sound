import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/ui/audio/audio_list_header.dart';
import 'package:than_sound/ui_platforms/ui/audio/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/ui/audio/list_gps_button.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/ui/partials/sort_provider.dart';

class AudioListPage extends StatefulWidget {
  final double? listGpsButtonRightPos;
  final double? listGpsButtonBottomPos;
  const AudioListPage({
    super.key,
    this.listGpsButtonRightPos,
    this.listGpsButtonBottomPos,
  });

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  final controller = ScrollController();

  Future<void> init({bool usedCache = true}) async {
    final con = ControllerManager.read<AllFileStateController>();
    await con.scanFromStorage(usedCache: usedCache);
    if (!mounted) return;

    ControllerManager.read<PlayerStateController>().setTracks(
      con.files,
      source: .allFileState,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<AllFileStateController>();
    final pCon = ControllerManager.read<PlayerStateController>();
    return StreamBuilder(
      stream: con.stream,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: context.colorScheme.surfaceContainer,
            title: const Text(
              'ThanAudio',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: actions,
            centerTitle: false,
            scrolledUnderElevation: 0,
          ),
          body: Stack(
            children: [
              Positioned.fill(child: bodyWidget),
              // list gps button
              if (widget.listGpsButtonBottomPos != null)
                Positioned(
                  right: widget.listGpsButtonRightPos ?? 10,
                  bottom: widget.listGpsButtonBottomPos,
                  child: ListGpsButton(onClicked: goListGps),
                )
              else if (pCon.current.value != null)
                Positioned(
                  right: widget.listGpsButtonRightPos ?? 10,
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
    final con = ControllerManager.read<AllFileStateController>();

    return [
      if (Platform.isLinux)
        IconButton(
          tooltip: 'Rescan Library',
          onPressed: () => init(usedCache: false),
          icon: const Icon(Icons.refresh_rounded),
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
    final con = ControllerManager.read<AllFileStateController>();
    final state = con.state;
    final colors = Theme.of(context).colorScheme;

    if (state.isLoading && con.files.isEmpty) {
      return Center(child: TLoaderRandom());
    }

    if (state.errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.error.withValues(alpha: .25)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.errorMessage,
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (con.files.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.music_off_rounded,
                size: 42,
                color: colors.onSurfaceVariant,
              ),

              const SizedBox(height: 12),

              Text(
                'No Audio Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Your audio library is empty.',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 16),

              RefreshButton(text: const Text('Scan Again'), onClicked: init),
            ],
          ),
        ),
      );
    }

    final pCon = ControllerManager.read<PlayerStateController>();

    return RefreshIndicator.adaptive(
      onRefresh: () => init(usedCache: false),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          if (state.isLoading && con.files.isNotEmpty)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),

          SliverToBoxAdapter(child: AudioListHeader()),

          AudioSliverList(list: con.files, onClicked: openConfrmAndPlay),

          SliverToBoxAdapter(
            child: SizedBox(height: pCon.showFloatWidget.value ? 130 : 90),
          ),
        ],
      ),
    );
  }

  void goListGps() {
    try {
      final con = ControllerManager.read<PlayerStateController>();
      final current = con.current.value;
      if (current == null) return;
      final allCon = ControllerManager.read<AllFileStateController>();
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

  void openConfrmAndPlay(AudioFile file) async {
    final pCon = ControllerManager.read<PlayerStateController>();
    final current = pCon.current.value;
    if (current != null && current.id == file.id && pCon.state.playing) {
      showTConfirmDialog(
        context,
        contentText: 'Want To Restart!',
        submitText: 'Restart',
        cancelText: 'No!',
        onSubmit: () async {
          await pCon.setTracks(
            ControllerManager.read<AllFileStateController>().files,
            source: .allFileState,
          );
          // print('item: $file');
          pCon.open(file);
        },
      );
      return;
    }
    await pCon.setTracks(
      ControllerManager.read<AllFileStateController>().files,
      source: .allFileState,
    );
    // print('item: $file');
    pCon.open(file);
  }
}
