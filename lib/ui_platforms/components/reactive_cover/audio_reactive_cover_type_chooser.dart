import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/const_keys.dart';
import 'package:than_sound/ui_platforms/components/reactive_cover/reactive_cover_types.dart';

class AudioReactiveCoverTypeChooser extends StatelessWidget {
  AudioReactiveCoverTypeChooser({super.key});

  final store = CFBStore.getInstance;

  final list = ReactiveCoverType.values
      .map(
        (e) => DropdownMenuItem<ReactiveCoverType>(
          value: e,
          child: Text(e.name.capitalize),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: CFBStore.getInstance.events.where(
        (e) => e is PutValue && e.key == audioContentUseReactiveCoverTypeKey,
      ),
      builder: (context, _) {
        final value = ReactiveCoverType.fromValue(
          store.getString(audioContentUseReactiveCoverTypeKey),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.animation_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reactive Cover',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Choose how the cover reacts to audio',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: value,
                  borderRadius: BorderRadius.circular(14),
                  items: list,
                  onChanged: (value) {
                    store.putAndWriteAll(
                      audioContentUseReactiveCoverTypeKey,
                      value!.name,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
