// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/configs/bass_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class AudioBassEqPage extends StatefulWidget {
  const AudioBassEqPage({super.key});

  @override
  State<AudioBassEqPage> createState() => _AudioBassEqPageState();
}

// 60–80 Hz → deep/sub-bass ပိုခံစားရ
// 100 Hz → ⭐ general music အတွက် balance ကောင်း
// 120–150 Hz → bass ပိုထူလာမယ်
// 180–200 Hz → low-mid ပါဝင်လာပြီး အသံ muddy ဖြစ်နိုင်

// ဒါကြောင့် default = 100 Hz လို့ထားတာ အကောင်းဆုံး။
class _AudioBassEqPageState extends State<AudioBassEqPage> {
  ColorScheme get col => Theme.of(context).colorScheme;
  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(title: Text('Bass Boost')),
      body: StreamBuilder(
        stream: con.config.stream.put.where((e) => e.key == audioBassConfigKey),
        builder: (context, snapshot) {
          final cf = BassConfig.fromMap(con.config.getMap(audioBassConfigKey));
          final enabled = cf.enable;
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
                  con.config
                      .put(
                        audioBassConfigKey,
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

  Container _bassWidget(BassConfig bass) {
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
                '${bass.gain >= 0 ? '+' : ''}'
                '${bass.gain.toStringAsFixed(1)} dB',
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
                    audioBassConfigKey,
                    bass.copyWith(gain: 6).toMap(),
                  );
                },
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Slider(
            min: -20,
            max: 20,
            value: bass.gain.clamp(-20, 20),
            onChanged: (value) {
              con.config.putAndWriteAll(
                audioBassConfigKey,
                bass.copyWith(gain: value).toMap(),
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

  Container _frequencyWidget(BassConfig bass) {
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
                '${bass.frequency.toInt()} Hz',
                style: TextStyle(color: col.primary, fontWeight: .w600),
              ),
              IconButton(
                onPressed: () {
                  con.config.putAndWriteAll(
                    audioBassConfigKey,
                    bass.copyWith(frequency: 100).toMap(),
                  );
                },
                icon: Icon(Icons.restart_alt_outlined),
              ),
            ],
          ),
          Slider(
            min: 40,
            max: 200,
            value: bass.frequency,
            onChanged: (value) {
              con.config.putAndWriteAll(
                audioBassConfigKey,
                bass.copyWith(frequency: value).toMap(),
              );
            },
          ),
          Row(children: [Text('20Hz'), Spacer(), Text('200 Hz')]),
        ],
      ),
    );
  }
}
