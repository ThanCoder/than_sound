// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:mpv_audio_kit/src/generated/audio_effects_settings.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';

class AudioBassEqPage extends StatefulWidget {
  const AudioBassEqPage({super.key});

  @override
  State<AudioBassEqPage> createState() => _AudioBassEqPageState();
}

class _AudioBassEqPageState extends State<AudioBassEqPage> {
  ColorScheme get col => Theme.of(context).colorScheme;
  final py =
      ControllerManager.read<PlayerStateController>().audioHandler.player;

  double gain = 6;
  double frequency = 100;
  bool enable = false;

  void updateBass() {
    py.updateAudioEffects(
      (e) => e.copyWith(
        bass: BassSettings(enabled: enable, g: gain, f: frequency),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(title: Text('Bass Boost')),
      body: StreamBuilder(
        stream: py.stream.audioEffects.map((e) => e.bass),
        builder: (context, snapshot) {
          final bass = snapshot.data ?? py.state.audioEffects.bass;
          final enabled = bass?.enabled ?? false;

          return Column(
            spacing: 5,
            children: [
              SwitchListTile.adaptive(
                tileColor: col.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: .circular(15)),
                title: Text(
                  'Base Boost',
                  style: TextStyle(color: col.onSurface, fontWeight: .w600),
                ),
                subtitle: Text(
                  'Enhance low frequencies',
                  style: TextStyle(color: col.onSurfaceVariant),
                ),
                value: enabled,
                onChanged: (value) {
                  setState(() {
                    enable = value;
                  });
                  updateBass();
                },
              ),
              if (enabled) _bassWidget(bass),
              if (enabled) _frequencyWidget(bass),
            ],
          );
        },
      ),
    );
  }

  Container _frequencyWidget(BassSettings? bass) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Frequency',
                style: TextStyle(fontWeight: .w600, color: col.onSurface),
              ),
              Spacer(),
              Text(
                '100 Hz',
                style: TextStyle(color: col.primary, fontWeight: .w600),
              ),
              IconButton(
                onPressed: () {
                  frequency = 100;
                  updateBass();
                },
                icon: Icon(Icons.restart_alt_outlined),
              ),
            ],
          ),
          CSlider(
            min: 20,
            max: 200,
            value: bass!.frequency,
            onChanged: (value) {
              frequency = value;
              updateBass();
            },
          ),
          Row(children: [Text('20Hz'), Spacer(), Text('200 Hz')]),
        ],
      ),
    );
  }

  Container _bassWidget(BassSettings? bass) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Gain',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: col.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${bass!.g >= 0 ? '+' : ''}'
                '${bass.g.toStringAsFixed(1)} dB',
                style: TextStyle(
                  color: col.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Reset',
                onPressed: () {
                  gain = 6;
                  updateBass();
                },
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),

          const SizedBox(height: 4),

          CSlider(
            min: -20,
            max: 20,
            value: bass.g,
            onChanged: (value) {
              gain = value;
              updateBass();
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  '-20 dB',
                  style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '0 dB',
                  style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '+20 dB',
                  style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
