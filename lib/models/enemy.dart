// lib/models/enemy.dart

class Enemy {
  final String name;
  final double maxHealth;
  double currentHealth; // O campo real
  final int xpReward;
  final int goldReward;
  final int minLevel;

  Enemy({
    required this.name,
    required this.maxHealth,
    required this.xpReward,
    required this.goldReward,
    required this.minLevel,
  }) : currentHealth = maxHealth;

  // Adicione este getter para resolver o erro da CombatScreen
  double get health => currentHealth; 

  void takeDamage(double damage) {
    currentHealth -= damage;
    if (currentHealth < 0) currentHealth = 0;
  }

  bool get isDead => currentHealth <= 0;

  void reset() {
    currentHealth = maxHealth;
  }
}