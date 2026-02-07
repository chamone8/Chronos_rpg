// lib/main.dart

import 'package:chronos_rpg/screens/ProfileScreen.dart';
import 'package:chronos_rpg/screens/combat_screen.dart';
import 'package:chronos_rpg/screens/inventory_screen.dart';
import 'package:chronos_rpg/screens/merchant_screen.dart';
import 'package:chronos_rpg/widgets/skill_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/offline_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronos RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      if (game.lastOfflineSeconds > 0) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OfflineDialog(
            seconds: game.lastOfflineSeconds,
            goldGained: game.lastOfflineGold,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos select para otimizar: a tela só reconstrói se essas propriedades mudarem
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CHRONOS RPG",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF000000)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // PAINEL DE STATUS (REATIVO)
            _buildStatusPanel(game),

            const SizedBox(height: 10),
            const Divider(color: Colors.white10, height: 1),

            // LISTA DE SKILLS
            Expanded(
              child: ListView.builder(
                itemCount: game.skills.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  return SkillCard(
                    skill: game.skills[index],
                    onTap: () => game.setActiveSkill(index),
                    // Passamos se está ativa para o widget de Card
                    // Se o seu SkillCard ainda não recebe 'isActive', podemos adicionar agora
                    isActive: game.activeSkillIndex == index,
                  );
                },
              ),
            ),

            // BOTÕES DE NAVEGAÇÃO
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Botão de Inventário (Destaque Secundário)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text("ABRIR MOCHILA"),
                    style: _buttonStyle(Colors.blueGrey.withOpacity(0.2)),
                  ),
                  const SizedBox(height: 12),
                  // Botão do Mercador (Destaque Principal)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MerchantScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.storefront, color: Colors.amber),
                    label: const Text("VISITAR MERCADOR"),
                    style: _buttonStyle(
                      Colors.amber.withOpacity(0.1),
                      borderColor: Colors.amber.withOpacity(0.5),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CombatScreen(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.colorize,
                      color: Colors.redAccent,
                    ), // Ícone de espada/combate
                    label: const Text("CAMPO DE BATALHA"),
                    style: _buttonStyle(
                      Colors.red.withOpacity(0.1),
                      borderColor: Colors.redAccent.withOpacity(0.5),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.person_search),
                    label: const Text("MEU PERFIL / ATRIBUTOS"),
                    style: _buttonStyle(Colors.white.withOpacity(0.05)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget extraído para manter o código limpo (padrão sênior)
  Widget _buildStatusPanel(GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusItem(
            "OURO",
            "${game.player.gold.toStringAsFixed(0)}G",
            Colors.amber,
          ),
          _statusItem(
            "ATIVIDADE",
            game.activeSkillIndex == -1
                ? "DESCANSO"
                : game.skills[game.activeSkillIndex].name.toUpperCase(),
            game.activeSkillIndex == -1 ? Colors.white54 : Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(
    Color bgColor, {
    Color borderColor = Colors.white24,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
    );
  }
}
