import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/audio_reactive_cover_type_chooser.dart';
import 'package:than_sound/ui_platforms/components/waveform/waveform_widget/wave_form_chooser.dart';

class AudioContentThemeMenu extends StatelessWidget {
  const AudioContentThemeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 5,
          children: [
            const SizedBox(height: 20),

            // Rective Cover
            AudioReactiveCoverTypeChooser(),
            //WaveForm Chooser
            WaveFormChooser(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
