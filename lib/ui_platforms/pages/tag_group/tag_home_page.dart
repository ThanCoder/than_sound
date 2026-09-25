import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/extensions/audio_file_extensions.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/pages/tag_group/audio_group_page.dart';
import 'package:than_sound/ui_platforms/pages/tag_group/lib_tag_type.dart';

class TagHomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<TagHomePage> createState() => _TagHomePageState();
}

class _TagHomePageState extends State<TagHomePage> {
  final con = ControllerManager.read<AllFileStateController>();
  final currentTag = ValueNotifier<LibTagType>(LibTagType.artist);

  List<AudioGroup> _groups(LibTagType type) {
    final groups = <String, List<AudioFile>>{};

    for (final file in con.files) {
      final key = switch (type) {
        LibTagType.artist => file.meta.artist,
        LibTagType.album => file.meta.album,
        LibTagType.genre => file.meta.genre,
        LibTagType.year => file.yearLabel,
      };

      if (key.isEmpty || key == '0') continue;

      groups.putIfAbsent(key, () => []).add(file);
    }

    return groups.entries
        .map((e) => AudioGroup(name: e.key, files: e.value))
        .toList();
  }

  final tags = LibTagType.values;
  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            pinned: true,
            flexibleSpace: SingleChildScrollView(
              scrollDirection: .horizontal,
              child: Padding(
                padding: .symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  spacing: 8,
                  children: tags.map((e) => _tagItem(e)).toList(),
                ),
              ),
            ),
          ),

          // list
          SliverPadding(
            padding: .symmetric(vertical: 5, horizontal: 5),
            sliver: _list,
          ),
        ],
      ),
    );
  }

  Widget _tagItem(LibTagType tag) {
    return ValueListenableBuilder(
      valueListenable: currentTag,
      builder: (context, current, child) {
        return GestureDetector(
          onTap: () {
            currentTag.value = tag;
          },
          child: Container(
            padding: .symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
              color: col.tertiaryContainer,
              borderRadius: .circular(15),
              boxShadow: current != tag
                  ? null
                  : [
                      .new(
                        blurRadius: 5,
                        color: col.onTertiaryContainer,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Row(
              children: [
                tag.icon,
                Text(
                  tag.label,
                  style: TextStyle(
                    color: col.onTertiaryContainer,
                    fontWeight: .w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get _list {
    return ValueListenableBuilder(
      valueListenable: currentTag,
      builder: (context, tag, child) {
        final groups = _groups(tag);
        return SliverGrid.builder(
          itemCount: groups.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 200,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final item = groups[index];

            return gridItem(item);
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
