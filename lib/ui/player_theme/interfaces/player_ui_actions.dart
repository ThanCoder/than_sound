// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

abstract class PlayerUiActions {
  final VoidCallback playPause;
  final VoidCallback next;
  final VoidCallback previous;
  final ValueChanged<Duration> seek;
  const PlayerUiActions({
    required this.playPause,
    required this.next,
    required this.previous,
    required this.seek,
  });
}
