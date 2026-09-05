import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player_state/player_state_controller.dart';
import 'package:than_sound/core/utils/tem_storage.dart';
import 'package:than_sound/ui_platforms/components/sleep_timer/sleep_timer.dart';

class SleepTimerPage extends StatefulWidget {
  const SleepTimerPage({super.key});

  @override
  State<SleepTimerPage> createState() => _SleepTimerPageState();
}

class _SleepTimerPageState extends State<SleepTimerPage> {
  final cf = TemStorage.store;

  final con = ControllerManager.read<PlayerStateController>();

  SleepTimer get sleepTimer => con.sleepTimer;

  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();

    // Remaining time ကို UI မှာ update လုပ်ဖို့
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer(Duration duration) {
    sleepTimer.start(duration, () async {
      await con.player.pause();

      if (mounted) {
        setState(() {});
      }
    });

    setState(() {});
  }

  void _endOfSong() {
    sleepTimer.endOfSong();
    setState(() {});
  }

  void _cancelTimer() {
    sleepTimer.cancel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    final remaining = sleepTimer.remaining;
    final isActive = sleepTimer.mode != SleepTimerMode.off;
    final isEndOfSong = sleepTimer.mode == SleepTimerMode.endOfSong;

    return Scaffold(
      backgroundColor: col.surface,
      appBar: AppBar(
        title: const Text('Sleep Timer'),
        backgroundColor: col.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Current timer
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: col.surfaceContainer,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Icon(Icons.nightlight_round, size: 42, color: col.primary),

                const SizedBox(height: 20),

                Text(
                  isEndOfSong
                      ? 'End of song'
                      : remaining != null
                      ? _formatDuration(remaining)
                      : 'Off',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isEndOfSong
                      ? 'Music will stop after this song'
                      : isActive
                      ? 'Music will stop automatically'
                      : 'Sleep timer is not active',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: col.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

                if (isActive) ...[
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: _cancelTimer,
                      child: const Text('Cancel timer'),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Quick Timer',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TimerChip(
                label: '15 min',
                onPressed: () {
                  _startTimer(const Duration(minutes: 15));
                },
              ),
              _TimerChip(
                label: '30 min',
                onPressed: () {
                  _startTimer(const Duration(minutes: 30));
                },
              ),
              _TimerChip(
                label: '45 min',
                onPressed: () {
                  _startTimer(const Duration(minutes: 45));
                },
              ),
              _TimerChip(
                label: '60 min',
                onPressed: () {
                  _startTimer(const Duration(minutes: 60));
                },
              ),
              _TimerChip(
                label: '90 min',
                onPressed: () {
                  _startTimer(const Duration(minutes: 90));
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(
            'Stop Playback',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(Icons.music_note_rounded, color: col.primary),
              title: const Text('End of current song'),
              subtitle: const Text(
                'Stop playback when the current song finishes',
              ),
              trailing: Switch(
                value: isEndOfSong,
                onChanged: (value) {
                  if (value) {
                    _endOfSong();
                  } else {
                    _cancelTimer();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onPressed);
  }
}
