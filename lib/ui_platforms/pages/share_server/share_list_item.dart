import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/models/audio_file.dart';

class ShareListItem extends StatelessWidget {
  const ShareListItem({
    super.key,
    required this.file,
    required this.host,
    required this.onClicked,
  });
  final AudioFile file;
  final String host;
  final void Function(AudioFile file) onClicked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onClicked(file),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: audioSliverListItemHeight,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .25),
              ),
            ),
            child: Row(
              spacing: 8,
              children: [
                _cover(context),

                Expanded(child: _contentText(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cover(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 68,
        height: 68,
        child: Image.network(
          'http://$host/api/thumbnail/${file.id}',
          fit: .cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentText(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          file.autoTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            _infoText(context, file.meta.formatLabel),

            _dot(context),

            _infoText(context, file.meta.bitrateLabel),

            _dot(context),

            Flexible(child: _infoText(context, file.meta.sampleRateLabel)),
          ],
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 13,
              color: colors.onSurfaceVariant,
            ),

            const SizedBox(width: 3),

            Text(
              file.meta.duration.formatClockLabel(),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),

            const SizedBox(width: 7),
          ],
        ),
      ],
    );
  }

  Widget _infoText(BuildContext context, String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _dot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 9,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
