import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/configs/loudess_config.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';

class LoudnessEqPage extends StatefulWidget {
  const LoudnessEqPage({super.key});

  @override
  State<LoudnessEqPage> createState() => _LoudnessEqPageState();
}

class _LoudnessEqPageState extends State<LoudnessEqPage> {
  ColorScheme get col => Theme.of(context).colorScheme;

  final con = ControllerManager.read<PlayerStateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(title: const Text('Loudness')),
      body: StreamBuilder(
        stream: con.config.stream.put.where((e) => e.key == loudnessConfigKey),
        builder: (context, snapshot) {
          final loudness = LoudessConfig.fromMap(
            con.config.getMap(loudnessConfigKey),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _enableWidget(loudness),
              if (loudness.enabled) ...[
                const SizedBox(height: 8),
                _targetLufsWidget(loudness),
                const SizedBox(height: 8),
                _gainRangeWidget(loudness),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _enableWidget(LoudessConfig loudness) {
    return Container(
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Loudness',
          style: TextStyle(color: col.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Normalize volume between tracks',
          style: TextStyle(color: col.onSurfaceVariant),
        ),
        value: loudness.enabled,
        onChanged: (value) {
          con.config.putAndWriteAll(
            loudnessConfigKey,
            loudness.copyWith(enabled: value).toMap(),
          );
        },
      ),
    );
  }

  Widget _targetLufsWidget(LoudessConfig loudness) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Target Loudness',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: col.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${loudness.targetLufs.toStringAsFixed(1)} LUFS',
                style: TextStyle(
                  color: col.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                tooltip: 'Reset',
                onPressed: () {
                  con.config.putAndWriteAll(
                    loudnessConfigKey,
                    loudness.copyWith(targetLufs: -18).toMap(),
                  );
                },
                icon: const Icon(Icons.restart_alt_outlined),
              ),
            ],
          ),
          Slider(
            min: -24,
            max: -8,
            value: loudness.targetLufs.clamp(-24, -8),
            onChanged: (value) {
              con.config.putAndWriteAll(
                loudnessConfigKey,
                loudness.copyWith(targetLufs: value).toMap(),
              );
            },
          ),
          Row(
            children: [
              Text(
                '-24 LUFS',
                style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '-18 LUFS',
                style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '-8 LUFS',
                style: TextStyle(color: col.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gainRangeWidget(LoudessConfig loudness) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Gain Range',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: col.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${loudness.minGain >= 0 ? '+' : ''}'
                '${loudness.minGain.toStringAsFixed(1)} '
                'to '
                '${loudness.maxGain >= 0 ? '+' : ''}'
                '${loudness.maxGain.toStringAsFixed(1)} dB',
                style: TextStyle(
                  color: col.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _gainSlider(
                  title: 'Min Gain',
                  value: loudness.minGain,
                  min: -20,
                  max: 0,
                  onChanged: (value) {
                    final maxGain = loudness.maxGain < value
                        ? value
                        : loudness.maxGain;

                    con.config.putAndWriteAll(
                      loudnessConfigKey,
                      loudness
                          .copyWith(minGain: value, maxGain: maxGain)
                          .toMap(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _gainSlider(
                  title: 'Max Gain',
                  value: loudness.maxGain,
                  min: 0,
                  max: 12,
                  onChanged: (value) {
                    final minGain = loudness.minGain > value
                        ? value
                        : loudness.minGain;

                    con.config.putAndWriteAll(
                      loudnessConfigKey,
                      loudness
                          .copyWith(minGain: minGain, maxGain: value)
                          .toMap(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gainSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(color: col.onSurfaceVariant, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '${value >= 0 ? '+' : ''}'
              '${value.toStringAsFixed(1)} dB',
              style: TextStyle(
                color: col.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          min: min,
          max: max,
          value: value.clamp(min, max),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
