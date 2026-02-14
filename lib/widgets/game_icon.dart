import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:chronos_rpg/core/constants/game_icons.dart';
import 'package:chronos_rpg/core/graphics/sprite_painter.dart';

class GameIcon extends StatelessWidget {
  final String iconName;
  final ui.Image spriteSheet;
  final double size;

  const GameIcon({
    super.key,
    required this.iconName,
    required this.spriteSheet,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    // --- ESTE É O CÓDIGO QUE VOCÊ PERGUNTOU ---
    // Ele mapeia a String (ex: "mining") para o Point(2, 10)
    final coords = GameIcons.skillMap[iconName] ?? const Point(0, 0);

    return CustomPaint(
      size: Size(size, size),
      painter: SpriteIconPainter(
        image: spriteSheet,
        row: coords.y, // Y representa a linha na Sprite Sheet
        col: coords.x, // X representa a coluna na Sprite Sheet
        tileSize: 32.0, // Tamanho de cada quadrado (tile) na imagem original
      ),
    );
    // --- FIM DO BLOCO ---
  }
}