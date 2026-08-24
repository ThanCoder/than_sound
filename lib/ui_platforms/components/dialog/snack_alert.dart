import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message) {
  final col = Theme.of(context).colorScheme;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: col.onSurface)),
      showCloseIcon: true,
    ),
  );
}
