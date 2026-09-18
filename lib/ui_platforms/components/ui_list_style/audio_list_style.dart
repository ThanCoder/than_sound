import 'package:flutter/material.dart';

enum AudioListStyle {
  list,
  grid;

  IconData get iconData {
    return switch (this) {
      grid => Icons.grid_view_outlined,
      list => Icons.view_list_outlined,
    };
  }
}

class AudioListStyleViewButton extends StatefulWidget {
  const new({super.key});

  @override
  State<AudioListStyleViewButton> createState() =>
      _AudioListStyleViewButtonState();
  static final current = ValueNotifier<AudioListStyle>(.list);
}

class _AudioListStyleViewButtonState extends State<AudioListStyleViewButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AudioListStyleViewButton.current,
      builder: (context, value, child) {
        return IconButton(
          icon: Icon(value.iconData),
          onPressed: () {
            final index = AudioListStyle.values.indexOf(value);
            final next = (index + 1) % AudioListStyle.values.length;
            AudioListStyleViewButton.current.value =
                AudioListStyle.values[next];
          },
        );
      },
    );
  }
}
