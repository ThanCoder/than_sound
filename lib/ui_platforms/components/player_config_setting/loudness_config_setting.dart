import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/player_config/loudess_config.dart';

class LoudnessConfigSetting extends StatefulWidget {
  const LoudnessConfigSetting({super.key});

  @override
  State<LoudnessConfigSetting> createState() => _LoudnessConfigSettingState();
}

class _LoudnessConfigSettingState extends State<LoudnessConfigSetting> {
  final store = CFBStore.getInstance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return StreamBuilder(
      stream: store.events.where(
        (e) => e is PutValue && e.key == loudnessConfigKey,
      ),
      builder: (context, asyncSnapshot) {
        final config = LoudessConfig.fromMap(store.getMap(loudnessConfigKey));
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
            borderRadius: .circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.snowing, size: 30, color: colorScheme.primary),
                    SizedBox(width: 10),
                    Text(
                      'Loundness Controller',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: .all(8),

                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text('Loudness', style: TextStyle(fontWeight: .w600)),
                          Text(
                            'Normalization ON/OFF',
                            style: TextStyle(fontWeight: .w400),
                          ),
                        ],
                      ),
                      Spacer(),
                      Switch.adaptive(
                        value: config.enabled,
                        onChanged: (value) {
                          save(config.copyWith(enabled: value));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void save(LoudessConfig config) {
    store.putAndWriteAll(loudnessConfigKey, config.toMap());
    // final py = ControllerManager.read<PlayerStateController>().player;
    // py.updateAudioEffects(mapper)
    // py.set
  }
}
