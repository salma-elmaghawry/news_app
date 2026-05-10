import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/models/news_response_model.dart';

class NewsService {
  late Dio dio;
  static const String baseUrl = 'https://newsapi.org/v2';
  static String apiKey = dotenv.env['apiKey']!;

  NewsService() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
  }
  // Fetch top headlines with pagination
  Future<NewsResponse> fetchTopHeadlines({
    required String country,
    required int page,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        '/top-headlines',
        queryParameters: {
          'country': country,
          'page': page,
          'pageSize': pageSize,
          'apiKey': apiKey,
        },
      );
      if (response.statusCode == 200) {
        // Convert entire response to NewsResponse model
        return NewsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load headlines: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      rethrow;
    }
  }

  /// Fetch articles by category with pagination
  Future<NewsResponse> fetchArticlesByCategory({
    required String category,
    required int page,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        '/top-headlines',
        queryParameters: {
          'category': category,
          'page': page,
          'pageSize': pageSize,
          'apiKey': apiKey,
        },
      );
      if (response.statusCode == 200) {
        return NewsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      rethrow;
    }
  }
}
