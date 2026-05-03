import 'package:dio/dio.dart';
import 'package:news_app/models/article.dart';

class NewsService {
  late Dio dio;
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey =
      'cd8ebc8ba0c549788bffa0647702502f'; // Get from newsapi.org

  NewsService() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
  }
  //  Send Request & Receive Response
  Future<List<Article>> fetchTopHeadlines({required String country}) async {
    try {
      // STEP 1: Send HTTP GET Request
      final response = await dio.get(
        '/top-headlines',
        queryParameters: {
          'country': country, // e.g., 'us', 'gb', 'in'
          'apiKey': apiKey,
        },
      );
      if (response.statusCode == 200) {
        //  Decode JSON (DIO does this automatically!)
        // Get articles list from response
        List<dynamic> articlesJson = response.data['articles'];
        //Convert JSON to Article Model
        List<Article> articles = [];
        for (var json in articlesJson) {
          articles.add(Article.fromJson(json));
        }
        // Return (Store) the articles
        return articles;
      } else {
        throw Exception('Failed to load headlines: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error: ${e.message}');
      return [];
    }
  }
}
