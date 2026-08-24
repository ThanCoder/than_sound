import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/pages/favourite/favourite_controller.dart';

class FavouriteButton extends StatefulWidget {
  final AudioFile file;
  final double? size;
  const FavouriteButton({super.key, required this.file, this.size});

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  final con = ControllerManager.read<FavouriteController>();
  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        con.toggle(widget.file);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: StreamBuilder(
          stream: con.event.whereType<FavouriteControllerValueChanged>(),
          builder: (context, asyncSnapshot) {
            if (con.isExists(widget.file)) {
              return Icon(
                Icons.favorite_outlined,
                size: widget.size,
                color: col.primary,
              );
            }
            return Icon(Icons.favorite_outline, size: widget.size);
          },
        ),
      ),
    );
  }
}
