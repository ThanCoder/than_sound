import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioThumbnail extends StatelessWidget {
  final AudioFile file;
  const AudioThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: .circular(4), child: imageWidget);
  }

  Widget get imageWidget {
    final f = File(file.cacheCoverPath);
    if (!f.existsSync()) {
      // return Icon(Icons.music_note, size: 50);
      return SvgPicture.asset('assets/svg/music-notes-svgrepo-com.svg');
    }
    return Image.file(
      f,
      fit: .cover,
      errorBuilder: (context, error, stackTrace) {
        return SvgPicture.asset('assets/svg/music-notes-svgrepo-com.svg');
      },
    );
  }
}
