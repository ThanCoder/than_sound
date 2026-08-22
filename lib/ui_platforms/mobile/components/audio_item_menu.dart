import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_content_theme_menu.dart';
import 'package:than_sound/ui_platforms/pages/art_cover_manager_page.dart';
import 'package:than_sound/ui_platforms/pages/equalizers/audio_eq_home_page.dart';
import 'package:than_sound/ui_platforms/pages/audio_medatata_editor_page.dart';
import 'package:than_sound/ui_platforms/components/audio_info_menu.dart';

class AudioItemMenu extends StatefulWidget {
  const AudioItemMenu({
    super.key,
    required this.file,
    this.showDeleteAction = false,
    this.showContentAnimation = false,
  });

  final AudioFile file;
  final bool showDeleteAction;
  final bool showContentAnimation;

  @override
  State<AudioItemMenu> createState() => _AudioItemMenuState();
}

class _AudioItemMenuState extends State<AudioItemMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final col = theme.colorScheme;

    void deleteConfirm() async {
      final confirmed = await showConfirmDialog(
        context,
        'Want To Delete?\n${widget.file.autoTitle}',
        confirmColor: col.error,
        confirmForegroundColor: col.onError,
        closeText: 'No!',
        confirmText: 'Delete Forever!',
      );
      if (!confirmed) return;
      ControllerManager.read<AllFileStateController>().deleteAudioFile(
        widget.file,
      );
    }

    return TScrollableColumn(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              _Cover(path: widget.file.cacheCoverPath),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.autoTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: col.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: col.outlineVariant.withValues(alpha: .5),
        ),

        const SizedBox(height: 6),

        // Audio Info
        _MenuTile(
          icon: Icons.audiotrack_rounded,
          title: 'Audio Info',
          subtitle: 'View audio metadata and file information',
          onTap: () {
            context.pop();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              builder: (context) {
                return AudioInfoMenu(file: widget.file);
              },
            );
          },
        ),
        // Audio edit
        _MenuTile(
          icon: Icons.edit_document,
          title: 'Audio Info Editor',
          subtitle: 'edit audio metadata and file information',
          onTap: () {
            context.pop();

            context.pushMaterialPageRoute(
              builder: (mainCtx) => AudioMedatataEditorPage(file: widget.file),
            );
          },
        ),

        // Art Cover
        _MenuTile(
          icon: Icons.art_track_rounded,
          title: 'Manage Art Cover',
          subtitle: 'Change or remove album artwork',
          onTap: () {
            context.pop();

            context.pushMaterialPageRoute(
              builder: (mainCtx) {
                return ArtCoverManagerPage(file: widget.file);
              },
            );
          },
        ),

        const SizedBox(height: 4),

        // Audio Equalizer
        _MenuTile(
          icon: Icons.equalizer,
          title: 'Audio Equalizer',
          subtitle: 'Change or Modify audio',
          onTap: () {
            context.pop();

            context.pushMaterialPageRoute(
              builder: (mainCtx) {
                return AudioEqHomePage();
              },
            );
          },
        ),

        const SizedBox(height: 4),

        // Content Animation
        if (widget.showContentAnimation)
          _MenuTile(
            icon: Icons.animation,
            title: 'Content Animation',
            subtitle: 'Change or remove Animation',
            onTap: () {
              context.pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                builder: (context) => AudioContentThemeMenu(),
              );
            },
          ),

        const SizedBox(height: 4),

        Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          color: col.outlineVariant.withValues(alpha: .5),
        ),

        const SizedBox(height: 4),

        // Delete
        if (widget.showDeleteAction)
          _MenuTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete',
            subtitle: 'Permanently delete this audio file',
            destructive: true,
            onTap: () {
              context.pop();
              deleteConfirm();
            },
          ),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foreground = destructive ? colorScheme.error : colorScheme.onSurface;

    final iconBackground = destructive
        ? colorScheme.errorContainer.withValues(alpha: .55)
        : colorScheme.secondaryContainer.withValues(alpha: .55);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: foreground),
            ),

            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: destructive
                            ? colorScheme.error.withValues(alpha: .7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: destructive
                  ? colorScheme.error.withValues(alpha: .6)
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String path;

  const _Cover({required this.path});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 58,
      height: 58,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: path.isEmpty
          ? Icon(Icons.music_note_rounded, color: colorScheme.onSurfaceVariant)
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.music_note_rounded,
                  color: colorScheme.onSurfaceVariant,
                );
              },
            ),
    );
  }
}
