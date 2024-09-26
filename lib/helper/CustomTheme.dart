import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme extends ChangeNotifier {
  bool isDark = false;

  final ThemeData _lightTheme = ThemeData(
    primaryColor: Colors.purple,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      buttonColor: Colors.purple.shade500,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primaryColor: Colors.grey.shade500,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    textTheme: ThemeData.dark().textTheme,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      buttonColor: Colors.purple.shade500,
    ),
  );

  ThemeData get curTheme => isDark ? _darkTheme : _lightTheme;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}
