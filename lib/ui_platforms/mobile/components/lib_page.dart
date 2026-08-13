import 'package:flutter/material.dart';
import 'package:than_sound/ui/favourite/favourite_count_view.dart';

class LibPage extends StatelessWidget {
  const LibPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Library")),
      body: CustomScrollView(
        slivers: [
          SliverGrid.list(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisExtent: 50,
            ),
            children: [FavouriteCountView()],
          ),
        ],
      ),
    );
  }
}
