import 'dart:async';

import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
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

  void openConfrmAndPlay(AudioFile file) async {
    final pCon = ControllerManager.read<PlayerStateController>();
    final current = pCon.state.current;
    if (current != null && current.id == file.id && pCon.state.playing) {
      final confirmed = await showConfirmDialog(
        context,
        'Want to Song Restart!',
      );
      if (confirmed) {
        await pCon.actions.setTracks(
          ControllerManager.read<AllFileStateController>().files,
          source: const AllFileStateSource(),
        );
        pCon.actions.open(file);
      }
      return;
    }
    await pCon.actions.setTracks(
      ControllerManager.read<AllFileStateController>().files,
      source: const AllFileStateSource(),
    );
    // print('item: $file');
    pCon.actions.open(file);
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
          _searchbar(),
          if (result.isEmpty && showNotfoundResult) _result(),
          if (result.isEmpty && controller.text.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Looking for a song?',
                  style: TextStyle(
                    fontWeight: .w700,
                    fontSize: 18,
                    color: col.onSurface,
                  ),
                ),
              ),
            ),
          AudioSliverList(list: result, onClicked: openConfrmAndPlay),
        ],
      ),
    );
  }

  SliverFillRemaining _result() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Icon(Icons.search_off),
          SizedBox(height: 12),
          Text(
            'No songs found',
            style: TextStyle(
              fontWeight: .w600,
              fontSize: 16,
              color: col.onSurface,
            ),
          ),
          Text(
            'Try searching for something else',
            style: TextStyle(
              fontWeight: .w400,
              fontSize: 14,
              color: col.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _searchbar() {
    return SliverToBoxAdapter(
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
    );
  }
}
