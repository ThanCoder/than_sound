import 'dart:io';
import 'dart:typed_data';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_type_plus/file_type_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/core/utils/app_utils.dart';
import 'package:than_sound/ui_platforms/components/audio_thumbnail.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/components/dialog/error_alert_dialog.dart';
import 'package:than_sound/ui_platforms/components/dialog/snack_alert.dart';
import 'package:than_sound/ui_platforms/components/dialog/success_alert_dialog.dart';

class ArtCoverManagerPage extends StatefulWidget {
  final AudioFile file;
  const ArtCoverManagerPage({super.key, required this.file});

  @override
  State<ArtCoverManagerPage> createState() => _ArtCoverManagerState();
}

class _ArtCoverManagerState extends State<ArtCoverManagerPage> {
  late File coverFile;

  bool isLoading = false;

  @override
  void initState() {
    coverFile = File(widget.file.cacheCoverPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    return DropTarget(
      enable: true,
      onDragDone: onDrop,
      child: Scaffold(
        backgroundColor: col.surface,
        appBar: AppBar(
          backgroundColor: col.surfaceContainer,
          foregroundColor: col.onSurface,
          title: const Text(
            'Art Cover Manager',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: FutureBuilder(
              future: TagPictureWorker.instance.getImageBytes(widget.file.path),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final exists = data != null && data.isOk;
                Uint8List? bytes;
                if (exists) {
                  bytes = data.unwrap();
                }
                return Column(
                  children: [
                    _title(),

                    const SizedBox(height: 24),
                    coverImage(),

                    const SizedBox(height: 24),

                    _info(),

                    const SizedBox(height: 28),

                    buttonWidget(exists, bytes),
                  ],
                );
              },
            ),
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
      onTap: isLoading ? null : writeImage,
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
          child: AudioThumbnail(file: widget.file),
        ),
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

  Widget buttonWidget(bool exists, Uint8List? bytes) {
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
            onPressed: isLoading ? null : () => saveImage(bytes),
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

  void writeImage() async {
    try {
      setState(() {
        isLoading = true;
      });

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

      final t = TTag();
      final tRes = t.openFile(widget.file.path);

      if (tRes.isErr) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showErrorDialog(context, tRes.unwrapError().toString());
        return;
      }

      final picRes = t.writePictureData(
        .new(
          description: '',
          mimeType: 'image/jpeg',
          pictureType: 'cover',
          data: imageData,
        ),
      );
      if (picRes.isErr) {
        t.close();
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showErrorDialog(context, picRes.unwrapError());
        return;
      }
      t.close();
      AppUtils.clearImageCache();
      await Future.delayed(const Duration(seconds: 1));

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

      showErrorDialog(context, e.toString());
    }
  }

  void saveImage(Uint8List? bytes) async {
    try {
      if (bytes == null) {
        showErrorDialog(context, 'Uint8List? bytes is null!');
        return;
      }
      final downloadPath = await AppUtils.getPlatformDownloadPath();

      if (downloadPath == null) {
        if (!mounted) return;

        showErrorDialog(context, 'AppUtils.getPlatformDownloadPath error');
        return;
      }

      final outpath = downloadPath.join(coverFile.name);

      await File(outpath).writeAsBytes(bytes!);

      if (!mounted) return;

      showSuccessDialog(context, 'Saved: $outpath');
    } catch (e) {
      if (!mounted) return;

      showTMessageDialogError(context, e.toString());
    }
  }

  void delete() async {
    final confirmed = await showConfirmDialog(
      context,
      'Want To Delete?',
      confirmText: 'Delete!',
      closeText: 'No!',
      confirmColor: context.colorScheme.error,
      confirmForegroundColor: context.colorScheme.onError,
    );
    if (!confirmed) return;
    try {
      setState(() {
        isLoading = true;
      });
      final t = TTag();
      final tRes = t.openFile(widget.file.path);

      if (tRes.isErr) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showErrorDialog(context, tRes.unwrapError().toString());
        return;
      }
      final picRes = t.removePicture();
      if (picRes.isErr) {
        t.close();
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        showErrorDialog(context, tRes.unwrapError().toString());
        return;
      }

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

  void onDrop(DropDoneDetails details) async {
    try {
      final files = details.files;
      if (files.isEmpty) return;
      final type = FileType.fromPath(files.first.path);
      if (type != .image) {
        showErrorDialog(context, 'Image File Required!\n`${type.value}`');
        return;
      }

      setState(() {
        isLoading = true;
      });

      bool oldImage = coverFile.existsSync();
      final imageData = await files.first.readAsBytes();

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

      showSnackbar(context, 'Changed Image!');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showErrorDialog(context, e.toString());
    }
  }
}
