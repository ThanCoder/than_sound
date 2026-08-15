import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/all_audio/all_state.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/desktop/components/audio_item_menu_dialog.dart';
import 'package:than_sound/ui_platforms/ui/audio/thumbnail.dart';

class DesktopListPage extends StatefulWidget {
  const DesktopListPage({super.key});

  @override
  State<DesktopListPage> createState() => _DesktopListPageState();
}

class _DesktopListPageState extends State<DesktopListPage> {
  @override
  void dispose() {
    hozScrollController.dispose();
    super.dispose();
  }

  final hozScrollController = ScrollController();
  final allC = ControllerManager.read<AllFileStateController>();

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Desktop Audio List'),
        actions: [
          IconButton(
            onPressed: () {
              allC.scanFromStorage(usedCache: true);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: CustomScrollView(slivers: [_list()]),
    );
  }

  StreamBuilder<AllState> _list() {
    final col = context.colorScheme;
    return StreamBuilder(
      stream: allC.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return SliverFillRemaining(child: Center(child: TLoaderRandom()));
        }
        return SliverToBoxAdapter(
          child: SingleChildScrollView(
            controller: hozScrollController,
            scrollDirection: .horizontal,
            child: Scrollbar(
              thumbVisibility: true,
              controller: hozScrollController,
              child: DataTable(
                dataRowMaxHeight: 80,
                columnSpacing: 8,
                headingTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: .w600,
                  color: col.primary,
                ),
                columns: columns,
                rows: rows(allC.files),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> rows(List<AudioFile> files) {
    final col = context.colorScheme;
    return files
        .map(
          (e) => DataRow(
            cells: [
              DataCell(
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Thumbnail(file: e),
                  ),
                ),
              ),
              DataCell(
                GestureDetector(
                  onSecondaryTap: () => _showItemMenu(e),
                  onTap: () => _itemClicked(e),
                  child: Text(
                    e.autoTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: .w400,
                      color: col.primary,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  '${e.meta.artist}/${e.meta.album}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: .w400,
                    color: col.primary,
                  ),
                ),
              ),
              DataCell(
                Text(
                  e.meta.duration.formatClockLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: .w400,
                    color: col.primary,
                  ),
                ),
              ),
              DataCell(
                Text(
                  e.meta.format,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: .w400,
                    color: col.primary,
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  List<DataColumn> get columns {
    return [
      DataColumn(label: Text('Art'), columnWidth: FixedColumnWidth(150)),
      DataColumn(label: Text('Title'), columnWidth: FixedColumnWidth(200)),
      DataColumn(
        label: Text('Artist / Album '),
        columnWidth: FixedColumnWidth(200),
      ),
      DataColumn(label: Text('Duration')),
      DataColumn(label: Text('Format')),
    ];
  }

  final pl = ControllerManager.read<PlayerStateController>();

  void _itemClicked(AudioFile file) async {
    await pl.setTracks(
      ControllerManager.read<AllFileStateController>().files,
      source: .allFileState,
    );
    // print('item: $file');
    pl.open(file);
  }

  void _showItemMenu(AudioFile file) {
    showDialog(
      context: context,
      builder: (context) => AudioItemMenuDialog(file: file),
    );
  }
}
