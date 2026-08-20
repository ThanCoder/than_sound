import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/tag_widget.dart';
import 'package:than_sound/ui_platforms/mobile/home/library/lib_tag_type.dart';

class TagHeader extends StatelessWidget {
  const TagHeader({super.key, required this.currentTag});

  final ValueNotifier<LibTagType> currentTag;

  // final items = LibTagType.values.map((e)=> e)
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        child: ValueListenableBuilder(
          valueListenable: currentTag,
          builder: (context, value, child) {
            return Row(
              spacing: 8,
              children: LibTagType.values
                  .map(
                    (e) => TagWidget(
                      title: e.name.toCaptalize,
                      icon: Icon(Icons.person_2_outlined),
                      selected: currentTag.value == e,
                      onTap: () {
                        currentTag.value = e;
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
