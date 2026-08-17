import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/ui_platforms/components/dialog/error_alert_dialog.dart';
import 'package:than_sound/ui_platforms/components/favourite/desktop_favourite_list_page.dart';
import 'package:than_sound/ui_platforms/components/favourite/favourite_controller.dart';
import 'package:than_sound/ui_platforms/components/favourite/mobile_favourite_list_page.dart';

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
      onTap: () {
        if (Platform.isAndroid) {
          context.pushMaterialPageRoute(
            builder: (mainCtx) => MobileFavouriteListPage(),
          );
        } else if (Platform.isLinux) {
          context.pushMaterialPageRoute(
            builder: (mainCtx) => DesktopFavouriteListPage(),
          );
        } else {
          showErrorDialog(context,"Not Supported Platform!");
        }
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
              stream: con.events,
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
