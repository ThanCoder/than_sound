import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';

class BluetoothControlSetting extends StatelessWidget {
  const BluetoothControlSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final cf = CFBStore.getInstance;
    final col = context.colorScheme;
    return StreamBuilder(
      stream: cf.stream.put.where((e) => e.key == audioBluetoothControlKeyName),

      builder: (context, asyncSnapshot) {
        return SwitchListTile.adaptive(
          tileColor: col.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: .circular(15)),
          title: Row(
            children: [
              Container(
                padding: .all(8),
                decoration: BoxDecoration(
                  color: col.surface,
                  borderRadius: .circular(15),
                ),
                child: Icon(Icons.bluetooth, color: col.onSurface),
              ),
              SizedBox(width: 10),
              Text(
                'Bluetooth Control',
                style: TextStyle(fontWeight: .w600, fontSize: 16),
              ),
            ],
          ),
          subtitle: Text(
            'Control Media Playback from Bluetooth!',
            maxLines: 2,
            overflow: .ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: .w400),
          ),
          value: cf.getBool(audioBluetoothControlKeyName, true),
          onChanged: (value) {
            cf.putAndWriteAll(audioBluetoothControlKeyName, value);
          },
        );
      },
    );
  }
}
