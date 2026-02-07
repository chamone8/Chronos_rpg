import 'dart:async';
import 'package:chronos_rpg/models/upgradeItem.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/skill.dart';
import '../models/enemy.dart';
import 'dart:math'; // Adicionado para lógica de probabilidade

class GameProvider with ChangeNotifier {
  Player player = Player(lastUpdate: DateTime.now());
  int activeSkillIndex = -1;
  int monstersDefeatedInGroup = 0; // Quantos monstros dos 10 ele já matou
  int currentMonsterIndex = 0; // Qual dos 10 monstros ele está enfrentando
  bool bossAvailable = false;

  // Inventário inicializado com os novos recursos
  Map<String, int> inventory = {
    'pedra': 0,
    'minerio_carvao': 0,
    'minerio_ferro': 0,
    'peixe_cru': 0,
    'madeira_carvalho': 0,
    'couro_monstro': 0,
  };

  final List<Skill> skills = [
    Skill(name: "Mineração", iconPath: "mining"),
    Skill(name: "Pesca", iconPath: "fishing"),
    Skill(name: "Combate", iconPath: "combat"),
    Skill(name: "Lenhador", iconPath: "woodcutting"),
  ];

  List<Enemy> allEnemies = [
    Enemy(
      name: "Lodo Temporal",
      maxHealth: 50,
      xpReward: 20,
      minLevel: 1,
      goldReward: 0,
    ),
    Enemy(
      name: "Vigia de Bronze",
      maxHealth: 150,
      xpReward: 60,
      minLevel: 5,
      goldReward: 0,
    ),
    Enemy(
      name: "Espectro de Chronos",
      maxHealth: 400,
      xpReward: 150,
      minLevel: 12,
      goldReward: 50,
    ),
  ];

  List<UpgradeItem> shopUpgrades = [
    UpgradeItem(
      name: "Picareta de Bronze",
      description: "Melhora a qualidade dos minérios encontrados.",
      price: 500,
      targetSkill: "Mineração",
    ),
    UpgradeItem(
      name: "Vara de Bambu Reforçada",
      description: "Pesca 2x mais rápido.",
      price: 450,
      targetSkill: "Pesca",
    ),
  ];

  final Map<String, double> itemPrices = {
    'pedra': 1.0,
    'minerio_carvao': 5.0,
    'minerio_ferro': 15.0,
    'peixe_cru': 5.0,
    'madeira_carvalho': 3.0,
    'couro_monstro': 15.0,
  };

  int lastOfflineSeconds = 0;
  String offlineSummary = "";
  double lastOfflineGold = 0;

  Enemy currentEnemy = Enemy(
    name: "Lodo Temporal",
    maxHealth: 50,
    goldReward: 0,
    xpReward: 10,
    minLevel: 0,
  );

  Timer? _timer;

  GameProvider() {
    _initGame();
  }

  // --- GETTERS ---
  double get totalInventoryValue {
    double total = 0;
    inventory.forEach((key, quantity) {
      total += quantity * (itemPrices[key] ?? 0);
    });
    return total;
  }

  // --- INICIALIZAÇÃO E LOOP ---
  Future<void> _initGame() async {
    await _loadProgress();
    _calculateOfflineProgress();
    _startGameLoop();
  }

  void setActiveSkill(int index) {
    activeSkillIndex = (activeSkillIndex == index) ? -1 : index;
    notifyListeners();
  }

  void _startGameLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (activeSkillIndex != -1) {
        _processWork();
      }
      player.lastUpdate = DateTime.now();
      _saveProgress();
      notifyListeners();
    });
  }

  void _processWork() {
    final skill = skills[activeSkillIndex];
    skill.addXp(5);

    switch (activeSkillIndex) {
      case 0:
        _processMining(skill.level);
        break;
      case 1:
        _addToInventory('peixe_cru');
        break;
      case 2:
        _processCombat();
        break;
      case 3:
        _addToInventory('madeira_carvalho');
        break;
    }
  }

  // --- LÓGICA DE MINERAÇÃO REFINADA ---
  void _processMining(int skillLevel) {
    final random = Random();
    int roll = random.nextInt(100); // 0 a 99

    // Se tiver o upgrade, melhora a sorte (diminui o roll para atingir faixas raras)
    bool hasBronzePickaxe = shopUpgrades[0].isOwned;
    if (hasBronzePickaxe) {
      roll -= 10; // "Buff" de sorte
    }

    if (skillLevel >= 10 && roll < 15) {
      _addToInventory('minerio_ferro');
    } else if (skillLevel >= 5 && roll < 40) {
      _addToInventory('minerio_carvao');
    } else {
      _addToInventory('pedra');
    }
  }

  void _addToInventory(String itemKey) {
    inventory[itemKey] = (inventory[itemKey] ?? 0) + 1;
  }

  void _processCombat() {
    // Dano baseado na força do player
    double damage = 5.0 + (player.strength * 1.5);
    currentEnemy.takeDamage(damage);

    if (currentEnemy.isDead) {
      // Chama a lógica de vitória que gerencia os 10 monstros + Boss
      processVictory();
    }
  }

  // --- OFFLINE E PERSISTÊNCIA ---
  void _calculateOfflineProgress() {
    final now = DateTime.now();
    final secondsAway = now.difference(player.lastUpdate).inSeconds;

    if (secondsAway > 10 && activeSkillIndex != -1) {
      lastOfflineSeconds = secondsAway;
      int itemsGained = (secondsAway / 3).floor();

      skills[activeSkillIndex].addXp(secondsAway * 2.0);
      String itemKey = _getItemKeyForSkill(activeSkillIndex);
      inventory[itemKey] = (inventory[itemKey] ?? 0) + itemsGained;

      offlineSummary =
          "Você treinou ${skills[activeSkillIndex].name} e coletou $itemsGained itens!";
      player.lastUpdate = now;
      notifyListeners();
    }
  }

  String _getItemKeyForSkill(int index) {
    switch (index) {
      case 0:
        return 'pedra'; // Offline na mina agora dá pedra por padrão
      case 1:
        return 'peixe_cru';
      case 2:
        return 'couro_monstro';
      default:
        return 'madeira_carvalho';
    }
  }

  void sellAllResources() {
    player.gold += totalInventoryValue;
    inventory.updateAll((key, value) => 0);
    notifyListeners();
  }

  void distributePoint(String attribute) {
    if (player.pointsToDistribute > 0) {
      if (attribute == 'strength') player.strength++;
      if (attribute == 'defense') player.defense++;
      if (attribute == 'vitality') player.vitality++;
      if (attribute == 'intelligence') player.intelligence++;
      if (attribute == 'luck') player.luck++;
      player.pointsToDistribute--;
      notifyListeners();
    }
  }

  void buyUpgrade(int index) {
    var upgrade = shopUpgrades[index];
    if (player.gold >= upgrade.price && !upgrade.isOwned) {
      player.gold -= upgrade.price;
      upgrade.isOwned = true;
      notifyListeners();
    }
  }

  void processVictory() {
    if (bossAvailable) {
      _giveSpecialRewards(); // Recompensa do Boss
      bossAvailable = false;
      monstersDefeatedInGroup = 0;
      currentMonsterIndex = 0;
      // Reseta para o primeiro inimigo da lista ou evolui o grupo
      currentEnemy = allEnemies[0];
    } else {
      // Recompensa comum
      player.addXp(currentEnemy.xpReward.toDouble());
      _addToInventory('couro_monstro');

      monstersDefeatedInGroup++;

      if (monstersDefeatedInGroup >= 10) {
        bossAvailable = true;
        // Transforma o inimigo atual em uma versão "Boss"
        currentEnemy = Enemy(
          name: "GENERAL DE CHRONOS",
          maxHealth: 500,
          xpReward: 500,
          goldReward: 200,
          minLevel: 10,
        );
      } else {
        currentEnemy.reset(); // Próximo monstro comum
      }
    }
    notifyListeners();
  }

  void _giveSpecialRewards() {
    player.gold += 500; // Ouro bônus do Boss
    player.addXp(1000); // XP massivo
    _addToInventory('minerio_ouro'); // Item raro
  }

  // --- SHARED PREFS ---
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('gold', player.gold);
    await prefs.setInt('activeSkill', activeSkillIndex);
    await prefs.setString('lastUpdate', player.lastUpdate.toIso8601String());
    // Sugestão sênior: Salvar o inventory aqui também para não perder itens
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    player.gold = prefs.getDouble('gold') ?? 0.0;
    activeSkillIndex = prefs.getInt('activeSkill') ?? -1;
    final lastUpdateStr = prefs.getString('lastUpdate');
    if (lastUpdateStr != null)
      player.lastUpdate = DateTime.parse(lastUpdateStr);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
