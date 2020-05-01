import 'package:flutter/material.dart';

class AppColors {
  static const Color red = Colors.redAccent;
  static const Color white = const Color(0xFFFFFFFF);
  static const Color black = const Color(0xFF222222);
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
  static const String primary = 'DM Sans';
  static const String secondary = 'Audiowide';
}

class AppTextStyles {
  static const TextStyle regularText = const TextStyle(
      fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.white);
}
