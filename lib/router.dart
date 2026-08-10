import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/content/audio_content_screen.dart';

Future<void> goContent(BuildContext context) async {
  context.pushMaterialPageRoute(builder: (mainCtx) => AudioContentScreen());
}
