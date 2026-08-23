// import 'package:flutter/material.dart';
// import 'package:than_sound/ui_platforms/pages/music_tracker/song_stats.dart';

// class SongStatsPage extends StatelessWidget {
//   const SongStatsPage({super.key, required this.stats});

//   final SongStats stats;

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Song Statistics')),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           // 🎵 Header
//           Card(
//             elevation: 0,
//             color: color.primaryContainer,
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.music_note_rounded,
//                     size: 64,
//                     color: color.onPrimaryContainer,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Song Statistics',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // 📊 Stats
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.timer_outlined,
//                   label: 'Listening Time',
//                   value: _formatDuration(stats.listened),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.play_circle_outline,
//                   label: 'Times Played',
//                   value: '${stats.playCount}',
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.check_circle_outline,
//                   label: 'Completed',
//                   value: '${stats.completionCount}',
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StatCard(
//                   icon: Icons.history,
//                   label: 'Last Played',
//                   value: _lastPlayed(stats.lastPlayedAt),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 28),

//           // 📈 Details
//           Text(
//             'Listening Details',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),

//           const SizedBox(height: 8),

//           Card(
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.music_note_outlined),
//                   title: const Text('Track ID'),
//                   trailing: Text(stats.trackId),
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   leading: const Icon(Icons.repeat),
//                   title: const Text('Completion rate'),
//                   trailing: Text(
//                     stats.playCount == 0
//                         ? '—'
//                         : '${((stats.completionCount / stats.playCount) * 100).toStringAsFixed(0)}%',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   final IconData icon;
//   final String label;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.surfaceContainer,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color.primary),
//           const SizedBox(height: 16),
//           Text(
//             value,
//             style: Theme.of(
//               context,
//             ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: color.onSurfaceVariant)),
//         ],
//       ),
//     );
//   }
// }

// String _formatDuration(Duration duration) {
//   if (duration.inHours > 0) {
//     return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
//   }

//   if (duration.inMinutes > 0) {
//     return '${duration.inMinutes}m';
//   }

//   return '${duration.inSeconds}s';
// }

// String _lastPlayed(DateTime? date) {
//   if (date == null) return 'Never';

//   final diff = DateTime.now().difference(date);

//   if (diff.inMinutes < 1) return 'Just now';
//   if (diff.inHours < 1) return '${diff.inMinutes}m ago';
//   if (diff.inDays < 1) return '${diff.inHours}h ago';
//   if (diff.inDays == 1) return 'Yesterday';

//   return '${diff.inDays} days ago';
// }
