import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/core/utils/tem_storage.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_dropdown.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_mode.dart';

class SleepTimerPage extends StatefulWidget {
  const SleepTimerPage({super.key});

  @override
  State<SleepTimerPage> createState() => _SleepTimerPageState();
}

class _SleepTimerPageState extends State<SleepTimerPage> {
  final cf = TemStorage.store;

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: .circular(15),
          color: col.surface,
        ),
        child: Column(
          children: [
            _header(),
            Expanded(child: Center(child: _body())),
          ],
        ),
      ),
    );
  }

  Container _header() {
    final col = context.colorScheme;
    return Container(
      padding: .all(10),
      decoration: BoxDecoration(
        borderRadius: .circular(15),
        color: col.surfaceContainerHighest,
      ),
      child: Column(
        spacing: 5,
        children: [Text('Sleep Timer Modes'), SleepTimerDropdown()],
      ),
    );
  }

  Widget _body() {
    final col = context.colorScheme;
    return StreamBuilder(
      stream: cf.stream.put.where((e) => e.key == playerSleepTimerTypeKey),
      builder: (context, snapshot) {
        final type = SleepTimerMode.fromValue(
          cf.getString(playerSleepTimerTypeKey),
        );
        if (type == .duration) {
          return sleepTimerClock();
        }
        if (type == .endOfPlaylist) {
          return Text(
            'It Will Stop End Playlist!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: col.primary,
            ),
          );
        }
        if (type == .endOfTrack) {
          return Text(
            'It Will Stop End Of Song!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: col.primary,
            ),
          );
        }

        return Text(
          'Timer Not Setted!',
          style: TextStyle(fontSize: 20, fontWeight: .bold, color: col.primary),
        );
      },
    );
  }

  Widget sleepTimerClock() {
    return TimePickerDialog(initialTime: .now());
  }
}
