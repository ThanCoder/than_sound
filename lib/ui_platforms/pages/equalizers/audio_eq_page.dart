import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';

class AudioEqPage extends StatefulWidget {
  const AudioEqPage({super.key});

  @override
  State<AudioEqPage> createState() => _AudioEqPageState();
}

class _AudioEqPageState extends State<AudioEqPage> {
  ColorScheme get col => Theme.of(context).colorScheme;

  final frequencies = const [
    '31 Hz',
    '60 Hz',
    '120 Hz',
    '250 Hz',
    '500 Hz',
    '1 kHz',
    '2 kHz',
    '4 kHz',
    '8 kHz',
    '16 kHz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(
        title: const Text('Audio Equalizer'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enable EQ
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              title: const Text('Equalizer'),
              subtitle: const Text('Enable audio equalizer'),
              value: true,
              onChanged: (value) {},
            ),
          ),

          const SizedBox(height: 16),

          // EQ
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  for (final frequency in frequencies)
                    _EqualizerSlider(
                      frequency: frequency,
                      value: 0,
                      onChanged: (value) {
                        // print('frequency: $frequency - val: $value');
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerSlider extends StatelessWidget {
  const _EqualizerSlider({
    required this.frequency,
    required this.value,
    required this.onChanged,
  });

  final String frequency;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              frequency,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            child: CSlider(
              min: -12,
              max: 12,
              value: value,
              onChanged: onChanged,
              onChangeEnd: onChanged,
            ),
          ),

          SizedBox(
            width: 48,
            child: Text(
              '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)} dB',
              textAlign: TextAlign.end,
              style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
