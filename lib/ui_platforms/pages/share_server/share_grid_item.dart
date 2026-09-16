import 'package:flutter/material.dart';
import 'package:than_sound/core/models/audio_file.dart';

class ShareGridItem extends StatelessWidget {
  const ShareGridItem({
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
    final col = Theme.of(context).colorScheme;
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: .circular(15),
      onTap: () {
        onClicked(file);
      },
      child: Container(
        padding: .all(8),
        decoration: BoxDecoration(borderRadius: .circular(15)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: .circular(5),
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
                ),
                SizedBox(height: 10),
                _content(col),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(ColorScheme col) {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Text(
          file.name,
          maxLines: 2,
          overflow: .ellipsis,
          style: TextStyle(color: col.onSurface),
        ),
      ],
    );
  }
}
