import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/mobile/setting/bluetooth_control_setting.dart';
import 'package:than_sound/ui_platforms/pages/equalizers/audio_eq_home_page.dart';

class AudioSettingPage extends StatelessWidget {
  const AudioSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: Text('Audio Setting')),
      body: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: [
            ListTile(
              tileColor: col.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: .circular(15)),
              contentPadding: .symmetric(vertical: 10, horizontal: 12),
              leading: Container(
                padding: .all(10),
                decoration: BoxDecoration(
                  color: col.primaryContainer,
                  borderRadius: .circular(15),
                  boxShadow: [
                    .new(color: col.primary, blurRadius: 12, spreadRadius: 1),
                  ],
                ),
                child: Icon(
                  Icons.equalizer_outlined,
                  color: col.onPrimaryContainer,
                ),
              ),
              title: Text('Audio Equalizers'),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              onTap: () {
                context.pushMaterialPageRoute(
                  builder: (mainCtx) => AudioEqHomePage(),
                );
              },
            ),
            BluetoothControlSetting(),
          ],
        ),
      ),
    );
  }
}
