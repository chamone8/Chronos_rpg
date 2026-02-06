import 'package:flutter/material.dart';

class OfflineDialog extends StatelessWidget {
  final int seconds;
  final double goldGained;

  const OfflineDialog({
    super.key, 
    required this.seconds, 
    required this.goldGained
  });

  @override
  Widget build(BuildContext context) {
    // Formata o tempo de forma amigável
    Duration duration = Duration(seconds: seconds);
    String timeText = "${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s";

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amber, width: 0.5)),
      title: const Text(
        "BEM-VINDO DE VOLTA",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_toggle_off, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            "Você esteve ausente por:",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          Text(
            timeText,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                "+ ${goldGained.toStringAsFixed(0)} Ouro",
                style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("COLETAR RECOMPENSAS", style: TextStyle(color: Colors.amber)),
        ),
      ],
    );
  }
}