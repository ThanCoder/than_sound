// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/configs/treble_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';

class AudioTrebleEqPage extends StatefulWidget {
  const AudioTrebleEqPage({super.key});

  @override
  State<AudioTrebleEqPage> createState() => _AudioTrebleEqPageState();
}

class _AudioTrebleEqPageState extends State<AudioTrebleEqPage> {
  ColorScheme get col => Theme.of(context).colorScheme;
  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(title: Text('Treble Boost')),
      body: StreamBuilder(
        stream: con.config.stream.put.where(
          (e) => e.key == audioTrebleConfigKey,
        ),
        builder: (context, snapshot) {
          final cf = TrebleConfig.fromMap(
            con.config.getMap(audioTrebleConfigKey),
          );
          final enabled = cf.enable;
          return Column(
            spacing: 5,
            children: [
              SwitchListTile.adaptive(
                tileColor: col.surfaceContainer,
                shape: RoundedRectangleBorder(borderRadius: .circular(15)),
                title: Text(
                  'Treble Boost',
                  style: TextStyle(color: col.onSurface, fontWeight: .w600),
                ),
                subtitle: Text(
                  'Enhance high frequencies',
                  style: TextStyle(color: col.onSurfaceVariant),
                ),
                value: enabled,
                onChanged: (value) {
                  con.config
                      .put(
                        audioTrebleConfigKey,
                        cf.copyWith(enable: value).toMap(),
                      )
                      .writeAll();
                },
              ),
              if (enabled) _bassWidget(cf),
              if (enabled) _frequencyWidget(cf),
            ],
          );
        },
      ),
    );
  }

  Container _bassWidget(TrebleConfig treble) {
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
                '${treble.gain >= 0 ? '+' : ''}'
                '${treble.gain.toStringAsFixed(1)} dB',
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
                  con.config.putAndWriteAll(
                    audioTrebleConfigKey,
                    treble.copyWith(gain: 0).toMap(),
                  );
                },
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),

          const SizedBox(height: 4),

          CSlider(
            min: -12,
            max: 12,
            value: treble.gain,
            onChanged: (value) {
              con.config.putAndWriteAll(
                audioTrebleConfigKey,
                treble.copyWith(gain: value).toMap(),
              );
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

  Container _frequencyWidget(TrebleConfig treble) {
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
                  con.config.putAndWriteAll(
                    audioTrebleConfigKey,
                    treble.copyWith(frequency: 100).toMap(),
                  );
                },
                icon: Icon(Icons.restart_alt_outlined),
              ),
            ],
          ),
          CSlider(
            min: 1000,
            max: 12000,
            value: treble.frequency,
            onChanged: (value) {
              con.config.putAndWriteAll(
                audioTrebleConfigKey,
                treble.copyWith(gain: value).toMap(),
              );
            },
          ),
          Row(children: [Text('20Hz'), Spacer(), Text('200 Hz')]),
        ],
      ),
    );
  }
}
