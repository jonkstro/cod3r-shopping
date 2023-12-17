class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    // Vai iniciar favorito como falso
    this.isFavorite = false,
  });

  // Método que vai alternar o favorito
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
