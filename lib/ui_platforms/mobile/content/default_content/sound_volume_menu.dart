import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/ui_platforms/ui/content/c_slider.dart';

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
                onChangeEnd: py.setVolume,
                icon: Icon(Icons.volume_up_rounded),
                title: 'Player Volume',
              );
            },
          ),
          StreamBuilder(
            stream: py.stream.volumeGain,
            builder: (context, asyncSnapshot) {
              return _VolumeWidget(
                value: py.state.volumeGain,
                max: py.state.volumeMax,
                onChangeEnd: py.setVolumeGain,
                icon: Icon(Icons.volume_up_rounded),
                title: 'Gain Volume',
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
  final double value;
  final double min;
  final double max;
  final String title;
  final Widget icon;
  final void Function(double value) onChangeEnd;
  const _VolumeWidget({
    required this.value,
    required this.max,
    required this.onChangeEnd,
    required this.title,
    required this.icon,
  }) : min = 0.0;

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Container(
      padding: .symmetric(vertical: 4, horizontal: 5),
      decoration: BoxDecoration(
        color: col.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: .circular(15),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            spacing: 5,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: col.primary.withValues(alpha: .45),
                  borderRadius: .circular(15),
                ),
                child: icon,
              ),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: .w600)),
            ],
          ),

          SizedBox(height: 5),
          CSlider(min: min, max: max, value: value, onChangeEnd: onChangeEnd),
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
