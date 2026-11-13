import 'package:material_ui/material_ui.dart';
import 'package:than_sound/ui/build_context_x.dart';

import 'package:than_sound/platforms/pages/setting/audio_filter_setting.dart';
import 'package:than_sound/platforms/pages/setting/bluetooth_control_setting.dart';
import 'package:than_sound/platforms/pages/equalizers/audio_eq_home_page.dart';

class AudioSettingPage extends StatelessWidget {
  const AudioSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final col = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: Text('Audio Setting')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 12,
            children: [
              AudioEqHomePage.listTile(context),
              BluetoothControlSetting(),
              AudioFilterSetting(),
            ],
          ),
        ),
      ),
    );
  }
}
