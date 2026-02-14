// lib/screens/profile_screen.dart

import 'package:chronos_rpg/models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final p = game.player;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("PERFIL DO HERÓI"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. SEÇÃO DE EQUIPAMENTOS E PERSONAGEM (Paper Doll Layout)
            _buildEquipmentSection(game),

            const Text(
              "PROGRESSO",
              style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
            ),

            // Barra de XP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              child: LinearProgressIndicator(
                value: p.currentXp / p.xpRequired,
                backgroundColor: Colors.white10,
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Divider(color: Colors.white10, height: 30),

            // 2. DISTRIBUIÇÃO DE PONTOS
            if (p.pointsToDistribute > 0) _buildPointBanner(p.pointsToDistribute),

            const SizedBox(height: 10),

            // 3. LISTA DE ATRIBUTOS
            _buildAttributeRow(context, game, "FORÇA", game.totalStrength, "strength", Icons.fitness_center),
            _buildAttributeRow(context, game, "VITALIDADE", p.vitality, "vitality", Icons.favorite),
            _buildAttributeRow(context, game, "DEFESA", game.totalDefense, "defense", Icons.shield),
            _buildAttributeRow(context, game, "INTELIGÊNCIA", p.intelligence, "intelligence", Icons.auto_stories),
            _buildAttributeRow(context, game, "SORTE", p.luck, "luck", Icons.casino),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE INTERFACE ---

  Widget _buildEquipmentSection(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // COLUNA ESQUERDA: Defesa
          Column(
            children: [
              _buildSlot(label: "ELMO", item: game.equippedHelmet, icon: Icons.assignment_ind_outlined),
              const SizedBox(height: 10),
              _buildSlot(label: "PEITORAL", item: game.equippedArmor, icon: Icons.shield_outlined),
              const SizedBox(height: 10),
              _buildSlot(label: "CALÇA", item: game.equippedLeggings, icon: Icons.vertical_split_outlined),
              const SizedBox(height: 10),
              _buildSlot(label: "BOTAS", item: game.equippedBoots, icon: Icons.directions_walk),
            ],
          ),

          // CENTRO: O Card do Personagem (Ajustado para o layout que você gostou)
          _buildCharacterCard(game.player.level),

          // COLUNA DIREITA: Ataque e Utilidade
          Column(
            children: [
              _buildSlot(label: "ARMA", item: game.equippedWeapon, icon: Icons.colorize_outlined),
              const SizedBox(height: 10),
              _buildSlot(label: "ANEL", item: game.equippedRing, icon: Icons.blur_circular),
              const SizedBox(height: 10),
              _buildSlot(label: "SANGUE", item: game.equippedPotionHP, icon: Icons.bloodtype, color: Colors.redAccent),
              const SizedBox(height: 10),
              _buildSlot(label: "MANA", item: game.equippedPotionMP, icon: Icons.bolt, color: Colors.blueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(int level) {
    return Container(
      width: 150,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'lib/assets/images/pesona.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80, color: Colors.white10),
              ),
            ),
          ),
          Text("NÍVEL $level", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSlot({required String label, Equipment? item, required IconData icon, Color color = Colors.white24}) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item != null ? Colors.amber.withOpacity(0.5) : color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: item != null
              ? const Icon(Icons.inventory_2, color: Colors.amber, size: 28)
              : Icon(icon, color: color.withOpacity(0.4), size: 22),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPointBanner(int points) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "PONTOS DISPONÍVEIS: $points",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildAttributeRow(BuildContext context, GameProvider game, String label, int value, String attrKey, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white24, size: 16),
            const SizedBox(width: 15),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
            Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            IconButton(
              onPressed: game.player.pointsToDistribute > 0 ? () => game.distributePoint(attrKey) : null,
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}