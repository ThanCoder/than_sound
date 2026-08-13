import 'package:flutter/material.dart';
import 'package:than_sound/core/controllers/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';

class AudioListHeader extends StatelessWidget {
  const AudioListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final con = ControllerManager.read<AllFileStateController>();
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.library_music_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              'Audio Library',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${con.files.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
