import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_count_view.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/audio_group_page.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/lib_tag_type.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/tag_header.dart';

class AudioGroup {
  const AudioGroup({required this.name, required this.files});

  final String name;
  final List<AudioFile> files;

  int get count => files.length;

  AudioFile get cover => files.first;
}

class LibPage extends StatefulWidget {
  const LibPage({super.key});

  @override
  State<LibPage> createState() => _LibPageState();
}

class _LibPageState extends State<LibPage> {
  ColorScheme get col => context.colorScheme;

  final currentTag = ValueNotifier<LibTagType>(LibTagType.artist);

  final con = ControllerManager.read<AllFileStateController>();

  List<AudioGroup> _groups(LibTagType type) {
    final groups = <String, List<AudioFile>>{};

    for (final file in con.files) {
      final key = switch (type) {
        LibTagType.artist => file.meta.artist,
        LibTagType.album => file.meta.album,
        LibTagType.genre => file.meta.genre,
        LibTagType.year => file.meta.year.toString(),
      };

      if (key.isEmpty || key == '0') continue;

      groups.putIfAbsent(key, () => []).add(file);
    }

    return groups.entries
        .map((e) => AudioGroup(name: e.key, files: e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      // appBar: AppBar(
      //   backgroundColor: context.colorScheme.surfaceContainer,
      //   foregroundColor: context.colorScheme.onSurfaceVariant,
      //   title: Text("Library"),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.colorScheme.surfaceContainer,
              foregroundColor: context.colorScheme.onSurfaceVariant,
              title: Text("Library"),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverGrid.list(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisExtent: 50,
              ),
              children: [FavouriteCountView()],
            ),
            //
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: TagHeader(currentTag: currentTag),
              ),
            ),

            _tagList(),
          ],
        ),
      ),
    );
  }

  Widget _tagList() {
    return ValueListenableBuilder(
      valueListenable: currentTag,
      builder: (context, value, child) {
        final groups = _groups(value);
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 200,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];

            return gridItem(group);
          },
        );
      },
    );
  }

  Widget gridItem(AudioGroup group) {
    return GestureDetector(
      onTap: () {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => AudioGroupPage(group: group),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AudioThumbnail(file: group.cover),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${group.count} songs',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
