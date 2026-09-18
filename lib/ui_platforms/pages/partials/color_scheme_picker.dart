import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:t_widgets/t_widgets.dart';

class ColorSchemePicker extends StatefulWidget {
  final Color pickerColor;
  final void Function(Color color)? onColorChanged;
  const ColorSchemePicker({
    super.key,
    required this.pickerColor,
    this.onColorChanged,
  });

  @override
  State<ColorSchemePicker> createState() => _ColorSchemePickerState();
}

class _ColorSchemePickerState extends State<ColorSchemePicker> {
  @override
  void initState() {
    value = widget.pickerColor;
    super.initState();
  }

  late Color value;
  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;

    return AlertDialog.adaptive(
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: widget.pickerColor,
          onColorChanged: (value) {
            this.value = value;
            widget.onColorChanged?.call(value);
          },
        ),
      ),

      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: col.surfaceContainerLow,
            foregroundColor: col.onSurface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: col.primary,
            foregroundColor: col.onPrimary,
          ),
          onPressed: () {
            Navigator.pop<Color>(context, value);
          },
          child: Text('Use Color'),
        ),
      ],
    );
  }
}
