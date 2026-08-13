import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/mobile/components/waveform/wave_form_chooser.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class WaveformSwitcher extends StatelessWidget {
  final Widget Function(WaveformDrawStyle style) switcher;
  const WaveformSwitcher({super.key, required this.switcher});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CFBStore.getInstance.events.where(
        (e) => e is PutValue && e.key == audioContentWaveFormTypeKey,
      ),
      builder: (context, _) {
        return switcher(WaveFormChooser.getCurrentValue());
      },
    );
  }
}
