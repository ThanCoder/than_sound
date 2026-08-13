import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/ui_platforms/ui/favourite/favourite_controller.dart';
import 'package:than_sound/ui_platforms/ui/favourite/favourite_list_page.dart';

class FavouriteCountView extends StatelessWidget {
  const FavouriteCountView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<FavouriteController>();
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => FavouriteListPage(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: .circular(15),
          border: .all(color: colorScheme.outlineVariant.withValues(alpha: .5)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svg/music-note-slider-svgrepo-com.svg',
              colorFilter: .mode(colorScheme.onPrimaryContainer, .srcIn),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Favourites',
                style: TextStyle(fontSize: 13, fontWeight: .bold),
              ),
            ),
            Text(
              '${con.files.length}',
              style: TextStyle(fontSize: 20, fontWeight: .bold),
            ),
          ],
        ),
      ),
    );
  }
}
