import 'package:flutter/material.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioItemMenuDialog extends StatelessWidget {
  final AudioFile file;
  const AudioItemMenuDialog({super.key,required this.file});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(content: Placeholder(),);
  }
}
