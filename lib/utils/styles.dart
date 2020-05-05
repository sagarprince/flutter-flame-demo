import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Colors.redAccent;
  static const Color white = const Color(0xFFFFFFFF);
  static const Color black = const Color(0xFF222222);
  static const Color cardinal = const Color(0xFFBC154C);
  static const Color razzmatazz = const Color(0xFFF01C62);
  static const Color blueGrey = Colors.blueGrey;
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color getColorByName(player) {
    switch (player) {
      case 'blue':
        return Colors.blue;
        break;
      case 'yellow':
        return Colors.yellow;
        break;
      case 'green':
        return Colors.green;
        break;
      case 'orange':
        return Colors.orange;
        break;
      default:
        return Colors.red;
    }
  }
}

class AppFonts {
  static const String primary = 'Roboto Slab';
  static const String secondary = 'Audiowide';
  static const String third = 'Bungee Inline';
}

class AppTextStyles {
  static const TextStyle regularText = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.white);
  static const TextStyle landingHeadingText = const TextStyle(
      fontFamily: AppFonts.third, fontSize: 42.0, color: AppColors.cardinal);
}
