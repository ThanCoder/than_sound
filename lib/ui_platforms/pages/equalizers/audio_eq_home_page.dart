import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import 'package:than_sound/ui_platforms/pages/equalizers/audio_bass_eq_page.dart';

class AudioEqHomePage extends StatefulWidget {
  const AudioEqHomePage({super.key});

  @override
  State<AudioEqHomePage> createState() => _AudioEqHomePageState();
}

class _AudioEqHomePageState extends State<AudioEqHomePage> {
  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(
        title: Text(
          'Audio EQ Home Page',
          style: TextStyle(color: col.onSurface),
        ),
      ),
      body: Column(
        spacing: 8,
        children: [
          ListTile(
            tileColor: col.surfaceContainer,
            shape: RoundedRectangleBorder(borderRadius: .circular(15)),
            leading: Icon(
              Icons.equalizer_outlined,
              color: col.primaryContainer,
            ),
            title: Text(
              'Bass',
              style: TextStyle(color: col.onSurface, fontWeight: .w600),
            ),
            subtitle: Text(
              'Bass Boost',
              style: TextStyle(color: col.onSurfaceVariant),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_outlined,
              color: col.primary,
            ),
            onTap: () {
              context.pushMaterialPageRoute(
                builder: (mainCtx) => AudioBassEqPage(),
              );
            },
          ),
        ],
      ),
    );
  }
}
