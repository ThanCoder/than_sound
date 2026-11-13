import 'package:material_ui/material_ui.dart';
import 'package:than_sound/platforms/components/reactive_cover/audio_reactive_cover_type_chooser.dart';
import 'package:than_sound/platforms/components/waveform/waveform_widget/wave_form_chooser.dart';
import 'package:than_sound/platforms/ui_config/widget/ui_content_blur_config_wiget.dart';

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

            UiContentBlurConfigWiget(),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
