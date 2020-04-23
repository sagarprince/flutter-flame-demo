import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/position.dart';
import 'package:flutter_flame_demo/game_service.dart';
import 'package:flutter_flame_demo/background.dart';
import 'package:flame/text_config.dart';
import 'package:flutter_flame_demo/cell.dart';
import 'package:flutter_flame_demo/orbs.dart';

class ChainReactionGame extends BaseGame {
  Size screenSize;
  int col = 6;
  int row = 9;
  bool isGridRendering = false;
  GameService service;

  final TextConfig fpsTextConfig =
      const TextConfig(color: const Color(0xFFFFFFFF));

  ChainReactionGame() {
    this.service = gameService;
    add(Background());
  }

  @override
  bool debugMode() => true;

  void buildGrid() {
    if (screenSize != null && !isGridRendering) {
      isGridRendering = true;
      for (int i = 0; i < service.matrix.length; i++) {
        for (int j = 0; j < service.matrix[i].length; j++) {
          double width = (screenSize.width / col);
          double height = (screenSize.height / row);
          double x = j * width;
          double y = i * height;
          Cell cell = Cell(
              x: x,
              y: y,
              width: width,
              height: height,
              cellModel: service.matrix[i][j]);
          add(cell);

          Orbs orbs = Orbs(
              x: x,
              y: y,
              width: width,
              height: height,
              cellModel: service.matrix[i][j]);
          add(orbs);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (debugMode()) {
      fpsTextConfig.render(canvas, fps(120).floorToDouble().toString(),
          Position(screenSize.width / 2 - 20, (screenSize.height - 10)));
    }
  }

  @override
  void resize(Size size) {
    screenSize = size;
    buildGrid();
    super.resize(size);
  }
}
