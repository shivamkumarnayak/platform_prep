import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GalleryThemeData {
  static Color successColor = const Color(0xff70AD47);
  static Color inActiveColor = const Color(0xff9A9B9B);
  static Color fieldInActiveColor = const Color.fromARGB(255, 235, 234, 234);
  static Color labelColor = const Color(0xff595C5F);
  static Color bodyBackgroundColor = const Color(0Xfff8fafb);
  static Color lightOrangeColor = const Color(0xffFFFBDE); // Card color
  static Color primaryFontColor = const Color(0xff2D3436); // Title color
  static Color subtitleColor = const Color(0xff636E72); // Subtitle color
  static Color fontGreyColor = const Color(0xffE6E5E5); // This is used for font
  static Color fontColor = Colors.black; // Default font color
  static Color blackColor = Colors.black;
  static Color whiteColor = Colors.white;
  static Color redColor = const Color(0xffB91C1C);
  static Color greyColor = Colors.grey;
  static Color greyShadedColor = Colors.grey.shade600;
  static Color inputFieldLabelColor = const Color(0xff1A1A1A);
  static Color lightGreyColor = const Color(0xffe8e8e8);
  static Color lightPrimaryColor = const Color(0xFFDCE6F7);
  static Color lightSecondaryColor = const Color(0xFFFEF3D9);
  static Color primaryColorSecondVersion = const Color(0xFFD3E0F5);

  static const ColorScheme colorScheme = ColorScheme(
    primary: Color(0xFF1E4FA3),
    onPrimary: Colors.white,
    secondary: Color(0xFFF59E0B),
    onSecondary: Color(0xFF1A1A1A),
    primaryContainer: Color(0xFFEAF0FA),
    secondaryContainer: Color(0xFFFEF3D9),
    tertiary: Color(0xFFE8EEF9),
    surface: Color(0xFFFAFBFB),
    onSurface: Color(0xFF1F2937),
    error: Color(0xFFB91C1C),
    onError: Colors.white,
    brightness: Brightness.light,
  );

  ThemeData customTheme = ThemeData(
    primaryColor: GalleryThemeData.colorScheme.primary,
    primarySwatch: Colors.green,
    appBarTheme: AppBarTheme(
      foregroundColor: GalleryThemeData.fontColor,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
    ),
    textTheme: GoogleFonts.montserratTextTheme(GalleryThemeData.textTheme),
    fontFamily: GoogleFonts.montserrat().fontFamily,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(color: colorScheme.primary))),
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return GalleryThemeData.inActiveColor;
          } else if (states.contains(WidgetState.hovered)) {
            return GalleryThemeData.inActiveColor;
          } else {
            return colorScheme.primary; // Your primary color
          }
        },
      ),
      foregroundColor: WidgetStateProperty.all(GalleryThemeData.fontColor),
    )),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return GalleryThemeData.inActiveColor;
            } else if (states.contains(WidgetState.hovered)) {
              return GalleryThemeData.inActiveColor;
            } else {
              return colorScheme.primary; // Your primary color
            }
          },
        ),
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    side: BorderSide(color: colorScheme.primary))),
            side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return BorderSide(color: colorScheme.primary, width: 2);
              } else {
                return BorderSide(color: colorScheme.primary, width: 2);
              }
            }),
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return colorScheme.primary;
                } else if (states.contains(WidgetState.hovered)) {
                  return colorScheme.primary;
                } else {
                  return colorScheme.surface; // Your primary color
                }
              },
            ),
            foregroundColor:
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return GalleryThemeData.fontColor;
              } else {
                return colorScheme.primary;
              }
            }))),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: GalleryThemeData.whiteColor,
      backgroundColor: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: GalleryThemeData.fontColor),
      focusColor: colorScheme.primary,
      hoverColor: colorScheme.primary,
      border: OutlineInputBorder(
          borderSide: BorderSide(color: GalleryThemeData.fontColor, width: 1),
          borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: GalleryThemeData.fontColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: GalleryThemeData.fontColor,
        ),
      ),
    ),
    focusColor: colorScheme.primary,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    bottomSheetTheme:
        BottomSheetThemeData(backgroundColor: colorScheme.surface),
    dialogTheme: DialogThemeData(backgroundColor: colorScheme.surface),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.surface)),
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: colorScheme.primary),
  );
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    labelMedium: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    labelSmall: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    bodyLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
        color: Colors.white),
    bodyMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: Colors.black),
    bodySmall: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        color: Colors.black),
  );
}
