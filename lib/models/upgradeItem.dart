class UpgradeItem {
  final String name;
  final String description;
  final double price;
  final String targetSkill; // 'Mineração', 'Pesca', etc.
  bool isOwned;

  UpgradeItem({
    required this.name, 
    required this.description, 
    required this.price, 
    required this.targetSkill,
    this.isOwned = false,
  });
}