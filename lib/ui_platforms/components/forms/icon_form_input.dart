import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';

class IconFormInput extends StatelessWidget {
  const IconFormInput({
    super.key,
    required this.controller,
    this.errorText,
    required this.icon,
    required this.title,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  // final ColorScheme col;
  final TextEditingController controller;
  final String? errorText;
  final Icon icon;
  final String title;
  final void Function(String value)? onChanged;
  final TextInputType? keyboardType;

  ///FilteringTextInputFormatter
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final col = context.colorScheme;
    return Container(
      padding: .symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: col.surfaceContainer,
        borderRadius: .circular(15),
      ),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 4,
        children: [
          TextField(
            // maxLines: 1,
            style: TextStyle(fontSize: 14, color: col.onSurface),
            decoration: InputDecoration(
              label: Text(title),
              border: OutlineInputBorder(),
              errorText: errorText,
              suffixIcon: icon,
            ),
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }
}
