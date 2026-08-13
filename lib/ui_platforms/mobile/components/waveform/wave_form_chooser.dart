import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:waveform_visualizer/waveform_visualizer.dart';

class WaveFormChooser extends StatelessWidget {
  WaveFormChooser({super.key});

  static WaveformDrawStyle getCurrentValue() {
    WaveformDrawStyle value = .bars;
    final name = CFBStore.getInstance.getString(audioContentWaveFormTypeKey);

    if (name == WaveformDrawStyle.circular.name) {
      value = .circular;
    } else if (name == WaveformDrawStyle.filled.name) {
      value = .filled;
    } else if (name == WaveformDrawStyle.line.name) {
      value = .line;
    }
    return value;
  }

  final store = CFBStore.getInstance;

  final list = WaveformDrawStyle.values
      .map(
        (e) => DropdownMenuItem<WaveformDrawStyle>(
          value: e,
          child: Text(e.name.capitalize),
        ),
      )
      .toList();

  final current = WaveFormChooser.getCurrentValue();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder(
      stream: store.events.where(
        (e) => e is PutValue && e.key == audioContentWaveFormTypeKey,
      ),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(15),
            border: .all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: .circular(12),
                ),
                child: Icon(
                  Icons.waves_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'WaveForm',
                      style: TextStyle(fontSize: 15, fontWeight: .w600),
                    ),
                    Text(
                      'Choose how the cover reacts to audio',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  borderRadius: .circular(14),
                  value: current,
                  items: list,
                  onChanged: (value) {
                    store.putAndWriteAll(
                      audioContentWaveFormTypeKey,
                      value!.name,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
