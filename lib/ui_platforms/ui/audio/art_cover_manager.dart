import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/app_utils.dart';

class ArtCoverManager extends StatefulWidget {
  final AudioFile file;
  const ArtCoverManager({super.key, required this.file});

  @override
  State<ArtCoverManager> createState() => _ArtCoverManagerState();
}

class _ArtCoverManagerState extends State<ArtCoverManager> {
  late File coverFile;

  bool isLoading = false;

  @override
  void initState() {
    coverFile = File(widget.file.cacheCoverPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Art Cover Manager',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              _title(),

              const SizedBox(height: 24),

              coverImage(),

              const SizedBox(height: 24),

              _info(),

              const SizedBox(height: 28),

              buttonWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          widget.file.autoTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),

        if (widget.file.meta.artist.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            widget.file.meta.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget coverImage() {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : chooseImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 260,
        height: 260,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .35),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: .12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: isLoading
              ? _loadingCover()
              : Image.file(
                  coverFile,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _emptyCover();
                  },
                ),
        ),
      ),
    );
  }

  Widget _loadingCover() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _emptyCover() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 10),

          Text(
            'No Art Cover',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Tap to choose an image',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _info() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 20, color: colors.primary),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Tap the artwork to choose a new cover image.',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget get buttonWidget {
    final exists = coverFile.existsSync();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (exists)
          _actionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            color: Theme.of(context).colorScheme.error,
            onPressed: isLoading ? null : delete,
          ),

        if (exists)
          _actionButton(
            icon: Icons.file_download_outlined,
            label: 'Save',
            color: Theme.of(context).colorScheme.primary,
            onPressed: isLoading ? null : saveImage,
          ),

        _actionButton(
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          color: Theme.of(context).colorScheme.secondary,
          onPressed: isLoading ? null : refreshImage,
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(110, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }

  // ----------------------------
  // Logic
  // ----------------------------

  void chooseImage() async {
    try {
      setState(() {
        isLoading = true;
      });

      bool oldImage = coverFile.existsSync();

      final picker = ImagePicker();
      final res = await picker.pickImage(source: ImageSource.gallery);

      if (res == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
        return;
      }

      final imageData = await res.readAsBytes();

      final tag = ThanAudioTag.open(widget.file.path);
      tag.writeCover(imageData);
      tag.close();

      await coverFile.writeAsBytes(imageData);

      if (oldImage) {
        AppUtils.clearImageCache();
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showTSnackBar(context, 'Changed Image!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showTMessageDialogError(context, e.toString());
    }
  }

  void saveImage() async {
    try {
      final downloadPath = await AppUtils.getPlatformDownloadPath();

      if (downloadPath == null) {
        if (!mounted) return;

        showTMessageDialogError(
          context,
          'AppUtils.getPlatformDownloadPath error',
        );
        return;
      }

      final outpath = downloadPath.join(coverFile.name);

      await coverFile.copy(outpath);

      if (!mounted) return;

      showTMessageDialog(context, 'Saved: $outpath');
    } catch (e) {
      if (!mounted) return;

      showTMessageDialogError(context, e.toString());
    }
  }

  void delete() {
    showTConfirmDialog(
      context,
      contentText: 'Want To Delete?',
      cancelText: 'No!',
      submitText: 'Delete Forever!',
      onSubmit: () async {
        try {
          setState(() {
            isLoading = true;
          });

          final tag = ThanAudioTag.open(widget.file.path);

          tag.removeCover(save: true);
          tag.close();

          await coverFile.deleteSafe();

          AppUtils.clearImageCache();

          await Future.delayed(const Duration(seconds: 1));

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          showTMessageDialogError(context, e.toString());
        }
      },
    );
  }

  void refreshImage() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }
}
