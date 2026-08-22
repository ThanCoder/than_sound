import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_sound/core/extensions/date_time_ext.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioInfoMenu extends StatelessWidget {
  final AudioFile file;

  const AudioInfoMenu({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final meta = file.meta;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Cover(path: file.cacheCoverPath, size: 82),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.autoTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (meta.artist.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          meta.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],

                      if (meta.album.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          meta.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Basic Info
            _SectionTitle(icon: Icons.music_note_rounded, title: 'Audio'),

            const SizedBox(height: 8),

            _InfoCard(
              children: [
                _InfoTile(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: meta.formatDuration,
                ),
                _InfoTile(
                  icon: Icons.high_quality_outlined,
                  label: 'Format',
                  value: meta.format.isNotEmpty
                      ? meta.format.toUpperCase()
                      : meta.formatLabel,
                ),
                _InfoTile(
                  icon: Icons.speed_outlined,
                  label: 'Bitrate',
                  value: meta.bitrate > 0 ? meta.bitrateLabel : 'Unknown',
                ),
                _InfoTile(
                  icon: Icons.graphic_eq_rounded,
                  label: 'Sample Rate',
                  value: meta.sampleRate > 0 ? meta.sampleRateLabel : 'Unknown',
                ),
                _InfoTile(
                  icon: Icons.speaker_group_outlined,
                  label: 'Channels',
                  value: _channelLabel(meta.channels),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Metadata
            _SectionTitle(
              icon: Icons.library_music_outlined,
              title: 'Metadata',
            ),

            const SizedBox(height: 8),

            _InfoCard(
              children: [
                if (meta.title.isNotEmpty)
                  _InfoTile(
                    icon: Icons.title_rounded,
                    label: 'Title',
                    value: meta.title,
                  ),
                if (meta.artist.isNotEmpty)
                  _InfoTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Artist',
                    value: meta.artist,
                  ),
                if (meta.album.isNotEmpty)
                  _InfoTile(
                    icon: Icons.album_outlined,
                    label: 'Album',
                    value: meta.album,
                  ),
                if (meta.genre.isNotEmpty)
                  _InfoTile(
                    icon: Icons.category_outlined,
                    label: 'Genre',
                    value: meta.genre,
                  ),
                if (meta.track > 0)
                  _InfoTile(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Track',
                    value: '${meta.track}',
                  ),
                if (meta.year > 0)
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year',
                    value:
                        '${meta.year.toString().parseYyyyMMdd()?.yyyyMMdd(sprator: '-')}',
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // File Info
            _SectionTitle(
              icon: Icons.insert_drive_file_outlined,
              title: 'File',
            ),

            const SizedBox(height: 8),

            _InfoCard(
              children: [
                _InfoTile(
                  icon: Icons.description_outlined,
                  label: 'Name',
                  value: file.name,
                ),
                _InfoTile(
                  icon: Icons.storage_outlined,
                  label: 'Size',
                  value: _formatBytes(file.size),
                ),
                _InfoTile(
                  icon: Icons.folder_outlined,
                  label: 'Directory',
                  value: file.dirname,
                ),
                _InfoTile(
                  icon: Icons.access_time_outlined,
                  label: 'Modified',
                  value: _formatDate(file.date),
                ),
                _InfoTile(
                  icon: Icons.fingerprint_rounded,
                  label: 'ID',
                  value: file.id,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Path
            _SectionTitle(icon: Icons.link_rounded, title: 'Path'),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: .45,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SelectableText(
                file.path,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            if (meta.comment.isNotEmpty) ...[
              const SizedBox(height: 20),

              _SectionTitle(icon: Icons.comment_outlined, title: 'Comment'),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: .45,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  meta.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static String _channelLabel(int channels) {
    switch (channels) {
      case 1:
        return 'Mono';
      case 2:
        return 'Stereo';
      default:
        return channels > 0 ? '$channels channels' : 'Unknown';
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];

    double size = bytes.toDouble();
    int index = 0;

    while (size >= 1024 && index < units.length - 1) {
      size /= 1024;
      index++;
    }

    if (index == 0) {
      return '${size.toInt()} ${units[index]}';
    }

    return '${size.toStringAsFixed(2)} ${units[index]}';
  }

  static String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${date.year}-'
        '${two(date.month)}-'
        '${two(date.day)} '
        '${two(date.hour)}:'
        '${two(date.minute)}';
  }
}

class _Cover extends StatelessWidget {
  final String path;
  final double size;

  const _Cover({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget child;

    if (path.isEmpty || !File(path).existsSync()) {
      child = Icon(
        Icons.music_note_rounded,
        size: size * .42,
        color: colorScheme.onSurfaceVariant,
      );
    } else {
      child = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Icon(
            Icons.music_note_rounded,
            size: size * .42,
            color: colorScheme.onSurfaceVariant,
          );
        },
      );
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 19, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 52,
                endIndent: 16,
                color: colorScheme.outlineVariant.withValues(alpha: .35),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),

          const SizedBox(width: 16),

          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
