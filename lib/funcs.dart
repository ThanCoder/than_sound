import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/desktop/desktop_now_playing_page.dart';

Future<void> openConfirmAndPlay(
  BuildContext context, {
  required AudioFile file,
  required List<AudioFile> sourceFiles,
  required AudioFileSource source,
  bool showConfirmBox = false,
}) async {
  final playstateController = ControllerManager.read<PlayerStateController>();
  final current = playstateController.state.current;

  if (showConfirmBox) {
    if (current != null &&
        current.id == file.id &&
        playstateController.state.playing) {
      final confirmed = await showConfirmDialog(
        context,
        'Want to Song Restart!',
      );
      if (confirmed) {
        await playstateController.actions.setTracks(
          sourceFiles,
          source: source,
        );
        await playstateController.actions.open(file);
      }

      return;
    }
  } else {
    if (current != null &&
        current.id == file.id &&
        playstateController.state.playing) {
      context.pushMaterialPageRoute(
        builder: (mainCtx) => DesktopNowPlayingPage(),
      );
      return;
    }
  }

  await playstateController.actions.setTracks(sourceFiles, source: source);
  await playstateController.actions.open(file);
}
