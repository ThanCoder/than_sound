import 'dart:async';

import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_sliver_list.dart';

class MobileSearchPage extends StatefulWidget {
  const MobileSearchPage({super.key});

  @override
  State<MobileSearchPage> createState() => _MobileSearchPageState();
}

class _MobileSearchPageState extends State<MobileSearchPage> {
  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  void dispose() {
    focusNode.dispose();
    searchDelay?.cancel();
    super.dispose();
  }

  final controller = TextEditingController();
  final focusNode = FocusNode();
  final con = ControllerManager.read<AllFileStateController>();
  Timer? searchDelay;

  void onChanged(String val) {
    searchDelay?.cancel();
    searchDelay = Timer(Duration(seconds: 1), () {
      onSearch(val);
    });
  }

  bool isSearch = false;
  bool showNotfoundResult = false;
  List<AudioFile> result = [];

  void onSearch(String val) {
    if (!mounted) return;
    setState(() {
      isSearch = true;
      showNotfoundResult = false;
    });
    result = con.files.where((e) {
      final t = e.autoTitle.toLowerCase();
      final n = e.name.toLowerCase();
      if (t.contains(val)) return true;
      if (n.contains(val)) return true;

      return false;
    }).toList();

    if (!mounted) return;
    if (result.isEmpty) {
      showNotfoundResult = true;
    }
    setState(() {
      isSearch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(title: Text('Search')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: !isSearch ? null : LinearProgressIndicator(),
          ),
          SliverToBoxAdapter(
            child: SearchBar(
              hintText: 'Search',
              focusNode: focusNode,
              controller: controller,
              leading: Icon(Icons.search),
              trailing: [
                IconButton(
                  onPressed: () {
                    controller.text = '';
                    result.clear();
                    setState(() {
                      showNotfoundResult = false;
                    });
                  },
                  icon: Icon(Icons.clear_all_outlined),
                ),
              ],
              onTapOutside: (event) {
                focusNode.unfocus();
                if (showNotfoundResult != false) {
                  setState(() {
                    showNotfoundResult = false;
                  });
                }
              },
              onChanged: onChanged,
            ),
          ),
          if (result.isEmpty && showNotfoundResult)
            SliverFillRemaining(
              child: Center(
                child: Container(
                  height: 150,
                  padding: .symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: col.surfaceContainer,
                    borderRadius: .circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'Audio Not Found!',
                        style: TextStyle(
                          color: col.onSurface,
                          fontWeight: .w700,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 20),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: col.surfaceContainer,
                          foregroundColor: col.onSurface,
                        ),
                        onPressed: () {
                          setState(() {
                            showNotfoundResult = false;
                          });
                          focusNode.requestFocus();
                        },
                        icon: Icon(
                          Icons.search_outlined,
                          size: 36,
                          color: col.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          AudioSliverList(list: result, onClicked: openConfrmAndPlay),
        ],
      ),
    );
  }

  void openConfrmAndPlay(AudioFile file) async {
    final pCon = ControllerManager.read<PlayerStateController>();
    final current = pCon.current.value;
    if (current != null && current.id == file.id && pCon.state.playing) {
      final confirmed = await showConfirmDialog(
        context,
        'Want to Song Restart!',
      );
      if (confirmed) {
        await pCon.setTracks(
          ControllerManager.read<AllFileStateController>().files,
          source: .allFileState,
        );
        pCon.open(file);
      }
      return;
    }
    await pCon.setTracks(
      ControllerManager.read<AllFileStateController>().files,
      source: .allFileState,
    );
    // print('item: $file');
    pCon.open(file);
  }
}
