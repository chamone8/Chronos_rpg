class Resource {
  final String id;
  final String name;
  final double basePrice; // Preço de venda no Mercador
  final String category; // 'Minério', 'Peixe', 'Madeira', 'Drop'
  int quantity;

  Resource({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.category,
    this.quantity = 0,
  });
}