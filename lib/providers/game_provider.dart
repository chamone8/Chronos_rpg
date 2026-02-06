import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/skill.dart';

class GameProvider with ChangeNotifier {
  int lastOfflineSeconds = 0;
  double lastOfflineGold = 0;

  Player player = Player(lastUpdate: DateTime.now());

  // Lista de habilidades do Chronos RPG
  final List<Skill> skills = [
    Skill(name: "Mineração", iconPath: "mining"),
    Skill(name: "Pesca", iconPath: "fishing"),
    Skill(name: "Combate", iconPath: "combat"),
  ];

  Timer? _timer;

  GameProvider() {
    _initGame();
  }

  // Inicialização assíncrona
  Future<void> _initGame() async {
    await _loadProgress(); // 1. Carrega o que estava salvo
    _calculateOfflineProgress(); // 2. Calcula o tempo fora
    _startGameLoop(); // 3. Começa o tick em tempo real
  }

  void _calculateOfflineProgress() {
    final now = DateTime.now();
    final secondsAway = now.difference(player.lastUpdate).inSeconds;

    if (secondsAway > 10) {
      // Mínimo de 10 segundos fora
      lastOfflineGold = secondsAway * 1.0;
      lastOfflineSeconds = secondsAway;

      player.gold += lastOfflineGold;

      // Ganho de XP offline (ex: 0.5 XP por segundo em cada skill)
      for (var skill in skills) {
        skill.addXp(secondsAway * 0.5);
      }

      print(
        "Bem-vindo de volta! Você ganhou ${lastOfflineGold.toStringAsFixed(0)} de ouro após $lastOfflineSeconds segundos!",
      );

      player.lastUpdate = now;
      notifyListeners();
    }
  }

  void _startGameLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      player.gold += 1;

      // Salva o timestamp atual a cada tick para o próximo cálculo offline
      player.lastUpdate = DateTime.now();
      _saveProgress();

      notifyListeners();
    });
  }

  // --- PERSISTÊNCIA (Local Storage) ---

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('gold', player.gold);
    await prefs.setString('lastUpdate', player.lastUpdate.toIso8601String());
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    player.gold = prefs.getDouble('gold') ?? 0.0;

    final lastUpdateStr = prefs.getString('lastUpdate');
    if (lastUpdateStr != null) {
      player.lastUpdate = DateTime.parse(lastUpdateStr);
    }
  }

  void clickToFarm() {
    player.gold += 10;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}