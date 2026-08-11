import 'package:flutter/material.dart';

class ListGpsButton extends StatelessWidget {
  final void Function()? onClicked;
  const ListGpsButton({super.key, required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      isExtended: false,
      onPressed: onClicked,
      child: Icon(Icons.gps_fixed),
    );
  }
}
