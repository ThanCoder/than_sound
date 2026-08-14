part of 'waveform_seekbar.dart';

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.colorScheme,
  });

  final WaveformData waveform;
  final double progress;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final min = waveform.min;
    final max = waveform.max;
    final filled = waveform.filled;

    final bins = waveform.bins;

    final playedPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final unplayedPaint = Paint()
      ..color = colorScheme.surfaceContainerHighest
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;

    for (var i = 0; i < bins; i++) {
      if (filled[i] == 0) continue;

      final x = (i / bins) * size.width;

      final top = centerY - (max[i].abs() * centerY);
      final bottom = centerY + (min[i].abs() * centerY);

      final played = i / bins <= progress;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        played ? playedPaint : unplayedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.waveform != waveform || oldDelegate.progress != progress;
  }
}
