
class Article {
  final String title;
  final String author;
  final String description;
  final String urlToImage;
  final String publishedAt;

  Article({
    required this.title,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.publishedAt,
  });

  // Factory to convert JSON to Article 
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      author: json['author'] ?? 'Unknown',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}

