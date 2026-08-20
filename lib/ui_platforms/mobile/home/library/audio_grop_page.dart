import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_item_menu.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_list_item.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/lib_page.dart';
import 'package:than_sound/ui_platforms/player_theme_provider/player_content_theme_provider_screen.dart';

class AudioGropPage extends StatefulWidget {
  const AudioGropPage({super.key, required this.group});

  final AudioGroup group;

  @override
  State<AudioGropPage> createState() => _AudioGropPageState();
}

class _AudioGropPageState extends State<AudioGropPage> {
  ColorScheme get col => context.colorScheme;

  AudioGroup get group => widget.group;
  final pCon = ControllerManager.read<PlayerStateController>();

  void openConfrmAndPlay(AudioFile file) async {
    final files = widget.group.files;

    final current = pCon.current.value;
    if (current != null && current.id == file.id && pCon.state.playing) {
      context.pushMaterialPageRoute(
        builder: (mainCtx) => PlayerContentThemeProviderScreen(),
      );
      // final confirmed = await showConfirmDialog(
      //   context,
      //   'Want to Song Restart!',
      // );
      // if (confirmed) {
      //   await pCon.setTracks(files, source: .libState);
      //   pCon.open(file);
      // }
      return;
    }
    await pCon.setTracks(files, source: .libState);
    // print('item: $file');
    pCon.open(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(
        backgroundColor: col.surfaceContainer,
        foregroundColor: col.onSurfaceVariant,
        title: Text(group.name),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),

          SliverList.builder(
            itemCount: group.files.length,
            itemBuilder: (context, index) {
              final file = group.files[index];

              return _songItem(file);
            },
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AudioThumbnail(file: group.cover),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            group.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 4),

          Text(
            '${group.count} songs',
            style: TextStyle(color: col.onSurfaceVariant, fontSize: 13),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  openConfrmAndPlay(widget.group.files[0]);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play'),
              ),

              const SizedBox(width: 8),

              StreamBuilder(
                stream: pCon.audioHandler.shuffleStream,
                builder: (context, asyncSnapshot) {
                  final enable = pCon.audioHandler.isShuffle;
                  return OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: enable
                          ? col.primaryContainer
                          : col.surfaceContainer,
                      foregroundColor: enable
                          ? col.onPrimaryContainer
                          : col.onSurfaceVariant,
                    ),
                    onPressed: () {
                      pCon.audioHandler.toggleShuffle();
                    },
                    icon: Icon(Icons.shuffle_rounded),
                    label: const Text('Shuffle'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _songItem(AudioFile file) {
    return AudioListItem(
      file: file,
      onClicked: (file) {
        openConfrmAndPlay(file);
      },
      onMenuClicked: (file) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              AudioItemMenu(file: file, showDeleteAction: true),
        );
      },
    );
    // return ListTile(
    //   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    //   leading: SizedBox(
    //     width: 48,
    //     height: 48,
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(8),
    //       child: AudioThumbnail(file: file),
    //     ),
    //   ),
    //   title: Text(file.autoTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    //   subtitle: Text(
    //     file.meta.artist.isNotEmpty ? file.meta.artist : 'Unknown Artist',
    //     maxLines: 1,
    //     overflow: TextOverflow.ellipsis,
    //   ),
    //   trailing: const Icon(Icons.more_vert_rounded),
    //   onTap: () {
    //     openConfrmAndPlay(file);
    //   },
    // );
  }
}
