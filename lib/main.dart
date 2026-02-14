// lib/main.dart

import 'package:chronos_rpg/screens/Profile_Screen.dart';
import 'package:chronos_rpg/screens/combat_screen.dart';
import 'package:chronos_rpg/screens/inventory_screen.dart';
import 'package:chronos_rpg/screens/merchant_screen.dart';
import 'package:chronos_rpg/widgets/game_icon.dart';
import 'package:chronos_rpg/widgets/skill_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/offline_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider()..loadAssets(),
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

  Widget _buildSquareButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60, // Largura do quadrado
        height: 60, // Altura do quadrado
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), // Fundo sutil com a cor do ícone
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  @override
  // ... (mantenha os imports e o início da classe)
  @override
  Widget build(BuildContext context) {
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

            // --- NOVO LAYOUT DO PERSONAGEM (ESTILO CARD QUADRADO) ---
            Center(
              child: Container(
                width:
                    140, // Um pouco menor que no perfil para caber melhor na principal
                height: 140,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), // Fundo cinza escuro sólido
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'lib/assets/images/pesona.png',
                    fit: BoxFit.contain, // Mantém o sprite inteiro sem cortar
                    filterQuality:
                        FilterQuality.none, // Essencial para Pixel Art
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white10,
                      );
                    },
                  ),
                ),
              ),
            ),

            // PAINEL DE STATUS (REATIVO)
            _buildStatusPanel(game),

            const SizedBox(height: 10),
            const Divider(color: Colors.white10, height: 1),

           // LISTA DE SKILLS COM O NOVO ÍCONE
            Expanded(
              child: ListView.builder(
                itemCount: game.skills.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (context, index) {
                  final skill = game.skills[index];
                  return SkillCard(
                    skill: skill,
                    // Aqui passamos o GameIcon se a imagem já estiver carregada
                    leading: game.spriteSheet != null 
                      ? GameIcon(iconName: skill.iconPath, spriteSheet: game.spriteSheet!)
                      : const CircularProgressIndicator(),
                    onTap: () => game.setActiveSkill(index),
                    isActive: game.activeSkillIndex == index,
                  );
                },
              ),
            ),

            // BOTÕES DE NAVEGAÇÃO RÁPIDA (RESTAURADOS)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSquareButton(context, icon: Icons.person_search, color: Colors.white, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                  const SizedBox(width: 15),
                  _buildSquareButton(context, icon: Icons.inventory_2_outlined, color: Colors.blueAccent, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))),
                  const SizedBox(width: 15),
                  _buildSquareButton(context, icon: Icons.storefront, color: Colors.amber, // Ícone de loja restaurado
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MerchantScreen()))),
                  const SizedBox(width: 15),
                  _buildSquareButton(context, icon: Icons.colorize, color: Colors.redAccent, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CombatScreen()))),
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
