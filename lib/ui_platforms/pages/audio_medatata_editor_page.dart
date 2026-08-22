import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/extensions/date_time_ext.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/ui_platforms/components/dialog/confirm_alert_dialog.dart';
import 'package:than_sound/ui_platforms/components/dialog/error_alert_dialog.dart';
import 'package:than_sound/ui_platforms/components/forms/icon_form_input.dart';

class AudioMedatataEditorPage extends StatefulWidget {
  const AudioMedatataEditorPage({super.key, required this.file});
  final AudioFile file;

  @override
  State<AudioMedatataEditorPage> createState() =>
      _AudioMedatataEditorPageState();
}

class _AudioMedatataEditorPageState extends State<AudioMedatataEditorPage> {
  final titleController = TextEditingController();
  final albumController = TextEditingController();
  final artistController = TextEditingController();
  final genreController = TextEditingController();
  final yearController = TextEditingController();
  final descriptionController = TextEditingController();
  final commentController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.file.meta.title;
    albumController.text = widget.file.meta.album;
    artistController.text = widget.file.meta.artist;
    genreController.text = widget.file.meta.genre;
    yearController.text = widget.file.meta.year.toString();
    descriptionController.text = widget.file.meta.description;
    commentController.text = widget.file.meta.comment;
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    albumController.dispose();
    artistController.dispose();
    genreController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    commentController.dispose();
    super.dispose();
  }

  bool changed = false;

  ColorScheme get col => context.colorScheme;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (changed) {
          saveConfirm();
          return;
        }
        context.pop();
      },
      child: Scaffold(
        backgroundColor: col.surface,
        appBar: _appbar(context),
        body: _body(),
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: Text('Audio Editor'),
      backgroundColor: col.surfaceBright,
      foregroundColor: col.onSurfaceVariant,
      leading: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: col.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          if (changed) {
            saveConfirm();
            return;
          }
          context.pop();
        },
        icon: const Icon(Icons.arrow_back_ios_new),
      ),
      actions: [
        if (changed)
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: col.tertiaryContainer,
              foregroundColor: col.onTertiaryContainer,
            ),
            onPressed: saveMetadata,
            icon: Icon(Icons.save_as_outlined),
          ),
        SizedBox(width: 10),
      ],
    );
  }

  SingleChildScrollView _body() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          children: [
            _header(col),

            IconFormInput(
              title: 'Title',
              icon: Icon(Icons.title),
              controller: titleController,
              onChanged: ensureChanged,
            ),
            IconFormInput(
              title: 'Artist',
              icon: Icon(Icons.person_outline_outlined),
              controller: artistController,
              onChanged: ensureChanged,
            ),
            IconFormInput(
              title: 'Album',
              icon: Icon(Icons.title),
              controller: albumController,
              onChanged: ensureChanged,
            ),
            IconFormInput(
              title: 'Genres',
              icon: Icon(Icons.category_outlined),
              controller: genreController,
              onChanged: ensureChanged,
            ),
            _year(),
            IconFormInput(
              title: 'Comment',
              icon: Icon(Icons.comment),
              controller: descriptionController,
              onChanged: ensureChanged,
            ),
            IconFormInput(
              title: 'Description',
              icon: Icon(Icons.description),
              controller: commentController,
              onChanged: ensureChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _year() {
    return Container(
      padding: .symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(15),
      ),
      child: TextField(
        controller: yearController,
        readOnly: true,
        style: TextStyle(fontSize: 14, color: col.onSurface),
        decoration: InputDecoration(
          label: Text('Year'),
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          var current = DateTime.now();
          if (yearController.text.isNotEmpty) {
            final work = yearController.text.parseYyyyMMdd();
            if (work != null) {
              current = work;
            }
          }

          final newD = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            initialDate: current,
          );
          if (newD == null) return;
          yearController.text = newD.yyyyMMdd();
          if (!changed) {
            setState(() {
              changed = true;
            });
          }
        },
      ),
    );
  }

  Container _header(ColorScheme col) {
    return Container(
      padding: .all(8),
      decoration: BoxDecoration(
        borderRadius: .circular(15),
        color: col.surfaceContainer,
      ),
      child: Row(
        spacing: 8,
        children: [Icon(Icons.library_music_outlined), Text('Metadata Editor')],
      ),
    );
  }

  void ensureChanged(String value) {
    if (changed) return;
    setState(() {
      changed = true;
    });
  }

  void saveConfirm() async {
    final confirmed = await showConfirmDialog(
      context,
      barrierDismissible: false,
      'Want To Save Metadata?',
      confirmText: 'Yes',
      closeText: 'No',
      closeForegroundColor: col.onError,
      closeColor: col.error,
      confirmColor: col.primary,
      confirmForegroundColor: col.onPrimary,
    );
    if (!mounted) return;
    if (!confirmed) {
      context.pop();
      return;
    }
    saveMetadata();
  }

  void saveMetadata() async {
    try {
      final meta = ThanAudioTag.open(widget.file.path);
      meta.updateTag(
        title: titleController.text,
        album: albumController.text,
        artist: artistController.text,
        genre: genreController.text,
        comment: commentController.text,
        year: int.tryParse(yearController.text) ?? 0,
      );

      meta.dispose();
      // update state
      final con = ControllerManager.read<AllFileStateController>();
      await con.updateMetadata(widget.file);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    }
  }
}
