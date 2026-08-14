import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/components/player_config_setting/loudness_config_setting.dart';
import 'package:than_sound/ui_platforms/mobile/setting/bluetooth_control_setting.dart';

class AudioSettingPage extends StatelessWidget {
  const AudioSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Setting')),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [LoudnessConfigSetting(), BluetoothControlSetting()],
        ),
      ),
    );
  }
}
