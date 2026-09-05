import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/ui_config/config/ui_content_blur_config.dart';

class UiContentBlurConfigWiget extends StatefulWidget {
  const UiContentBlurConfigWiget({super.key});

  @override
  State<UiContentBlurConfigWiget> createState() =>
      _UiContentBlurConfigWigetState();
}

class _UiContentBlurConfigWigetState extends State<UiContentBlurConfigWiget> {
  final con = ControllerManager.read<PlayerStateController>();
  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: con.config.stream.put.where((e) => e.key == audioContentBlurKey),
      builder: (context, asyncSnapshot) {
        final contentBur = UiContentBlurConfig.fromMap(
          con.config.getMap(audioContentBlurKey),
        );
        return SwitchListTile.adaptive(
          tileColor: col.surfaceContainerHighest.withValues(alpha: .45),
          shape: RoundedRectangleBorder(
            borderRadius: .circular(15),
            side: BorderSide(
              color: col.onSurfaceVariant.withValues(alpha: .45),
            ),
          ),
          title: Text(
            'Background Blur',
            style: TextStyle(color: col.onSurface, fontWeight: .w600),
          ),
          subtitle: Text(
            'Content Background Blur',
            style: TextStyle(color: col.onSurfaceVariant, fontSize: 13),
          ),
          value: contentBur.enable,
          onChanged: (value) {
            con.config.putAndWriteAll(
              audioContentBlurKey,
              contentBur.copyWith(enable: value).toMap(),
            );
          },
        );
      },
    );
  }
}
