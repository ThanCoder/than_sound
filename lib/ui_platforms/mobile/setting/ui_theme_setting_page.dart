import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/ui/partials/color_scheme_picker.dart';

class UiThemeSettingPage extends StatefulWidget {
  const UiThemeSettingPage({super.key});

  @override
  State<UiThemeSettingPage> createState() => _UiThemeSettingPageState();
}

class _UiThemeSettingPageState extends State<UiThemeSettingPage> {
  // @override
  // void initState() {
  //   store.stream.putError.listen((event) {
  //     print('putError: $event');
  //   });
  //   store.stream.saveError.listen((event) {
  //     print('saveError: $event');
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    return Scaffold(
      backgroundColor: col.surfaceContainerLow,
      appBar: AppBar(title: Text('UI Color Theme')),
      body: pickColorSeed(),
    );
  }

  final store = CFBStore.getInstance;

  Widget pickColorSeed() {
    final col = context.colorScheme;
    return StreamBuilder(
      stream: store.stream.put.where(
        (e) => e.key == appEnableColorSeedKey || e.key == appColorSeedKey,
      ),
      builder: (context, asyncSnapshot) {
        final enabledColor = store.getBool(appEnableColorSeedKey, false);
        final seedInt = store.getInt(appColorSeedKey);

        Color currentSeedColor = Colors.red; // Color.fromARGB();
        if (seedInt != 0) {
          currentSeedColor = Color(seedInt);
        }
        return Container(
          padding: .symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: .circular(15),
            color: col.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Pick Color Seeds',
                style: TextStyle(
                  color: enabledColor
                      ? col.primary
                      : col.onSurfaceVariant.withValues(alpha: .38),
                  fontWeight: .w600,
                ),
              ),
              // current color seed
              if (enabledColor)
                GestureDetector(
                  onTap: () => pickSeedColor(currentSeedColor),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: currentSeedColor,
                        borderRadius: .circular(15),
                      ),
                    ),
                  ),
                ),
              // Spacer(),
              Switch(
                value: enabledColor,
                onChanged: (value) {
                  store
                      .put(appEnableColorSeedKey, value)
                      .put(appColorSeedKey, currentSeedColor.toARGB32())
                      .writeAll();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void pickSeedColor(Color color) async {
    final picked = await showAdaptiveDialog<Color>(
      context: context,

      builder: (context) => ColorSchemePicker(pickerColor: color),
    );
    if (picked == null) return;
    store.putAndWriteAll(appColorSeedKey, picked.toARGB32());
  }
}
