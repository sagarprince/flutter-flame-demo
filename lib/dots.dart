import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter_flame_demo/box_game.dart';
import 'package:flame/time.dart';
import 'package:flutter_flame_demo/game_provider.dart';

class Dots extends PositionComponent with HasGameRef<BoxGame> {
  double dx = 0;
  double dy = 0;
  Timer interval;
  AtomModel atomModel;

  Dots(
      {double x = 0,
      double y = 0,
      double width = 60,
      double height = 60,
      AtomModel atomModel}) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.dx = (x + (width / 2));
    this.dy = (y + height / 2);
    this.atomModel = atomModel;

    interval = Timer(4, repeat: true, callback: () {});
    interval.start();
  }

  @override
  void render(Canvas canvas) {
    double dx = (x + (width / 2));
    double dy = (y + height / 2);
    atomModel.electrons.sort((a, b) => b - a);
    if (atomModel.electrons.length > 0) {
      atomModel.electrons.forEach((index) {
        if (index == 1) {
          _drawDot(canvas, dx, dy);
        }
        if (index == 2) {
          _drawDot(canvas, dx - 12, dy - 12);
        }
        if (index == 3) {
          _drawDot(canvas, dx + 12, dy - 12);
        }
        if (index == 4) {
          _drawDot(canvas, dx, dy + 14);
        }
      });
    }
  }

  Color get playerColor {
    if (atomModel.player == 'blue') {
      return Colors.blue;
    } else if (atomModel.player == 'green') {
      return Colors.green;
    } else if (atomModel.player == 'yellow') {
      return Colors.yellow;
    } else if (atomModel.player == 'orange') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _drawDot(Canvas canvas, double dx, double dy) {
    Rect circleRect = new Rect.fromCircle(
      center: new Offset(dx, dy),
      radius: 10.0,
    );

    var _gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(0.1, 1.0),
      colors: [const Color(0xFF888888), playerColor], // whitish to gray
      tileMode: TileMode.clamp,
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = new Paint()
      ..shader = _gradient.createShader(circleRect);
    canvas.drawCircle(Offset(dx, dy), 10, paint);
  }

  @override
  void update(double t) {
    interval.update(t);
  }

  @override
  void onMount() {
    super.onMount();
  }
}
