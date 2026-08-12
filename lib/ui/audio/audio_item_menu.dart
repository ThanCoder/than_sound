import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';

class AudioItemMenu extends StatefulWidget {
  final AudioFile file;
  const AudioItemMenu({super.key, required this.file});

  @override
  State<AudioItemMenu> createState() => _AudioItemMenuState();
}

class _AudioItemMenuState extends State<AudioItemMenu> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 130),
      child: TScrollableColumn(
        children: [
          ListTile(
            title: Text("Delete"),
            onTap: () {
              context.pop();
              deleteConfirm();
            },
          ),
        ],
      ),
    );
  }

  void deleteConfirm() {
    showTConfirmDialog(
      context,
      contentText: 'Are You Sure?\nသေချာပြီလား?\n${widget.file.autoTitle}',
      submitText: 'Delete Forever',
      onSubmit: () {
        ControllerManager.read<AllFileStateController>().deleteAudioFile(
          widget.file,
        );
      },
    );
  }
}
