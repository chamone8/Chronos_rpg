class Player {
  int level;
  double gold;
  double xp;
  DateTime lastUpdate;

  Player({
    this.level = 1,
    this.gold = 0,
    this.xp = 0,
    required this.lastUpdate,
  });

  // A mágica do IDLE: Calcula o que aconteceu enquanto o app estava fechado
  void updateOfflineProgress() {
    final now = DateTime.now();
    final secondsAway = now.difference(lastUpdate).inSeconds;
    
    if (secondsAway > 0) {
      // Exemplo: ganha 1 de ouro por segundo offline
      gold += secondsAway * 1.0; 
      lastUpdate = now;
    }
  }
}