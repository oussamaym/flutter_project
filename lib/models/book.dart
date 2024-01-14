class Book {
  final String id;
  final String title;
  final String author;
  final double price;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
  });

  factory Book.fromMap(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }
}
