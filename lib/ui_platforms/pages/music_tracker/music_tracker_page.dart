import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/music_tracker_controller.dart';
import 'package:than_sound/ui_platforms/pages/music_tracker/song_stats.dart';

class MusicTrackerPage extends StatefulWidget {
  const MusicTrackerPage({super.key});

  @override
  State<MusicTrackerPage> createState() => _MusicTrackerPageState();
}

class _MusicTrackerPageState extends State<MusicTrackerPage> {
  final con = ControllerManager.read<MusicTrackerController>();

  void onClicked(AudioFile audio, SongStats stat) {
    openConfrmAndPlay(audio);
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
          source: .allFileState,
        );
        pCon.actions.open(file);
      }
      return;
    }
    await pCon.actions.setTracks(
      ControllerManager.read<AllFileStateController>().files,
      source: .allFileState,
    );
    // print('item: $file');
    pCon.actions.open(file);
  }

  ColorScheme get col => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: con.event,
      builder: (context, snapshot) {
        List<SongStats> stats = con.statusMap.values.toList();
        return _body(stats);
      },
    );
  }

  Widget _body(List<SongStats> stats) {
    // final color = Theme.of(context).colorScheme;

    final mostPlayed = [...stats]
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    final recentlyPlayed = stats.where((e) => e.lastPlayedAt != null).toList()
      ..sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));

    final totalListening = stats.fold(
      Duration.zero,
      (total, item) => total + item.listened,
    );

    final totalPlays = stats.fold(0, (total, item) => total + item.playCount);

    final totalCompleted = stats.fold(
      0,
      (total, item) => total + item.completionCount,
    );

    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(
        title: const Text('Listening Activity'),
        backgroundColor: col.surfaceBright,
        foregroundColor: col.onSurface,
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: con.load,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  // ===== SUMMARY =====
                  Text(
                    'Your listening stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  _header(totalListening, totalPlays, totalCompleted),

                  const SizedBox(height: 32),

                  // ===== MOST PLAYED =====
                  _SectionTitle(
                    icon: Icons.local_fire_department_outlined,
                    title: 'Most Played',
                  ),

                  const SizedBox(height: 12),

                  ...mostPlayed
                      .take(5)
                      .map(
                        (stat) => _SongStatTile(
                          rank: mostPlayed.indexOf(stat) + 1,
                          stat: stat,
                          trailing: '${stat.playCount} plays',
                          audio: con.filesMap[stat.trackId]!,
                          onTap: onClicked,
                        ),
                      ),

                  const SizedBox(height: 28),

                  // ===== RECENTLY PLAYED =====
                  _SectionTitle(icon: Icons.history, title: 'Recently Played'),

                  const SizedBox(height: 12),

                  ...recentlyPlayed
                      .take(10)
                      .map(
                        (stat) => _SongStatTile(
                          stat: stat,
                          trailing: _timeAgo(stat.lastPlayedAt!),
                          audio: con.filesMap[stat.trackId]!,
                          onTap: onClicked,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _header(Duration totalListening, int totalPlays, int totalCompleted) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.timer_outlined,
            value: _formatDuration(totalListening),
            label: 'Listening time',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.play_arrow_rounded,
            value: '$totalPlays',
            label: 'Total plays',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.done_all_rounded,
            value: '$totalCompleted',
            label: 'Completed',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _SongStatTile extends StatelessWidget {
  const _SongStatTile({
    required this.stat,
    required this.trailing,
    this.rank,
    required this.audio,
    required this.onTap,
  });

  final SongStats stat;
  final String trailing;
  final int? rank;
  final AudioFile audio;
  final void Function(AudioFile audio, SongStats stat) onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          onTap: () => onTap(audio, stat),
          contentPadding: .all(2),
          tileColor: color.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: .circular(15),
            side: BorderSide(color: color.primary.withValues(alpha: .15)),
          ),
          // Ranking
          leading: rank == null
              ? CircleAvatar(
                  backgroundColor: color.surfaceContainerHigh,
                  child: AudioThumbnail(
                    file: audio,
                    borderRadius: .circular(15),
                  ),
                  // const Icon(Icons.music_note),
                )
              : SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      '$rank',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

          // မင်းရဲ့ Track model နဲ့ ချိတ်ရမယ့်နေရာ
          title: Text(
            audio.autoTitle,
            maxLines: 2,
            style: TextStyle(
              fontSize: 14,
              fontWeight: .w600,
              color: color.onSurface,
            ),
          ),

          subtitle: Text('${stat.listened.formatTimeLable()} listened'),

          trailing: Text(
            trailing,
            style: TextStyle(color: color.onSurfaceVariant),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) return '${hours}h ${minutes}m';
  return '${duration.inMinutes}m';
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';

  return '${diff.inDays} days ago';
}
