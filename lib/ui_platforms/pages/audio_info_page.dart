import 'package:flutter/material.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioInfoPage extends StatelessWidget {
  const AudioInfoPage({super.key, required this.file});
  final AudioFile file;

  @override
  Widget build(BuildContext context) {
    // final col = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Info: ${file.autoTitle}')),
      body: SingleChildScrollView(child: Column(children: [])),
    );
  }
}
