import 'package:news_app/models/article.dart';

class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  // Factory to convert JSON to NewsResponse
  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    List<Article> articles = [];
    if (json['articles'] != null) {
      for (var article in json['articles']) {
        articles.add(Article.fromJson(article));
      }
    }

    return NewsResponse(
      status: json['status'] ?? 'unknown',
      totalResults: json['totalResults'] ?? 0,
      articles: articles,
    );
  }
}
