import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/current_music_visualizer_widget.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_button.dart';
import 'package:than_sound/ui_platforms/ui/audio/thumbnail.dart';

class DesktopAudioSliverList extends StatelessWidget {
  const DesktopAudioSliverList({
    super.key,
    required this.files,
    required this.onTap,
    required this.onSecondaryTap,
    required this.currentNotifier,
  });

  final List<AudioFile> files;
  final ValueChanged<AudioFile> onTap;
  final ValueChanged<AudioFile> onSecondaryTap;
  final ValueNotifier<AudioFile?> currentNotifier;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];

        return _DesktopAudioRow(
          file: file,
          currentNotifier: currentNotifier,
          onTap: () => onTap(file),
          onSecondaryTap: () => onSecondaryTap(file),
        );
      },
    );
  }
}

class _DesktopAudioRow extends StatefulWidget {
  const _DesktopAudioRow({
    required this.file,
    required this.onTap,
    required this.onSecondaryTap,
    required this.currentNotifier,
  });

  final AudioFile file;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final ValueNotifier<AudioFile?> currentNotifier;

  @override
  State<_DesktopAudioRow> createState() => _DesktopAudioRowState();
}

class _DesktopAudioRowState extends State<_DesktopAudioRow> {
  bool hovering = false;



  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onSecondaryTap,
        child: ValueListenableBuilder(
          valueListenable: widget.currentNotifier,
          builder: (context, current, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: audioSliverListDesktopItemHeight,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: _colorDecoration(current),
              child: Row(
                children: [
                  _art(),
                  const SizedBox(width: 8),
                  if (current != null && current.id == widget.file.id)
                    CurrentMusicVisualizerWidget(),

                  const SizedBox(width: 12),

                  Expanded(flex: 4, child: _title()),

                  Expanded(flex: 3, child: _artistAlbum()),

                  SizedBox(
                    width: 80,
                    child: Text(
                      widget.file.meta.duration.formatClockLabel(),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(
                    width: 55,
                    child: Text(
                      widget.file.meta.format,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // visual

                  // fav
                  FavouriteButton(file: widget.file),
                  const SizedBox(width: 8),

                  _moreButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _colorDecoration(AudioFile? current) {
    final col = context.colorScheme;
    var currentCol = hovering
        ? col.surfaceContainerHighest
        : col.surfaceContainerHighest.withValues(alpha: .45);
    if (current != null && current.id == widget.file.id) {
      currentCol = col.primaryContainer;
    }
    return BoxDecoration(
      color: currentCol,
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget _art() {
    return SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Thumbnail(file: widget.file),
      ),
    );
  }

  Widget _title() {
    return Text(
      widget.file.autoTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  Widget _artistAlbum() {
    return Text(
      '${widget.file.meta.artist} ${widget.file.meta.album.isNotEmpty ? '/' : ''} ${widget.file.meta.album}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
      ),
    );
  }

  Widget _moreButton() {
    return IconButton(
      onPressed: widget.onSecondaryTap,
      icon: const Icon(Icons.more_vert),
      tooltip: 'More',
    );
  }
}
