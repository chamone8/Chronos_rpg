import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SpriteIconPainter extends CustomPainter {
  final ui.Image image;
  final int row; // Linha do ícone (começando em 0)
  final int col; // Coluna do ícone (começando em 0)
  final double tileSize; // Tamanho do ícone na imagem original (ex: 32.0)

  SpriteIconPainter({
    required this.image,
    required this.row,
    required this.col,
    this.tileSize = 32.0, // Ajuste conforme o tamanho real dos seus ícones
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Retângulo de origem (onde o ícone está na sua imagem)
    Rect src = Rect.fromLTWH(
      col * tileSize, 
      row * tileSize, 
      tileSize, 
      tileSize
    );

    // Retângulo de destino (onde ele será desenhado na tela do Flutter)
    Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}