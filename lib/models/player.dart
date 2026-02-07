class Player {
  int level;
  double currentXp;
  double gold;
  DateTime lastUpdate;

  // Atributos
  int pointsToDistribute;
  int strength;     // Aumenta dano físico
  int defense;      // Reduz dano recebido
  int intelligence; // Aumenta dano de mana/magia
  int vitality;     // Aumenta vida máxima
  int luck;         // Melhora chance de drops raros
  int mana;         // Para futuras skills ativas

  Player({
    this.level = 1,
    this.currentXp = 0,
    this.gold = 0,
    required this.lastUpdate,
    this.pointsToDistribute = 0,
    this.strength = 5,
    this.defense = 5,
    this.intelligence = 5,
    this.vitality = 5,
    this.luck = 5,
    this.mana = 10,
  });

  double get maxHealth => 100.0 + (vitality * 10);
  double get xpRequired => level * 200.0;

  void addXp(double amount) {
    currentXp += amount;
    while (currentXp >= xpRequired) {
      currentXp -= xpRequired;
      level++;
      pointsToDistribute += 5; // Ganha 5 pontos por nível
    }
  }
}