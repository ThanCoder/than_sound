import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/const_keys.dart';

class AudioFilterSetting extends StatefulWidget {
  const new({super.key});

  @override
  State<AudioFilterSetting> createState() => _AudioFilterSettingState();
}

class _AudioFilterSettingState extends State<AudioFilterSetting> {
  final cf = CFBStore.getInstance;
  ColorScheme get col => Theme.of(context).colorScheme;
  final durs = [5, 10, 15, 20, 21, 25, 30];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: cf.stream.put.where(
        (e) =>
            e.key == audioFilterDurationEnableKeyName ||
            e.key == audioFilterDurationValueKeyName,
      ),
      builder: (context, asyncSnapshot) {
        final enable = cf.getBool(audioFilterDurationEnableKeyName, true);
        final sec = cf.getInt(audioFilterDurationValueKeyName, 5);
        return Column(
          spacing: 10,
          children: [
            _enableWidget(enable),
            if (enable) Row(children: [Expanded(child: _durItem(sec))]),
          ],
        );
      },
    );
  }

  Widget _durItem(int sec) => Container(
    padding: .all(10),
    decoration: BoxDecoration(
      color: col.surfaceContainer,
      borderRadius: .circular(14),
    ),
    child: Wrap(
      spacing: 5,
      runSpacing: 5,
      children: durs
          .map(
            ((e) => GestureDetector(
              onTap: () =>
                  cf.putAndWriteAll(audioFilterDurationValueKeyName, e),
              child: Container(
                padding: .symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: e == sec ? col.primary : col.surfaceContainerHigh,
                  borderRadius: .circular(15),
                ),
                child: Text(
                  '$e s',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: .w700,
                    color: e == sec ? col.onPrimary : col.onSurface,
                  ),
                ),
              ),
            )),
          )
          .toList(),
    ),
  );

  SwitchListTile _enableWidget(bool enable) {
    return SwitchListTile.adaptive(
      tileColor: col.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(15)),
      title: Row(
        children: [
          Container(
            padding: .all(10),
            decoration: BoxDecoration(
              color: col.primaryContainer,
              borderRadius: .circular(15),
              boxShadow: !enable
                  ? null
                  : [
                      .new(
                        blurRadius: 12,
                        color: col.onPrimaryContainer,
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: Icon(
              Icons.audiotrack_outlined,
              color: !enable
                  ? col.onPrimaryContainer.withValues(alpha: .45)
                  : col.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Audio Filter Duration',
            style: TextStyle(
              fontWeight: .w600,
              fontSize: 16,
              color: !enable
                  ? col.onSurface.withValues(alpha: .45)
                  : col.onSurface,
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Enable or disable audio filtering by duration',
        maxLines: 2,
        overflow: .ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: .w400,
          color: !enable
              ? col.onSurfaceVariant.withValues(alpha: .45)
              : col.onSurfaceVariant,
        ),
      ),
      value: enable,
      onChanged: (value) {
        cf.putAndWriteAll(audioFilterDurationEnableKeyName, value);
      },
    );
  }
}
