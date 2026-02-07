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
      appBar: AppBar(title: const Text("PERFIL DO HERÓI"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar Placeholder (Onde ficará o personagem e armaduras)
            const Center(
              child: Icon(Icons.person, size: 120, color: Colors.amber),
            ),
            const SizedBox(height: 10),
            Text("NÍVEL ${p.level}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            
            // Barra de XP do Player
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: LinearProgressIndicator(
                value: p.currentXp / p.xpRequired,
                backgroundColor: Colors.white10,
                color: Colors.blueAccent,
              ),
            ),

            const Divider(color: Colors.white10, height: 40),

            // Distribuição de Pontos
            if (p.pointsToDistribute > 0)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.amber.withOpacity(0.1),
                child: Text(
                  "VOCÊ TEM ${p.pointsToDistribute} PONTOS DISPONÍVEIS!",
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 20),

            // Lista de Atributos
            _buildAttributeRow(context, game, "FORÇA", p.strength, "strength", Icons.fitness_center),
            _buildAttributeRow(context, game, "VITALIDADE", p.vitality, "vitality", Icons.favorite),
            _buildAttributeRow(context, game, "DEFESA", p.defense, "defense", Icons.shield),
            _buildAttributeRow(context, game, "INTELIGÊNCIA", p.intelligence, "intelligence", Icons.auto_stories),
            _buildAttributeRow(context, game, "SORTE", p.luck, "luck", Icons.casino),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow(BuildContext context, GameProvider game, String label, int value, String attrKey, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ),
          Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          // Botão de Adicionar Ponto
          IconButton(
            onPressed: game.player.pointsToDistribute > 0 
                ? () => game.distributePoint(attrKey) 
                : null,
            icon: const Icon(Icons.add_circle, color: Colors.amber),
            disabledColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}