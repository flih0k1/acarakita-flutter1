// =============================================================================
// | utils/app_colors.dart                                                   |
// =============================================================================
part of '../main.dart';

class AppColors {
  static const Color primary = Color(0xFF6A11CB);
  static const Color secondary = Color(0xFF2575FC);
  static const Color accent = Color(0xFFFFC107);
  
  static const Color background = Color(0xFFF5F5F7);
  static const Color inputBackground = Color(0xFFFFFFFF);
  
  static const Color primaryText = Color(0xFF1D1D1F);
  static const Color secondaryText = Color(0xFF8A8A8E);
  static const Color error = Color(0xFFB00020);

  static MaterialColor getPrimaryMaterialColor() {
    final int r = primary.red;
    final int g = primary.green;
    final int b = primary.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(r, g, b, .1),
      100: Color.fromRGBO(r, g, b, .2),
      200: Color.fromRGBO(r, g, b, .3),
      300: Color.fromRGBO(r, g, b, .4),
      400: Color.fromRGBO(r, g, b, .5),
      500: Color.fromRGBO(r, g, b, .6),
      600: Color.fromRGBO(r, g, b, .7),
      700: Color.fromRGBO(r, g, b, .8),
      800: Color.fromRGBO(r, g, b, .9),
      900: Color.fromRGBO(r, g, b, 1),
    };
    return MaterialColor(primary.value, shades);
  }
  
  static final MaterialColor primaryMaterialColor = getPrimaryMaterialColor();
}