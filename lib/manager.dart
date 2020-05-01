import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';

class AppManager {
  static void setup() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
            Brightness.dark // Dark == white status bar -- for IOS.
        ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}

/// Game manager used to abstract Game Initial Setup.
class GameManager {
  static Future<void> setup() async {
    Flame.audio.disableLog();
    Util flameUtil = Util();
    await flameUtil.setOrientation(DeviceOrientation.portraitUp);
    await Flame.audio.loadAll(<String>[
      'pop.mp3',
    ]);
  }
}
