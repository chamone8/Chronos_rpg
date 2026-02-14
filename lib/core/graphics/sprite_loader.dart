import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<ui.Image> loadSpriteSheet(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}