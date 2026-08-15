import 'package:flutter/material.dart';
import 'package:than_sound/core/models/audio_file.dart';

class DesktopListItem extends StatelessWidget {
  final AudioFile file;
  final void Function(AudioFile file) onClicked;
  final void Function(AudioFile file)? onMenuClicked;

  const DesktopListItem({
    super.key,
    required this.file,
    required this.onClicked,
    this.onMenuClicked,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
