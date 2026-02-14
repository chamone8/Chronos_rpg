import 'package:flutter/material.dart';
import '../models/skill.dart'; // Ajuste o import conforme seu projeto

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;
  final bool isActive;
  final Widget? leading; // 1. Adicione este campo

  const SkillCard({
    super.key,
    required this.skill,
    required this.onTap,
    required this.isActive,
    this.leading, // 2. Adicione ao construtor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive ? Colors.blueGrey[900] : Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        // 3. Use o widget leading aqui
        leading: leading, 
        title: Text(
          skill.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Nível ${skill.level}"), // Exemplo de subtítulo
        trailing: isActive 
          ? const Icon(Icons.play_arrow, color: Colors.greenAccent) 
          : null,
      ),
    );
  }
}