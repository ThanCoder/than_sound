import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/ui/favourite/favourite_controller.dart';

class FavouriteButton extends StatelessWidget {
  final AudioFile file;
  final double? size;
  const FavouriteButton({super.key, required this.file, this.size});

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<FavouriteController>();
    return GestureDetector(
      onTap: () {
        con.toggle(file);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: StreamBuilder(
          stream: con.events,
          builder: (context, asyncSnapshot) {
            if (con.isExists(file)) {
              return Icon(Icons.favorite_outlined, size: size);
            }
            return Icon(Icons.favorite_outline, size: size);
          },
        ),
      ),
    );
  }
}
