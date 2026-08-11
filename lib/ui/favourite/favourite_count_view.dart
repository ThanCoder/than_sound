import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/ui/favourite/favourite_controller.dart';
import 'package:than_sound/ui/favourite/favourite_list_page.dart';

class FavouriteCountView extends StatelessWidget {
  const FavouriteCountView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = context.read<FavouriteController>();
    return InkWell(
      onTap: () {
        context.pushMaterialPageRoute(
          builder: (mainCtx) => FavouriteListPage(),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            spacing: 3,
            children: [
              SvgPicture.asset('assets/svg/music-note-slider-svgrepo-com.svg'),
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
      ),
    );
  }
}
