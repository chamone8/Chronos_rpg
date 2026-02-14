import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:chronos_rpg/core/constants/game_icons.dart';
import 'package:chronos_rpg/core/graphics/sprite_loader.dart';
import 'package:chronos_rpg/models/upgradeItem.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/skill.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';

class GameProvider with ChangeNotifier {
  // --- ESTADO DO JOGADOR ---
  Player player = Player(lastUpdate: DateTime.now());
  // Novos Slots no GameProvider
  Equipment? equippedWeapon;
  Equipment? equippedArmor;
  Equipment? equippedHelmet;
  Equipment? equippedLeggings;
  Equipment? equippedBoots;
  Equipment? equippedRing;
  Equipment? equippedPotionHP;
  Equipment? equippedPotionMP;

  // --- ESTADO DE ATIVIDADE ---
  int activeSkillIndex =
      -1; // -1 = Parado, 0 = Mineração, 1 = Pesca, 2 = Lenhador
  int monstersDefeatedInGroup = 0;
  int currentMonsterIndex = 0;
  bool bossAvailable = false;
  ui.Image? spriteSheet;

  // --- INVENTÁRIO ---
  Map<String, int> inventory = {
    'pedra': 0,
    'minerio_carvao': 0,
    'minerio_ferro': 0,
    'minerio_ouro': 0, // Adicionado para suportar a recompensa do Boss
    'peixe_cru': 0,
    'madeira_carvalho': 0,
    'couro_monstro': 0,
  };

  // --- DEFINIÇÕES DE DADOS (DATABASE IMOBILIZADA) ---
  final List<Skill> skills = [
    Skill(name: "Mineração", iconPath: "mining"),
    Skill(name: "Pesca", iconPath: "fishing"),
    Skill(name: "Lenhador", iconPath: "woodcutting"),
  ];

  final List<UpgradeItem> shopUpgrades = [
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
    'minerio_ouro': 100.0,
    'peixe_cru': 5.0,
    'madeira_carvalho': 3.0,
    'couro_monstro': 15.0,
  };

  final List<Enemy> allEnemies = [
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

  // --- ESTADO DE COMBATE ---
  Enemy currentEnemy = Enemy(
    name: "Lodo Temporal",
    maxHealth: 50,
    goldReward: 0,
    xpReward: 10,
    minLevel: 0,
  );

  // --- CONTROLE DE UI/OFFLINE ---
  int lastOfflineSeconds = 0;
  String offlineSummary = "";
  double lastOfflineGold = 0;

  Timer? _timer;

  GameProvider() {
    _initGame();
  }

  // --- GETTERS CALCULADOS ---
  double get totalInventoryValue {
    double total = 0;
    inventory.forEach((key, quantity) {
      total += quantity * (itemPrices[key] ?? 0);
    });
    return total;
  }

  int get totalStrength =>
      player.strength + (equippedWeapon?.strengthBonus ?? 0);
  int get totalDefense =>
      player.defense +
      (equippedHelmet?.defenseBonus ?? 0) +
      (equippedArmor?.defenseBonus ?? 0) +
      (equippedLeggings?.defenseBonus ?? 0) +
      (equippedBoots?.defenseBonus ?? 0);

  // --- INICIALIZAÇÃO ---
  Future<void> _initGame() async {
    await _loadProgress();
    _calculateOfflineProgress();
    _startGameLoop();
  }

  void _startGameLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (activeSkillIndex != -1) {
        _processWork();
      }
      // O combate agora é independente das outras skills
      _processCombat();

      player.lastUpdate = DateTime.now();
      _saveProgress();
      notifyListeners();
    });
  }

  // --- PROCESSAMENTO DE TRABALHOS ---
  void setActiveSkill(int index) {
    activeSkillIndex = (activeSkillIndex == index) ? -1 : index;
    notifyListeners();
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
        _addToInventory('madeira_carvalho');
        break; // Lenhador agora é index 2
    }
  }

  void _processMining(int skillLevel) {
    final random = Random();
    int roll = random.nextInt(100);

    if (shopUpgrades[0].isOwned) roll -= 10;

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

  // --- SISTEMA DE COMBATE ---
  void _processCombat() {
    // IMPORTANTE: Usa o totalStrength (Base + Arma)
    double damage = 5.0 + (totalStrength * 1.5);
    currentEnemy.takeDamage(damage);

    if (currentEnemy.isDead) {
      processVictory();
    }
  }

  void processVictory() {
    if (bossAvailable) {
      _giveSpecialRewards();
      bossAvailable = false;
      monstersDefeatedInGroup = 0;
      currentMonsterIndex = 0;
      currentEnemy = allEnemies[0];
    } else {
      player.addXp(currentEnemy.xpReward.toDouble());
      _addToInventory('couro_monstro');
      monstersDefeatedInGroup++;

      if (monstersDefeatedInGroup >= 10) {
        bossAvailable = true;
        currentEnemy = Enemy(
          name: "GENERAL DE CHRONOS",
          maxHealth: 500,
          xpReward: 500,
          goldReward: 200,
          minLevel: 10,
        );
      } else {
        currentEnemy.reset();
      }
    }
    notifyListeners();
  }

  void _giveSpecialRewards() {
    player.gold += 500;
    player.addXp(1000);
    _addToInventory('minerio_ouro');
  }

  // --- LOJA E EQUIPAMENTOS ---
  void buyUpgrade(int index) {
    var upgrade = shopUpgrades[index];
    if (player.gold >= upgrade.price && !upgrade.isOwned) {
      player.gold -= upgrade.price;
      upgrade.isOwned = true;
      notifyListeners();
    }
  }

  void buyWeapon() {
    if (player.gold >= 1000) {
      player.gold -= 1000;
      equipItem(
        Equipment(
          name: "Espada de Bronze",
          slot: EquipmentSlot.weapon,
          strengthBonus: 15,
        ),
      );
    }
  }

  // Método equipItem atualizado
  void equipItem(Equipment item) {
    switch (item.slot) {
      case EquipmentSlot.helmet:
        equippedHelmet = item;
        break;
      case EquipmentSlot.armor:
        equippedArmor = item;
        break;
      case EquipmentSlot.leggings:
        equippedLeggings = item;
        break;
      case EquipmentSlot.boots:
        equippedBoots = item;
        break;
      case EquipmentSlot.weapon:
        equippedWeapon = item;
        break;
      case EquipmentSlot.ring:
        equippedRing = item;
        break;
      case EquipmentSlot.potionHP:
        equippedPotionHP = item;
        break;
      case EquipmentSlot.potionMP:
        equippedPotionMP = item;
        break;
    }
    notifyListeners();
  }

  void sellAllResources() {
    player.gold += totalInventoryValue;
    inventory.updateAll((key, value) => 0);
    notifyListeners();
  }

  void distributePoint(String attribute) {
    if (player.pointsToDistribute > 0) {
      switch (attribute) {
        case 'strength':
          player.strength++;
          break;
        case 'defense':
          player.defense++;
          break;
        case 'vitality':
          player.vitality++;
          break;
        case 'intelligence':
          player.intelligence++;
          break;
        case 'luck':
          player.luck++;
          break;
      }
      player.pointsToDistribute--;
      notifyListeners();
    }
  }

  // --- PERSISTÊNCIA E OFFLINE ---
  void _calculateOfflineProgress() {
    final now = DateTime.now();
    final secondsAway = now.difference(player.lastUpdate).inSeconds;

    if (secondsAway > 10 && activeSkillIndex != -1) {
      lastOfflineSeconds = secondsAway;
      int itemsGained = (secondsAway / 3).floor();
      skills[activeSkillIndex].addXp(secondsAway * 2.0);

      String itemKey = (activeSkillIndex == 0)
          ? 'pedra'
          : (activeSkillIndex == 1)
          ? 'peixe_cru'
          : 'madeira_carvalho';

      inventory[itemKey] = (inventory[itemKey] ?? 0) + itemsGained;
      offlineSummary =
          "Você treinou ${skills[activeSkillIndex].name} e coletou $itemsGained itens!";
      player.lastUpdate = now;
      notifyListeners();
    }
  }

Future<void> loadAssets() async {
  print("DEBUG: Iniciando carregamento da Sprite Sheet..."); // Log 1
  try {
    // Tente usar o path completo exatamente como está no seu pubspec.yaml
    final img = await loadSpriteSheet('lib/assets/items/sprite_sheet_items.png');
    
    this.spriteSheet = img;
    print("DEBUG: Imagem carregada com sucesso! ${img.width}x${img.height}"); // Log 2
    
    notifyListeners(); // ISSO É ESSENCIAL para a UI "acordar"
  } catch (e) {
    print("DEBUG ERROR: Falha ao carregar asset: $e"); // Log 3
  }
}
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('gold', player.gold);
    await prefs.setInt('activeSkill', activeSkillIndex);
    await prefs.setString('lastUpdate', player.lastUpdate.toIso8601String());
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
