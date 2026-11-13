import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/ui/build_context_x.dart';
import 'package:than_sound/platforms/pages/library/favourite/favourite_controller.dart';
import 'package:than_sound/platforms/pages/library/favourite/mobile_favourite_list_page.dart';

class FavouriteCountView extends StatefulWidget {
  const FavouriteCountView({super.key});

  @override
  State<FavouriteCountView> createState() => _FavouriteCountViewState();
}

class _FavouriteCountViewState extends State<FavouriteCountView> {
  final con = ControllerManager.read<FavouriteController>();

  @override
  Widget build(BuildContext context) {
    final col = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: .circular(15),
      onTap: () {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => MobileFavouriteListPage(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: col.surfaceContainerHighest,
          borderRadius: .circular(15),
          border: .all(color: col.outlineVariant.withValues(alpha: .5)),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svg/music-note-slider-svgrepo-com.svg',
              colorFilter: .mode(col.onPrimaryContainer, .srcIn),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Favourites',
                style: TextStyle(fontSize: 13, fontWeight: .bold),
              ),
            ),
            StreamBuilder(
              stream: con.event.whereType<FavouriteControllerValueChanged>(),
              builder: (context, asyncSnapshot) {
                return Text(
                  '${con.files.length}',
                  style: TextStyle(fontSize: 20, fontWeight: .bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
