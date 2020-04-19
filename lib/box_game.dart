import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_demo/provider.dart';
import 'package:flutter_flame_demo/background.dart';
import 'package:flutter_flame_demo/square.dart';
import 'package:flutter_flame_demo/dots.dart';

class BoxGame extends BaseGame {
  Provider provider;
  Size screenSize;
  int col = 6;
  int row = 9;
  bool isGridRendering = false;

  BoxGame(Provider provider) {
    this.provider = provider;
    add(Background());
  }

  void buildGrid() {
    if (screenSize != null && !isGridRendering) {
      isGridRendering = true;
      for (int i = 0; i < provider.matrix.length; i++) {
        for (int j = 0; j < provider.matrix[i].length; j++) {
          double width = (screenSize.width / col);
          double height = (screenSize.height / row);
          double x = j * width;
          double y = i * height;
          Square square = Square(
              x: x,
              y: y,
              width: width,
              height: height,
              provider: provider,
              atomModel: provider.matrix[i][j]);
          add(square);
          Dots dots = Dots(
              x: x,
              y: y,
              width: width,
              height: height,
              atomModel: provider.matrix[i][j]);
          add(dots);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void resize(Size size) {
    screenSize = size;
    buildGrid();
    super.resize(size);
  }
}
