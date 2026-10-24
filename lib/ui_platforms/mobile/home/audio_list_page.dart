import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/funcs.dart';
import 'package:than_sound/ui_platforms/components/audio_list_header.dart';
import 'package:than_sound/ui_platforms/components/audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/components/list_gps_button.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/pages/partials/sort_provider.dart';

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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final playstateController = ControllerManager.read<PlayerStateController>();
  final con = ControllerManager.read<AllFileStateController>();
  final pCon = ControllerManager.read<PlayerStateController>();
  ColorScheme get colors => Theme.of(context).colorScheme;

  Future<void> init({bool usedCache = true}) async {
    try {
      if (Platform.isAndroid) {
        final pkg = ThanPkgAndroid.getInstance.storagePermissionHandler;
        if (!await pkg.isStoragePermissionGranted()) {
          await pkg.requestStoragePermission();

          return;
        }
      }
      await con.scanFromStorage(usedCache: usedCache);
      if (!mounted) return;

      await playstateController.actions.setTracks(
        con.files,
        source: const AllFileStateSource(),
      );
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void goListGps() {
    try {
      final current = playstateController.state.current;
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

  void _openConfrmAndPlay(AudioFile file) async {
    await openConfirmAndPlay(
      context,
      file: file,
      sourceFiles: ControllerManager.read<AllFileStateController>().files,
      source: const AllFileStateSource(),
      showConfirmBox: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: con.stream,
      builder: (context, asyncSnapshot) {
        return Scaffold(
          backgroundColor: context.colorScheme.surface,
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
              else if (pCon.state.current != null)
                Positioned(
                  right: widget.listGpsButtonRightPos ?? 10,
                  bottom: pCon.state.showFloatWidget ? 70 : 30,
                  child: ListGpsButton(onClicked: goListGps),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> get _actions {
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
    final state = con.state;

    final pCon = ControllerManager.read<PlayerStateController>();

    return RefreshIndicator.adaptive(
      onRefresh: () => init(usedCache: false),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        slivers: [
          _appbar,
          if (state.isLoading && con.files.isEmpty)
            SliverFillRemaining(child: Center(child: TLoaderRandom())),

          if (state.isLoading && con.files.isNotEmpty)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),
          // header
          if (state.errorMessage.isEmpty && con.files.isNotEmpty)
            SliverToBoxAdapter(child: AudioListHeader()),

          if (state.errorMessage.isNotEmpty)
            SliverFillRemaining(child: _errorWidget),

          if (state.errorMessage.isEmpty && con.files.isEmpty)
            SliverFillRemaining(child: _listEmptyWidget),

          if (state.errorMessage.isEmpty)
            AudioSliverList(list: con.files, onClicked: _openConfrmAndPlay),

          if (state.errorMessage.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: pCon.state.showFloatWidget ? 130 : 90),
            ),
        ],
      ),
    );
  }

  Widget get _appbar {
    return SliverAppBar(
      snap: true,
      floating: true,
      pinned: false,
      backgroundColor: context.colorScheme.surfaceContainer,
      title: const Text(
        'ThanSound',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: _actions,
    );
  }

  Widget get _errorWidget {
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
                con.state.errorMessage,
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

  Widget get _listEmptyWidget {
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
}
