import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'dart:ui';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_flame_demo/box_game.dart';
import 'package:flutter_flame_demo/game_provider.dart';
import 'package:flutter_flame_demo/utilities.dart';

class Dots extends PositionComponent with HasGameRef<BoxGame> {
  int rows = gameProvider.rows;
  int cols = gameProvider.cols;
  double dx = 0;
  double dy = 0;
  double middleDx = 0;
  double middleDy = 0;
  double leftDx = 0;
  double leftDy = 0;
  double rightDx = 0;
  double rightDy = 0;
  double bottomDx = 0;
  double bottomDy = 0;

  AtomModel atomModel;

  double _speed = 120.0;

  Dots(
      {double x = 0,
      double y = 0,
      double width = 0,
      double height = 0,
      AtomModel atomModel}) {
    this.atomModel = atomModel;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.dx = (x + width / 2);
    this.dy = (y + height / 2);
    setDotsPositions();
  }

  void setDotsPositions() {
    int i = atomModel.i;
    int j = atomModel.j;

    if ((i == 0 && j == 0) ||
        (i == (rows - 1) && j == 0) ||
        (i == (rows - 1) && j == (cols - 1))) {
      // Top-Left Corner || Top-Right Corner || Bottom-Right Corner
      this.middleDx = dx;
      this.middleDy = dy;
    }

    if (i == 0 && j == 0) {
      // Top-Left Corner
      this.leftDx = dx + 12;
      this.leftDy = dy - 12;
    } else if (i == (rows - 1) && j == 0) {
      // Top-Right Corner
      this.leftDx = dx - 12;
      this.leftDy = dy - 12;
    } else if (i == (rows - 1) && j == (cols - 1)) {
      // Bottom-Right Corner
      this.leftDx = dx + 12;
      this.leftDy = dy - 12;
    } else if ((i > 0 && i < (rows - 1)) && j == 0) {
      // Left Side
      this.middleDx = dx + 5;
      this.middleDy = dy;
      this.leftDx = dx - 8;
      this.leftDy = dy - 12;
      this.rightDx = dx - 8;
      this.rightDy = dy + 12;
    } else if ((i > 0 && i < (rows - 1)) && j == (cols - 1)) {
      // Right Side
      this.middleDx = dx - 5;
      this.middleDy = dy;
      this.leftDx = dx + 8;
      this.leftDy = dy - 12;
      this.rightDx = dx + 8;
      this.rightDy = dy + 12;
    } else if ((i == (rows - 1)) && (j > 0 && j < (cols - 1))) {
      // Bottom Side
      this.middleDx = dx;
      this.middleDy = dy - 8;
      this.leftDx = dx - 12;
      this.leftDy = dy + 6;
      this.rightDx = dx + 12;
      this.rightDy = dy + 6;
    } else {
      this.middleDx = dx;
      this.middleDy = dy;
      this.leftDx = dx - 12;
      this.leftDy = dy - 12;
      this.rightDx = dx + 12;
      this.rightDy = dy - 12;
      this.bottomDx = dx;
      this.bottomDy = dy + 14;
    }
  }

  void explodeDotsPositions(double t) {
    int i = atomModel.i;
    int j = atomModel.j;

    if (i == 0 && j == 0) {
      // Top-Left Corner
      middleDy = middleDy + (t * _speed);
      leftDx = leftDx + (t * _speed);
    } else if (i == 0 && j == (cols - 1)) {
      // Top-Right Corner
      middleDy = middleDy + (t * _speed);
      leftDx = leftDx - (t * _speed);
    } else if (i == (rows - 1) && j == 0) {
      // Bottom-Left Corner
      middleDx = middleDx + (t * _speed);
      leftDy = leftDy - (t * _speed);
    } else if (i == (rows - 1) && j == (cols - 1)) {
      // Bottom-Right Corner
      middleDx = middleDx - (t * _speed);
      leftDy = leftDy - (t * _speed);
    } else if ((i == 0) && (j > 0 && j < (cols - 1))) {
      // Top Side
      middleDy = middleDy + (t * _speed);
      leftDx = leftDx - (t * _speed);
      rightDx = rightDx + (t * _speed);
    } else if ((i > 0 && i < (rows - 1)) && j == 0) {
      // Left Side
      middleDx = middleDx + (t * _speed);
      leftDy = leftDy - (t * _speed);
      rightDy = rightDy + (t * _speed);
    } else if ((i > 0 && i < (rows - 1)) && j == (cols - 1)) {
      // Right Side
      middleDx = middleDx - (t * _speed);
      leftDy = leftDy - (t * _speed);
      rightDy = rightDy + (t * _speed);
    } else {
      middleDy = middleDy - (t * _speed);
      leftDx = leftDx - (t * _speed);
      rightDx = rightDx + (t * _speed);
      bottomDy = bottomDy + (t * _speed);
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

  @override
  void render(Canvas canvas) {
    atomModel.electrons.sort((a, b) => b - a);
    if (atomModel.electrons.length > 0) {
      atomModel.electrons.forEach((index) {
        if (index == 1) {
          _drawDot(canvas, middleDx, middleDy);
        }
        if (index == 2) {
          _drawDot(canvas, leftDx, leftDy);
        }
        if (index == 3) {
          _drawDot(canvas, rightDx, rightDy);
        }
        if (index == 4) {
          _drawDot(canvas, bottomDx, bottomDy);
        }
      });
    }
  }

  @override
  void update(double t) {
    if (atomModel.electrons.length > 0 && atomModel.isExplode) {
      explodeDotsPositions(t);
    } else {
      setDotsPositions();
    }
  }

  void _drawDot(Canvas canvas, double dx, double dy) {
    Rect circleRect = new Rect.fromCircle(
      center: new Offset(dx, dy),
      radius: 10.0,
    );

    var _gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment(0.5, 1.0),
      colors: [playerColor, darken(playerColor, 0.3)], // whitish to gray
      tileMode: TileMode.clamp,
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = new Paint()
      ..shader = _gradient.createShader(circleRect);
    canvas.drawCircle(Offset(dx, dy), 10, paint);
  }

  @override
  void onMount() {
    super.onMount();
  }
}
