import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class CombatScreen extends StatelessWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final enemy = game.currentEnemy;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CAMPO DE BATALHA"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ÁREA DE COMBATE ATIVO
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: game.bossAvailable ? Colors.red : Colors.white10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (game.bossAvailable)
                  const Text("⚠ CHEFE DETECTADO ⚠", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Icon(Icons.adb, size: 80, color: Colors.white24), // Placeholder para o monstro
                Text(
                  game.bossAvailable ? "GENERAL DE CHRONOS" : "MONSTRO ${game.currentMonsterIndex + 1}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Barra de Vida do Inimigo
                _buildHealthBar(enemy.health, enemy.maxHealth),
              ],
            ),
          ),

          const Text("PROGRESSO DA ZONA", style: TextStyle(color: Colors.grey, letterSpacing: 2)),
          
          // GRID DE PROGRESSÃO (10 Monstros + Boss)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 11, // 10 monstros + 1 boss
              itemBuilder: (context, index) {
                if (index == 10) return _buildBossNode(game.bossAvailable);
                return _buildMonsterNode(index, game.monstersDefeatedInGroup);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBar(double current, double max) {
    return Container(
      width: 250,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (current / max).clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildMonsterNode(int index, int defeatedCount) {
    bool isDefeated = index < defeatedCount;
    bool isCurrent = index == defeatedCount;

    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? Colors.amber.withOpacity(0.2) : (isDefeated ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent ? Colors.amber : (isDefeated ? Colors.green : Colors.white10),
          width: 2,
        ),
      ),
      child: Center(
        child: isDefeated 
          ? const Icon(Icons.check, size: 16, color: Colors.green)
          : Text("${index + 1}", style: TextStyle(color: isCurrent ? Colors.amber : Colors.grey)),
      ),
    );
  }

  Widget _buildBossNode(bool isAvailable) {
    return Container(
      decoration: BoxDecoration(
        color: isAvailable ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isAvailable ? Colors.red : Colors.white10, width: 2),
      ),
      child: Icon(
        Icons.workspace_premium, 
        color: isAvailable ? Colors.red : Colors.grey[800]
      ),
    );
  }
}