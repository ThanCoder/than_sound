import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_sound/ui_platforms/mobile/components/audio_thumbnail.dart';
import 'package:than_sound/core/controllers/interfaces/i_controller.dart';
import 'package:than_sound/core/controllers/player/player_state_controller.dart';
import 'package:than_sound/core/models/audio_file.dart';
import 'package:than_sound/router.dart';

class AudioFloatWidget extends StatelessWidget {
  const AudioFloatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    final con = ControllerManager.read<PlayerStateController>();
    return GestureDetector(
      onTap: () => goContent(context),
      onLongPress: () => showCloseDialog(context),
      onSecondaryTap: () => showCloseDialog(context),
      child: ClipRRect(
        child: BackdropFilter(
          filter: .blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: .all(8),
            decoration: BoxDecoration(
              color: col.surfaceContainerHighest.withValues(alpha: .45),
              borderRadius: .only(
                topLeft: .circular(15),
                topRight: .circular(15),
              ),
            ),
            child: ValueListenableBuilder(
              valueListenable: con.current,
              builder: (context, current, child) {
                if (current == null || !con.showFloatWidget.value) {
                  return SizedBox.shrink();
                }

                return StreamBuilder(
                  stream: con.stream.playing,
                  builder: (context, asyncSnapshot) {
                    return contentWidget(context, current, con);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget contentWidget(
    BuildContext ctx,
    AudioFile current,
    PlayerStateController con,
  ) {
    final col = ctx.colorScheme;
    return Row(
      spacing: 3,
      children: [
        SizedBox(width: 50, height: 50, child: AudioThumbnail(file: current)),
        progressWidget(ctx, con, current),
        IconButton(
          color: col.primary.withValues(alpha: .80),
          onPressed: () {
            con.prev();
          },
          icon: Icon(Icons.skip_previous),
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              .new(
                color: col.primary.withValues(alpha: .35),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              con.toggle();
            },
            icon: Icon(
              color: col.primary,
              con.state.playing ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ),
        IconButton(
          color: col.primary.withValues(alpha: .80),
          onPressed: () {
            con.next();
          },
          icon: Icon(Icons.skip_next),
        ),
      ],
    );
  }

  Expanded progressWidget(
    BuildContext ctx,
    PlayerStateController con,
    AudioFile current,
  ) {
    final col = ctx.colorScheme;
    return Expanded(
      child: StreamBuilder(
        stream: con.stream.position,
        builder: (context, asyncSnapshot) {
          return Column(
            spacing: 2,
            crossAxisAlignment: .start,
            children: [
              Text(
                current.autoTitle,
                maxLines: 1,
                overflow: .ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: .w400,
                  // color: Colors.white,
                ),
              ),
              LinearProgressIndicator(
                backgroundColor: col.primary.withValues(alpha: .45),
                color: col.onPrimary,
                value:
                    con.state.position.inSeconds / con.state.duration.inSeconds,
              ),
              Row(
                children: [
                  Text(
                    '${con.state.position.formatClockLabel()}/${con.state.duration.formatClockLabel()}',
                    style: TextStyle(fontSize: 11, fontWeight: .w400),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void showCloseDialog(BuildContext ctx) {
    final col = ctx.colorScheme;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        backgroundColor: col.surfaceContainerHighest,
        closeIconColor: col.inversePrimary,
        content: Row(
          children: [
            Text(
              'Want To Hide Floating Widget?',
              style: TextStyle(color: ctx.colorScheme.onSurface),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                ControllerManager.read<PlayerStateController>()
                        .showFloatWidget
                        .value =
                    false;
              },
              child: Text('Hide', style: TextStyle(color: col.inverseSurface)),
            ),
          ],
        ),
        showCloseIcon: true,
        // action: .new(
        //   label: 'Close',
        //   onPressed: () {
        //     ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
        //   },
        // ),
      ),
    );
  }
}
