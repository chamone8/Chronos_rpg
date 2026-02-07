import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class MerchantScreen extends StatelessWidget {
  const MerchantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return DefaultTabController(
      length: 2, // Duas abas: Vender e Comprar
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("O MERCADOR", style: TextStyle(letterSpacing: 3)),
          backgroundColor: Colors.black,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.sell), text: "VENDER"),
              Tab(icon: Icon(Icons.shopping_cart), text: "UPGRADES"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSellTab(context, game),
            _buildUpgradeTab(context, game),
          ],
        ),
      ),
    );
  }

  // --- ABA 1: VENDA DE RECURSOS ---
  Widget _buildSellTab(BuildContext context, GameProvider game) {
    final double potentialGain = game.totalInventoryValue;
    final itemsToSell = game.inventory.entries.where((e) => e.value > 0).toList();

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "OURO ATUAL: ${game.player.gold.toStringAsFixed(0)}G",
          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: itemsToSell.isEmpty
              ? const Center(child: Text("Nada para vender...", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: itemsToSell.length,
                  itemBuilder: (context, index) {
                    final entry = itemsToSell[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2, color: Colors.blueGrey),
                      title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                      trailing: Text("x${entry.value}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ),
        _buildActionButton(
          label: "VENDER TUDO (+${potentialGain.toStringAsFixed(0)}G)",
          onPressed: potentialGain > 0 ? () => game.sellAllResources() : null,
          color: Colors.green[700]!,
        ),
      ],
    );
  }

  // --- ABA 2: COMPRA DE UPGRADES ---
  Widget _buildUpgradeTab(BuildContext context, GameProvider game) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: game.shopUpgrades.length,
            itemBuilder: (context, index) {
              final upgrade = game.shopUpgrades[index];
              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: upgrade.isOwned ? Colors.green : Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(upgrade.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(upgrade.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: upgrade.isOwned
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: game.player.gold >= upgrade.price 
                              ? () => game.buyUpgrade(index) 
                              : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                          child: Text("${upgrade.price.toStringAsFixed(0)}G"),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para botões de ação na base
  Widget _buildActionButton({required String label, required VoidCallback? onPressed, required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          disabledBackgroundColor: Colors.grey[800],
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}