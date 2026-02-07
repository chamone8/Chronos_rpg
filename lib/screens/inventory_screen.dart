import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    // Filtramos apenas itens que o jogador realmente possui (quantidade > 0)
    final itemsOwned = game.inventory.entries
        .where((entry) => entry.value > 0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MOCHILA"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Resumo de Ouro no topo do inventário
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 10),
                Text(
                  "${game.player.gold.toStringAsFixed(0)} OURO",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: itemsOwned.isEmpty
                ? const Center(
                    child: Text(
                      "Sua mochila está vazia...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 itens por linha
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: itemsOwned.length,
                    itemBuilder: (context, index) {
                      final itemKey = itemsOwned[index].key;
                      final quantity = itemsOwned[index].value;
                      Color _getRarityColor(String itemKey) {
                        if (itemKey.contains('ouro')) return Colors.amber;
                        if (itemKey.contains('carvao'))
                          return Colors.purpleAccent;
                        if (itemKey.contains('ferro')) return Colors.blueGrey;
                        return Colors.white70;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRarityColor(itemKey).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              color: Colors.blueGrey,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              itemKey.replaceAll('_', ' ').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "x$quantity",
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Botão para Vender Tudo (O Mercador)
          if (itemsOwned.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => _showSellConfirmation(context, game),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("VENDER TUDO PARA O MERCADOR"),
              ),
            ),
        ],
      ),
    );
  }

  void _showSellConfirmation(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vender itens?"),
        content: const Text(
          "O Mercador comprará todos os seus recursos por ouro.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () {
              game.sellAllResources();
              Navigator.pop(context);
            },
            child: const Text("VENDER", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
