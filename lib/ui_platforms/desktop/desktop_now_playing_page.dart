import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/components/sound_volume_menu.dart';

class DesktopNowPlayingPage extends StatefulWidget {
  const DesktopNowPlayingPage({super.key});

  @override
  State<DesktopNowPlayingPage> createState() => _DesktopNowPlayingPageState();
}

class _DesktopNowPlayingPageState extends State<DesktopNowPlayingPage> {
  final pCon = ControllerManager.read<PlayerStateController>();
  ColorScheme get col => Theme.of(context).colorScheme;

  void showItemMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) =>
          AudioItemMenu(file: pCon.state.current!, showContentAnimation: true),
    );
  }

  void showVolumeMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SoundVolumeMenu(),
    );
  }

  void playSong(AudioFile file) async {
    // await pCon.actions.setCurrent(file);
    await pCon.actions.open(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      body: SafeArea(
        child: Stack(
          fit: .expand,
          children: [
            Row(
              children: [
                Expanded(flex: 5, child: _playerSection()),

                const SizedBox(width: 24),

                Expanded(flex: 7, child: _playlistSection()),
              ],
            ),
            Positioned(
              left: 10,
              top: 10,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: col.surfaceContainer,
                  foregroundColor: col.onSurface,
                ),
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.arrow_back_ios_new_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerSection() {
    return StreamBuilder(
      stream: pCon.stream.current,
      builder: (context, asyncSnapshot) {
        final current = pCon.state.current;
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cover
              if (current != null)
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 200, minHeight: 200),
                  child: AudioThumbnail(file: current),
                ),

              Spacer(),

              Text(
                current?.autoTitle ?? 'Nothing Playing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: col.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Spacer(),

              Text(
                current?.meta.artist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: col.onSurface, fontSize: 15),
              ),

              // const SizedBox(height: 28),
              Spacer(),

              _progress(),
              Spacer(),
              // const SizedBox(height: 20),
              _controls(),
            ],
          ),
        );
      },
    );
  }

  Widget _progress() {
    return StreamBuilder(
      stream: pCon.stream.position,
      builder: (context, asyncSnapshot) {
        return Column(
          children: [
            Slider(
              max: pCon.state.duration.inSeconds.toDouble(),
              value: pCon.state.position.inSeconds.toDouble(),
              onChanged: (value) {
                pCon.actions.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pCon.state.position.formatClockLabel(),
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  pCon.state.duration.formatClockLabel(),

                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _controls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 30,
          onPressed: pCon.actions.prev,
          icon: const Icon(Icons.skip_previous_rounded),
        ),

        const SizedBox(width: 20),

        FilledButton(
          onPressed: pCon.actions.playPause,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: StreamBuilder(
            stream: pCon.stream.playing,
            builder: (context, asyncSnapshot) {
              return Icon(
                pCon.state.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_outlined,
                size: 30,
              );
            },
          ),
        ),

        const SizedBox(width: 20),

        IconButton(
          iconSize: 30,
          onPressed: pCon.actions.next,
          icon: const Icon(Icons.skip_next_rounded),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: showVolumeMenu,
          icon: Icon(Icons.volume_up_outlined),
        ),
      ],
    );
  }

  Widget _playlistSection() {
    return CustomScrollView(
      slivers: [
        // header
        SliverPadding(
          padding: const EdgeInsets.only(top: 32, right: 32, bottom: 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Text(
                    'Now Playing',
                    style: TextStyle(
                      color: col.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: showItemMenu,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'PLAYLIST',
                style: TextStyle(
                  color: col.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),
            ]),
          ),
        ),
        _listWidget(),
      ],
    );
  }

  StreamBuilder<PlayerStateEvent> _listWidget() {
    return StreamBuilder(
      stream: pCon.stream.all.where(
        (e) => e is CurrentChanged || e is PlayOrderChanged,
      ),
      builder: (context, asyncSnapshot) {
        return SliverReorderableList(
          itemCount: pCon.state.playOrder.length,
          itemBuilder: (context, index) {
            final item = pCon.state.playOrder[index];
            return Row(
              key: ValueKey(item.id),
              children: [
                Expanded(child: _playlistItem(item, index)),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle),
                ),
                SizedBox(width: 10),
              ],
            );
          },
          onReorderItem: (oldIndex, newIndex) {
            final item = pCon.state.playOrder.removeAt(oldIndex);
            pCon.state.playOrder.insert(newIndex, item);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _playlistItem(AudioFile file, int index) {
    final current = pCon.state.current;
    final selected = current != null && current.id == file.id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => playSong(file),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .15)
                : col.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (selected)
                CurrentMusicVisualizerWidget()
              else
                SizedBox(
                  width: 30,
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : col.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (selected) SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: col.onSurface,
                ),
                child: AudioThumbnail(file: file),
                // const Icon(
                //   Icons.music_note_rounded,
                //   size: 18,
                //   color: Colors.white38,
                // ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  file.autoTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: col.onSurface, fontSize: 14),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '03:54',
                style: TextStyle(color: col.onSurface, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
