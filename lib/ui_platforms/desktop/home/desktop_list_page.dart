import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' show ContextExt;
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_audio_item_menu.dart';
import 'package:than_sound/ui_platforms/components/dialog/error_alert_dialog.dart';
import 'package:than_sound/ui_platforms/desktop/components/desktop_audio_sliver_list.dart';
import 'package:than_sound/ui_platforms/ui/partials/sort_provider.dart';

class DesktopListPage extends StatefulWidget {
  const DesktopListPage({super.key});

  @override
  State<DesktopListPage> createState() => _DesktopListPageState();
}

class _DesktopListPageState extends State<DesktopListPage> {
  final allC = ControllerManager.read<AllFileStateController>();
  final plC = ControllerManager.read<PlayerStateController>();

  Future<void> init({bool usedCache = true}) async {
    allC.scanFromStorage(usedCache: usedCache);
  }

  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Than Audio'),
        actions: actions,
        backgroundColor: col.surfaceContainer,
        foregroundColor: col.onSurfaceVariant,
      ),
      backgroundColor: col.surface,
      body: Stack(children: [_body(), _gpsButton()]),
    );
  }

  Positioned _gpsButton() {
    return Positioned(
      right: 10,
      bottom: 10,
      child: FloatingActionButton.small(
        onPressed: _jumpGpsList,
        child: Icon(Icons.gps_fixed_outlined),
      ),
    );
  }

  CustomScrollView _body() {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        StreamBuilder(
          stream: allC.stream,
          builder: (context, asyncSnapshot) {
            return SliverToBoxAdapter(
              child: !allC.state.isLoading ? null : LinearProgressIndicator(),
            );
          },
        ),
        // header
        StreamBuilder(
          stream: allC.stream,
          builder: (context, asyncSnapshot) {
            return DesktopAudioSliverList(
              files: allC.files,
              currentNotifier: plC.current,
              onTap: onTap,
              onSecondaryTap: onSecondaryTap,
            );
          },
        ),
      ],
    );
  }

  List<Widget> get actions {
    final col = context.colorScheme;
    return [
      IconButton(
        color: col.primaryContainer,
        onPressed: () => init(usedCache: false),
        icon: Icon(Icons.refresh, color: col.onPrimaryContainer),
      ),
      SortButton(
        value: allC.state.currentSort,
        list: allC.sortList,
        onApply: (item) {
          allC.setSort(item);
        },
      ),
    ];
  }

  double get height => MediaQuery.of(context).size.height;

  void _jumpGpsList() {
    try {
      final current = plC.current.value;
      if (current == null) return;
      if (!scrollController.hasClients) return;
      final index = allC.files.indexWhere((e) => e.id == current.id);
      if (index == -1) return;
      final offset = (index * audioSliverListDesktopItemHeight);
      // jump
      scrollController.animateTo(
        offset.clamp(0, scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  void onTap(AudioFile file) async {
    await plC.setTracks(allC.files, source: .allFileState);
    if (plC.isCurrentFile(file)) {
      await plC.play();
    } else {
      await plC.open(file);
    }
    if (!plC.showFloatWidget.value) {
      plC.showFloatWidget.value = true;
    }
  }

  void onSecondaryTap(AudioFile file) {
    showDialog(
      context: context,
      builder: (context) => DesktopAudioItemMenu(file: file),
    );
  }
}
