import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer_mode.dart';

class SleepTimerDropdown extends StatelessWidget {
  SleepTimerDropdown({super.key});

  final list = SleepTimerMode.values
      .map(
        (e) => DropdownMenuItem<SleepTimerMode>(value: e, child: Text(e.lable)),
      )
      .toList();
  final cf = CFBStore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: cf.stream.put.where((e) => e.key == playerSleepTimerTypeKey),
      builder: (context, asyncSnapshot) {
        final val = SleepTimerMode.fromValue(
          cf.getString(playerSleepTimerTypeKey),
        );
        return DropdownButtonHideUnderline(
          child: DropdownButton<SleepTimerMode>(
            borderRadius: .circular(15),
            dropdownColor: context.colorScheme.surfaceBright,
            value: val,
            items: list,
            onChanged: (value) {
              cf.put(playerSleepTimerTypeKey, value!.name);
            },
          ),
        );
      },
    );
  }
}
