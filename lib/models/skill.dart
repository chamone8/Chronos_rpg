// lib/models/skill.dart

class Skill {
  final String name;
  final String iconPath; // Caminho para o sprite/ícone
  int level;
  double currentXp;

  Skill({
    required this.name,
    required this.iconPath,
    this.level = 1,
    this.currentXp = 0,
  });

  // Cálculo de XP necessário para o próximo nível (Fórmula Incremental)
  double get xpRequired => level * 100.0; 

  // Percentual de progresso (0.0 a 1.0) para alimentar a ProgressBar do Flutter
  double get progressPercentage => currentXp / xpRequired;

  void addXp(double amount) {
    currentXp += amount;
    while (currentXp >= xpRequired) {
      currentXp -= xpRequired;
      level++;
    }
  }
}