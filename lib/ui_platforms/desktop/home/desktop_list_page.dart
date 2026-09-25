import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/funcs.dart';
import 'package:than_sound/ui_platforms/components/audio_list_header.dart';
import 'package:than_sound/ui_platforms/components/audio_sliver_list.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/pages/partials/sort_provider.dart';

class DesktopListPage extends StatefulWidget {
  const DesktopListPage({super.key});

  @override
  State<DesktopListPage> createState() => _DesktopListPageState();
}

class _DesktopListPageState extends State<DesktopListPage> {
  final controller = ScrollController();

  final playstateController = ControllerManager.read<PlayerStateController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> init({bool usedCache = true}) async {
    try {
      if (Platform.isAndroid) {
        final pkg = ThanPkgAndroid.getInstance.storagePermissionHandler;

        if (!await pkg.isStoragePermissionGranted()) {
          await pkg.requestStoragePermission();
          return;
        }
      }

      final con = ControllerManager.read<AllFileStateController>();

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

  Future<void> _openConfirmAndPlay(AudioFile file) async {
    await openConfirmAndPlay(
      context,
      file: file,
      sourceFiles: ControllerManager.read<AllFileStateController>().files,
      source: const AllFileStateSource(),
    );
  }

  void goCurrentTrack() {
    try {
      final current = playstateController.state.current;

      if (current == null) return;

      final con = ControllerManager.read<AllFileStateController>();

      final index = con.files.indexWhere((e) => e.id == current.id);

      if (index == -1) return;

      final offset =
          (audioSliverListItemHeight * index) -
          (MediaQuery.sizeOf(context).height * .3);

      controller.animateTo(
        offset.clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<AllFileStateController>();

    return StreamBuilder(
      stream: con.stream,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: context.colorScheme.surface,

          appBar: AppBar(
            title: const Text(
              'ThanSound',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: context.colorScheme.surfaceContainer,
            scrolledUnderElevation: 0,

            actions: [
              IconButton(
                tooltip: 'Rescan Library',
                onPressed: () => init(usedCache: false),
                icon: const Icon(Icons.refresh_rounded),
              ),

              SortButton(
                value: con.state.currentSort,
                list: con.sortList,
                onApply: con.setSort,
              ),

              const SizedBox(width: 8),
            ],
          ),

          body: bodyWidget,
        );
      },
    );
  }

  Widget get bodyWidget {
    final con = ControllerManager.read<AllFileStateController>();
    final state = con.state;
    final colors = context.colorScheme;

    if (state.isLoading && con.files.isEmpty) {
      return Center(child: TLoaderRandom());
    }

    if (state.errorMessage.isNotEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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
          constraints: const BoxConstraints(maxWidth: 420),
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

    return RefreshIndicator.adaptive(
      onRefresh: () => init(usedCache: false),
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state.isLoading)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: colors.surfaceContainerHighest,
              ),
            ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: const AudioListHeader(),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: AudioSliverList(
              list: con.files,
              onClicked: _openConfirmAndPlay,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
