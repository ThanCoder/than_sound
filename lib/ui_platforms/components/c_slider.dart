import 'package:flutter/material.dart';

class CSlider extends StatefulWidget {
  const CSlider({
    super.key,
    this.min = 0.0,
    required this.max,
    required this.value,
    this.onChangeEnd,
    this.onChanged,
    this.secondaryTrackValue,
  });

  final double min;
  final double max;
  final double value;
  final double? secondaryTrackValue;
  final void Function(double value)? onChanged;
  final void Function(double value)? onChangeEnd;

  @override
  State<CSlider> createState() => _CSliderState();
}

class _CSliderState extends State<CSlider> {
  @override
  void initState() {
    val = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (hold) return;
    if (oldWidget.value != widget.value) {
      setState(() {
        val = widget.value;
      });
    }
  }

  late double val;
  bool hold = false;

  @override
  Widget build(BuildContext context) {
    return Slider.adaptive(
      min: widget.min,
      max: widget.max,
      value: val,
      secondaryTrackValue: widget.secondaryTrackValue,
      allowedInteraction: .slideOnly,
      onChanged: (value) {
        widget.onChanged?.call(val);
        setState(() {
          val = value;
        });
      },
      onChangeStart: (value) {
        hold = true;
      },
      onChangeEnd: (value) {
        hold = false;
        widget.onChangeEnd?.call(value);
      },
    );
  }
}
