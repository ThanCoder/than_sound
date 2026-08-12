import 'package:flutter/material.dart';

final bottomNavigationBarThemeDataLightTheme = ThemeData(
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    // backgroundColor: Color.fromARGB(170, 255, 255, 255),
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.black54,
  ),
);

final bottomNavigationBarThemeDataDarkTheme = ThemeData(
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    // backgroundColor: Color.fromARGB(170, 0, 0, 0),
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.white70,
  ),
);
