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
      theme: ThemeData.dark(),
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

    // O WidgetsBinding garante que o diálogo só apareça após a UI estar pronta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<GameProvider>(context, listen: false);
      
      // Se o GameProvider detectou tempo offline, mostra o pop-up
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
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("CHRONOS RPG"),
        centerTitle: true,
        backgroundColor: Colors.black,
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
            const SizedBox(height: 40),
            // Header de Status
            Text("Nível: ${game.player.level}", 
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
            Text("${game.player.gold.toStringAsFixed(0)}G", 
                 style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, color: Colors.amber)),
            
            const Divider(color: Colors.white10, height: 40),

            // Lista de Skills
            Expanded(
              child: ListView.builder(
                itemCount: game.skills.length,
                itemBuilder: (context, index) {
                  final skill = game.skills[index];
                  return ListTile(
                    title: Text(skill.name),
                    subtitle: LinearProgressIndicator(value: skill.progressPercentage),
                    trailing: Text("Lvl ${skill.level}"),
                  );
                },
              ),
            ),

            // Botão de ação rápida
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => game.clickToFarm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("TREINAR ATRIBUTOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}