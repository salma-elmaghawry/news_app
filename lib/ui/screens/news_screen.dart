import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/ui/widgets/article_card.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late NewsService newsService;
  late ScrollController scrollController;
  String selectedCategory = 'Top News';

  //
  // PAGINATION VARIABLES (STEP 1)

  int currentPage = 1;
  final int pageSize = 10;
  int totalResults = 0;
  List<Article> articles = [];
  bool hasMore = true;
  bool isLoadingMore = false;

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

    // STEP 2 & 3: INITIALIZE SCROLL CONTROLLER & LOAD FIRST PAGE
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Load first page when screen opens
    fetchFirstPage();
  }

  // STEP 4: DETECT SCROLL POSITION
  void _onScroll() {
    double currentScroll = scrollController.position.pixels;
    double maxScroll = scrollController.position.maxScrollExtent;

    // If user scrolled within 300 pixels of bottom, load next page
    if (currentScroll >= (maxScroll - 300) && hasMore && !isLoadingMore) {
      print('✓ User reached near bottom! Loading next page...');
      fetchNextPage();
    }
  }

  // STEP 5: FETCH FIRST PAGE
  Future<void> fetchFirstPage() async {
    print('\n📍 LOADING FIRST PAGE');
    print('=================================');

    setState(() {
      articles.clear();
      currentPage = 1;
      isLoadingMore = false;
    });

    try {
      final response = await _fetchArticlesResponse(selectedCategory, 1);
      setState(() {
        articles = response.articles;
        totalResults = response.totalResults;
        print('✓ Loaded ${articles.length} articles');
        print('  Total available: $totalResults');
      });
    } catch (e) {
      print('❌ Error loading first page: $e');
      setState(() {
        articles = [];
      });
    }
  }

  // STEP 6: FETCH NEXT PAGE (Triggered by scroll)
  Future<void> fetchNextPage() async {
    if (isLoadingMore) return;
    if (!hasMore) return;

    print('\n📍 LOADING NEXT PAGE');
    print('=================================');

    setState(() {
      isLoadingMore = true;
      print('⏳ Loading page ${currentPage + 1}...');
    });

    try {
      int nextPage = currentPage + 1;
      final response = await _fetchArticlesResponse(selectedCategory, nextPage);

      setState(() {
        articles.addAll(response.articles); // Append to list!
        currentPage = nextPage;
        isLoadingMore = false;

        print('✓ Loaded ${response.articles.length} more articles');
        print('  Total loaded: ${articles.length}');

        // Check if we've reached the end
        if (articles.length >= totalResults) {
          hasMore = false;
          print('✓ Reached end! No more pages.');
        }
      });
    } catch (e) {
      print('❌ Error loading next page: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  // Helper method to fetch articles
  Future<dynamic> _fetchArticlesResponse(String category, int page) async {
    if (category == 'Top News') {
      return await newsService.fetchTopHeadlines(
        country: 'us',
        page: page,
        pageSize: pageSize,
      );
    } else {
      return await newsService.fetchArticlesByCategory(
        category: category.toLowerCase(),
        page: page,
        pageSize: pageSize,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
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
                    // Reset pagination when category changes
                    fetchFirstPage();
                  });
                },
              ),
            ),

            Expanded(
              child: articles.isEmpty && !isLoadingMore
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.newspaper, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No articles found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: articles.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at bottom
                        if (index == articles.length) {
                          return Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                                SizedBox(height: 8),
                                Text('Loading more articles...'),
                              ],
                            ),
                          );
                        }

                        // Show article
                        return ArticleCardWidget(article: articles[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
