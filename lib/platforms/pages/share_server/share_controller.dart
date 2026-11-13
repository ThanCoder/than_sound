import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:t_server/t_server.dart';
import 'package:than_sound/core/controllers/all_audio/all_file_state_controller.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/utils/p_utils.dart';
import 'package:than_sound/core/utils/platform_util.dart';

class ShareController {
  static final ShareController instance = ShareController._();
  ShareController._();
  factory ShareController() => instance;

  final server = TServer();
  final _router = THttpRouter();
  AllFileStateController get _allCon =>
      ControllerManager.read<AllFileStateController>();
  int port = 5556;

  Future<void> init() async {
    _router.clearRoutes();
    _router.get('/', (ctx) async {
      await ctx.response.json({
        'message': 'Than Sound Api Server',
        '/api': 'audio file list',
        '/api/thumbnail/:id': 'cover data',
        '/api/audio/:id': 'book data && download data',
        '/api/audio/path?path=[path]': 'book data && download data',
      });
    });
    _router.get('/api', (ctx) async {
      final json = _allCon.files.map((e) => e.toMap()).toList();
      final jsonString = JsonEncoder.withIndent(' ').convert(json);
      await ctx.response.jsonString(jsonString);
    });
    _router.get('/api/thumbnail/:id', (ctx) async {
      final id = ctx.params['id'];
      if (id == null) {
        await ctx.response.json({'message': 'id not found!', 'success': false});
        return;
      }
      final file = _allCon.getById(id);
      if (file == null) {
        await ctx.response.json({
          'message': 'book not found!',
          'success': false,
        });
        return;
      }
      final coverFile = File(file.cacheCoverPath);
      if (!coverFile.existsSync()) {
        await PlatformUtil.genThumbnail(file);
      }
      if (!coverFile.existsSync()) {
        try {
          final thumb = File(PUtils.instance.getCachePath('no-image.png'));
          if (!thumb.existsSync()) {
            final data = await rootBundle.load(
              'assets/logo/plain-empty-soft-pastel-gradient-background--smoot.png-1788456930156.png',
            );
            await thumb.writeAsBytes(data.buffer.asUint8List());
          }
          await ctx.response.download(thumb);
          return;
        } catch (e) {
          debugPrint('[ShareController:`_router.get(/api/thumbnail/:id,`]: $e');
        }
      }

      await ctx.response.download(coverFile);
    });

    _router.get('/api/audio/:id', (ctx) async {
      final id = ctx.params['id'];
      if (id == null) {
        await ctx.response.json({'message': 'id not found!', 'success': false});
        return;
      }
      final audio = _allCon.getById(id);
      if (audio == null) {
        await ctx.response.json({
          'message': 'audio not found!',
          'success': false,
        });
        return;
      }
      final audioFile = File(audio.path);

      await ctx.response.download(audioFile);
    });

    _router.get('/api/audio/path', (ctx) async {
      final path = ctx.query['path'];
      if (path == null) {
        await ctx.response.json({'message': 'id not found!', 'success': false});
        return;
      }
      final audio = _allCon.getByPath(path);
      if (audio == null) {
        await ctx.response.json({
          'message': 'audio not found!',
          'success': false,
        });
        return;
      }
      final audioFile = File(audio.path);

      await ctx.response.download(audioFile);
    });
    server.setRouter(_router);
  }

  Future<void> start() async {
    await server.start(address: '0.0.0.0', port: port);
  }
}
