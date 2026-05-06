import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/widgets/article_card.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late NewsService newsService;
  String selectedCategory = 'Top News';

  final List<String> categories = [
    'Top News',
    'Sports',
    'Business',
    'Technology',
    'Entertainment',
  ];

  @override
  void initState() {
    super.initState();
    newsService = NewsService();
  }

  Future<List<Article>> fetchArticles(String category) async {
    if (category == 'Top News') {
      return await newsService.fetchTopHeadlines(country: 'us');
    } else {
      return await newsService.fetchArticlesByCategory(
        category: category.toLowerCase(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Easy News', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: AppColors.primaryColor,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.blue[900],
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: 'Top News'),
                  Tab(text: 'Sports'),
                  Tab(text: 'Business'),
                  Tab(text: 'Technology'),
                  Tab(text: 'Entertainment'),
                ],
                onTap: (index) {
                  setState(() {
                    selectedCategory = categories[index];
                  });
                },
              ),
            ),
            // Content with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: fetchArticles(selectedCategory),
                builder: (context, snapshot) {
                  // State 1: WAITING → Show loading indicator
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 16),
                          Text('Loading articles...'),
                        ],
                      ),
                    );
                  }

                  // State 2: ERROR → Display error message
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }

                  // State 3: DONE → Data successfully loaded
                  if (snapshot.hasData) {
                    final articles = snapshot.data ?? [];

                    if (articles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.newspaper, size: 50, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No articles found'),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        return ArticleCardWidget(article: articles[index]);
                      },
                    );
                  }
                  // Default fallback state
                  return Center(child: Text('No data available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
