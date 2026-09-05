import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioThumbnail extends StatelessWidget {
  const AudioThumbnail({super.key, required this.file, this.borderRadius});
  final AudioFile file;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? .circular(4),
      child: imageWidget,
    );
  }

  Widget get imageWidget {
    final f = File(file.cacheCoverPath);
    if (f.existsSync()) {
      return Image.file(f, fit: .cover, gaplessPlayback: true);
    }
    return FutureBuilder(
      future: TagPictureWorker.instance.getImageBytes(file.path),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data != null && data.isOk) {
          if (!f.existsSync()) {
            f.writeAsBytes(data.unwrap());
          }
          return Image.memory(
            data.unwrap(),
            fit: .cover,
            gaplessPlayback: true,
          );
        }
        return SvgPicture.asset('assets/svg/music-notes-svgrepo-com(2).svg');
      },
    );
  }
}
