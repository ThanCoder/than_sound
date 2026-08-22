import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioThumbnail extends StatelessWidget {
  final AudioFile file;
  const AudioThumbnail({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: .circular(4), child: imageWidget);
  }

  Widget get imageWidget {
    return FutureBuilder(
      future: TagPictureWorker.instance.getImageBytes(file.path),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == .waiting) {
        //   return Center(child: CircularProgressIndicator.adaptive());
        // }
        final data = snapshot.data;
        if (data != null && data.isOk) {
          return Image.memory(
            data.unwrap(),
            fit: .cover,
            gaplessPlayback: true,
          );
        }
        return SvgPicture.asset('assets/svg/music-notes-svgrepo-com(2).svg');
        // return Icon(Icons.image_not_supported_outlined, size: 50);
      },
    );
  }
}
