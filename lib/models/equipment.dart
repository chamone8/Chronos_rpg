enum EquipmentSlot { 
  helmet,    // Capacete
  armor,     // Peitoral
  leggings,  // Calça
  boots,     // Botas
  weapon,    // Arma
  ring,      // Anel
  potionHP,  // Poção de Sangue
  potionMP   // Poção de Mana
}
class Equipment {
  final String name;
  final EquipmentSlot slot;
  final int strengthBonus;
  final int defenseBonus;
  final String iconPath;

  Equipment({
    required this.name,
    required this.slot,
    this.strengthBonus = 0,
    this.defenseBonus = 0,
    this.iconPath = "",
  });
}