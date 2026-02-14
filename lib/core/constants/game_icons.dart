import 'dart:math';

class GameIcons {
  // Caminho da sua imagem local
  static const String spriteSheetPath = 'lib/assets/items/sprite_sheet_items.png'; 
  // Nota: Verifique se no seu pubspec.yaml o caminho está exatamente assim.

  static const Map<String, Point<int>> skillMap = {
    "mining": Point(2, 10),      // X: 2, Y: 10
    "fishing": Point(4, 11),     // X: 4, Y: 11
    "woodcutting": Point(1, 10), // X: 1, Y: 10
  };
}