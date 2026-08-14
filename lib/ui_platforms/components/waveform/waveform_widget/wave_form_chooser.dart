import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';

enum WaveFormType {
  none,
  bars,
  circular,
  filled,
  line;

  static WaveFormType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => bars);
  }
}

class WaveFormChooser extends StatelessWidget {
  WaveFormChooser({super.key});

  static WaveFormType get current {
    return WaveFormType.fromValue(
      CFBStore.getInstance.getString(audioContentWaveFormTypeKey),
    );
  }

  final store = CFBStore.getInstance;

  final list = WaveFormType.values
      .map(
        (e) => DropdownMenuItem<WaveFormType>(
          value: e,
          child: Text(e.name.capitalize),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  'Choose how the wave reacts to audio',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: StreamBuilder(
              stream: store.events.where(
                (e) => e is PutValue && e.key == audioContentWaveFormTypeKey,
              ),
              builder: (context, asyncSnapshot) {
                return DropdownButton<WaveFormType>(
                  borderRadius: .circular(14),
                  value: current,
                  items: list,
                  onChanged: (value) {
                    store.putAndWriteAll(
                      audioContentWaveFormTypeKey,
                      value!.name,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
