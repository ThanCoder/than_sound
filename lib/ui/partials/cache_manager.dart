import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_sound/core/utils/p_utils.dart';

class CacheManagerListTile extends StatefulWidget {
  final String cacheDirPath;
  const CacheManagerListTile({super.key, required this.cacheDirPath});

  @override
  State<CacheManagerListTile> createState() => _CacheManagerListTileState();
}

class _CacheManagerListTileState extends State<CacheManagerListTile> {
  @override
  void didUpdateWidget(covariant CacheManagerListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  bool needToClean = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PUtils.instance.getFolderInfo(Directory(widget.cacheDirPath)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return Card(
            child: ListTile(
              title: Text('စစ်ဆေးနေပါတယ်.....', style: TextStyle(fontSize: 13)),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null) return SizedBox.shrink();
        if (data.$1 == 0) return SizedBox.shrink();

        needToClean = data.$2 > 0;

        return buttonWidget(data);
      },
    );
  }

  ListTile buttonWidget((int, int) data) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        Icons.cleaning_services_outlined,
        color: colorScheme.primary,
      ),
      title: const Text(
        'Clear cache',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${data.$1} files • ${data.$2.fileSizeLabel()}',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.delete_outline_rounded),
      onTap: _showCaleanConfirm,
    );
  }

  void _showCaleanConfirm() {
    showClearCacheDialog(
      context: context,
      onClear: () async {
        await PUtils.instance.deleteFolder(Directory(widget.cacheDirPath));
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  Future<void> showClearCacheDialog({
    required BuildContext context,
    required Future<void> Function() onClear,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.cleaning_services_outlined,
            size: 32,
            color: colorScheme.primary,
          ),
          title: const Text('Clear cache?', textAlign: TextAlign.center),
          content: const Text(
            'Cached files will be removed.\n'
            'Your original files will not be affected.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await onClear();
              },
              child: const Text('Clear Cache'),
            ),
          ],
        );
      },
    );
  }
}

/*
 contentText: 'သိမ်းထားတဲ့ cache ဖိုင်တွေကို ရှင်းမှာသေချာပါသလား?\n\n'
      'မူရင်းဖိုင်တွေကို ထိခိုက်မှာမဟုတ်ပါ။',
  submitText: 'Clear Cache',
 */
