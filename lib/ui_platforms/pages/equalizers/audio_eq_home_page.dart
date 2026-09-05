import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/pages/equalizers/audio_treble_eq_page.dart';

import 'package:than_sound/ui_platforms/pages/equalizers/audio_bass_eq_page.dart';
import 'package:than_sound/ui_platforms/pages/equalizers/loudness_eq_page.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            _menuTile(
              'Loudness',
              icon: Icons.speaker_group_outlined,
              subTitle: 'Normalization ON/OFF',
              onTap: () {
                context.pushMaterialPageRoute(
                  builder: (mainCtx) => LoudnessEqPage(),
                );
              },
            ),
            _menuTile(
              'Bass',
              icon: Icons.equalizer_outlined,
              subTitle: 'Bass Boost',
              onTap: () {
                context.pushMaterialPageRoute(
                  builder: (mainCtx) => AudioBassEqPage(),
                );
              },
            ),
            _menuTile(
              'Trable',
              icon: Icons.equalizer_outlined,
              subTitle: 'Trable Boost',
              onTap: () {
                context.pushMaterialPageRoute(
                  builder: (mainCtx) => AudioTrebleEqPage(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
    String title, {
    required IconData icon,
    required String subTitle,
    void Function()? onTap,
  }) {
    return ListTile(
      tileColor: col.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(15)),
      leading: Container(
        padding: .all(5),
        decoration: BoxDecoration(
          color: col.primaryContainer,
          borderRadius: .circular(10),
          boxShadow: [.new(color: col.primary, blurRadius: 12)],
        ),
        child: Icon(icon, color: col.onPrimaryContainer),
      ),
      title: Text(
        title,
        style: TextStyle(color: col.onSurface, fontWeight: .w600),
      ),
      subtitle: Text(subTitle, style: TextStyle(color: col.onSurfaceVariant)),
      trailing: Icon(Icons.arrow_forward_ios_outlined, color: col.primary),
      onTap: onTap,
    );
  }
}
