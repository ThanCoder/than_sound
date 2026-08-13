import 'package:t_widgets/t_widgets.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/mobile/components/reactive_cover/audio_reactive_cover_type_chooser.dart';
import 'package:than_sound/ui_platforms/mobile/components/waveform/wave_form_chooser.dart';

class AudioContentThemeMenu extends StatelessWidget {
  const AudioContentThemeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TScrollableColumn(
      children: [
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: .35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Rective Cover
        AudioReactiveCoverTypeChooser(),
        //WaveForm Chooser
        WaveFormChooser(),
        SizedBox(height: 40),
      ],
    );
  }
}
