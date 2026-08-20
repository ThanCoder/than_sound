import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/components/c_slider.dart';

class SoundVolumeMenu extends StatefulWidget {
  const SoundVolumeMenu({super.key});

  @override
  State<SoundVolumeMenu> createState() => _SoundVolumeMenuState();
}

class _SoundVolumeMenuState extends State<SoundVolumeMenu> {
  final py = ControllerManager.read<PlayerStateController>().player;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        children: [
          StreamBuilder(
            stream: py.stream.volume,
            builder: (context, asyncSnapshot) {
              return _VolumeWidget(
                value: py.state.volume,
                max: 100,
                onChanged: py.setVolume,
                icon: Icon(Icons.volume_up_rounded),
                title: 'Player',
              );
            },
          ),
          StreamBuilder(
            stream: py.stream.volumeGain,
            builder: (context, asyncSnapshot) {
              return _VolumeWidget(
                value: py.state.volumeGain,
                max: 100,
                onChanged: py.setVolumeGain,
                icon: Icon(Icons.volume_up_rounded),
                title: 'Gain',
              );
            },
          ),
          if (py.state.systemVolume != null)
            StreamBuilder(
              stream: py.stream.systemVolume,
              builder: (context, asyncSnapshot) {
                return _VolumeWidget(
                  value: py.state.systemVolume ?? 0.0,
                  max: 100,
                  onChangeEnd: py.setSystemVolume,
                  icon: Icon(Icons.volume_up_rounded),
                  title: 'System Volume',
                );
              },
            ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}

class _VolumeWidget extends StatelessWidget {
  const _VolumeWidget({
    required this.value,
    required this.max,
    this.onChangeEnd,
    required this.title,
    required this.icon,
    this.onChanged,
  }) : min = 0.0;

  final double value;
  final double min;
  final double max;
  final String title;
  final Widget icon;
  final void Function(double value)? onChangeEnd;
  final void Function(double value)? onChanged;

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Container(
      padding: .symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(15),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 5,
            children: [
              Text(title, style: TextStyle(fontSize: 17, fontWeight: .w600)),
            ],
          ),

          SizedBox(height: 5),
          CSlider(
            min: min,
            max: max,
            value: value,
            onChangeEnd: onChangeEnd,
            onChanged: onChanged,
          ),
          SizedBox(height: 2),
          Padding(
            padding: .symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text('${min.toInt()}%'),
                Text(value.toStringAsFixed(1)),
                Text('${max.toInt()}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
