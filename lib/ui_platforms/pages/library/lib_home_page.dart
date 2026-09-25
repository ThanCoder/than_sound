import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/pages/audio_folder/audio_folder_page.dart';
import 'package:than_sound/ui_platforms/pages/library/favourite/favourite_count_view.dart';
import 'package:than_sound/ui_platforms/pages/tag_group/tag_home_page.dart';

class LibHomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<LibHomePage> createState() => _LibHomePageState();
}

class _LibHomePageState extends State<LibHomePage> {
  ColorScheme get col => context.colorScheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: context.colorScheme.surfaceContainer,
              foregroundColor: context.colorScheme.onSurfaceVariant,
              title: Text("Library"),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverGrid.list(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisExtent: 50,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              children: [
                FavouriteCountView(),
                itemView(
                  'Audio Tags',
                  icon: Icon(Icons.tag_outlined),
                  onTap: () {
                    context.pushMaterialPageRoute(
                      builder: (mainCtx) => TagHomePage(),
                    );
                  },
                ),
                itemView(
                  'Audio Folders',
                  icon: Icon(Icons.folder_outlined),
                  onTap: () {
                    context.pushMaterialPageRoute(
                      builder: (mainCtx) => AudioFolderPage(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemView(
    String title, {
    Widget? icon,
    void Function()? onTap,
    String? rightTitle,
  }) {
    return InkWell(
      borderRadius: .circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: col.surfaceContainerHighest,
          borderRadius: .circular(15),
          border: .all(color: col.outlineVariant.withValues(alpha: .5)),
        ),
        child: Row(
          children: [
            ?icon,
            if (icon != null) SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: .bold),
              ),
            ),
            if (rightTitle != null)
              Text(
                rightTitle,
                style: TextStyle(fontSize: 20, fontWeight: .bold),
              ),
          ],
        ),
      ),
    );
  }
}
