import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/ui/widgets/news_category_tab_bar.dart';
import 'package:news_app/ui/widgets/news_list_view.dart';
import 'package:news_app/ui/widgets/news_loading_state.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // ==================== SERVICES & CONTROLLERS ====================
  late NewsService newsService;
  late ScrollController scrollController;

  // ==================== UI STATE ====================
  String selectedCategory = 'Top News';

  final List<String> categories = [
    'Top News',
    'Sports',
    'Business',
    'Technology',
    'Entertainment',
  ];

  // ==================== pagination variables ====================
  int currentPage = 1;
  final int pageSize = 10;
  int totalResults = 0;
  List<Article> articles = [];
  bool hasMore = true;
  bool isLoadingNextPage = false;

  // ==================== INITIALIZATION ====================
  @override
  void initState() {
    super.initState();
    newsService = NewsService();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    fetchFirstPage();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // ==================== SCROLL DETECTION ====================
  /// Detects when user scrolls 300px from bottom and loads next page
  void _onScroll() {
    double currentScroll = scrollController.position.pixels;
    double maxScroll = scrollController.position.maxScrollExtent;

    // Trigger loading when within 300px of bottom
    bool isNearBottom = currentScroll >= (maxScroll - 300);

    if (isNearBottom && hasMore && !isLoadingNextPage) {
      print('User scrolled near bottom - Loading next page...');
      fetchNextPage();
    }
  }

  // ==================== API CALLS ====================
  /// Fetches articles from API based on selected category
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

  // ==================== PAGINATION METHODS ====================
  /// Fetches the first page of articles for the selected category
  /// Clears previous data and resets pagination
  Future<void> fetchFirstPage() async {
    _resetPagination();

    try {
      final response = await _fetchArticlesResponse(selectedCategory, 1);
      _updateArticles(response.articles, response.totalResults);
    } catch (e) {
      print('Error loading first page: $e');
      setState(() {
        articles = [];
      });
    }
  }

  /// Fetches the next page of articles when user scrolls near bottom
  /// Appends articles to existing list (infinite scroll)
  Future<void> fetchNextPage() async {
    // Guard clauses: prevent duplicate requests
    if (isLoadingNextPage) {
      print('Already loading next page, ignoring request');
      return;
    }
    if (!hasMore) {
      print('All articles loaded, no more pages');
      return;
    }
    setState(() {
      isLoadingNextPage = true;
    });

    try {
      int nextPage = currentPage + 1;
      final response = await _fetchArticlesResponse(selectedCategory, nextPage);

      _appendArticles(response.articles, nextPage, response.totalResults);
    } catch (e) {
      print('Error loading next page: $e');
      setState(() {
        isLoadingNextPage = false;
      });
    }
  }

  // ==================== PAGINATION METHODS ====================
  /// Resets all pagination variables to initial state
  void _resetPagination() {
    setState(() {
      articles.clear();
      currentPage = 1;
      isLoadingNextPage = false;
      hasMore = true;
      totalResults = 0;
    });
  }

  /// Updates UI with new articles and total count
  void _updateArticles(List<Article> newArticles, int total) {
    setState(() {
      articles = newArticles;
      totalResults = total;
      print('Loaded ${articles.length} articles from API');
    });
  }

  /// Appends new articles to list and checks if pagination complete
  void _appendArticles(List<Article> newArticles, int nextPage, int total) {
    setState(() {
      articles.addAll(newArticles); // Append, don't replace!
      currentPage = nextPage;
      isLoadingNextPage = false;

      // Check if we've loaded all available articles
      if (articles.length >= total) {
        hasMore = false;
        print('Reached end! All ${articles.length} articles loaded.');
      } else {
        print('Loaded ${articles.length}/$total articles');
      }
    });
  }

  // ==================== UI BUILD ====================
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
            NewsCategoryTabBar(
              categories: categories,
              onCategoryChanged: (index) {
                setState(() {
                  selectedCategory = categories[index];
                  fetchFirstPage();
                });
              },
            ),
            // FUTURE BUILDER WITH PAGINATION & REFRESH
            Expanded(
              child: FutureBuilder<dynamic>(
                future: articles.isEmpty
                    ? _fetchArticlesResponse(selectedCategory, 1)
                    : Future.value(null),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: NewsLoadingState());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData) {
                    final response = snapshot.data;
                    if (response != null && articles.isEmpty) {
                      setState(() {
                        articles = response.articles;
                        totalResults = response.totalResults;
                      });
                    }
                  }

                  if (articles.isEmpty) {
                    return Center(child: Text('No articles found'));
                  }

                  return RefreshIndicator(
                    onRefresh: fetchFirstPage,
                    color: AppColors.primaryColor,
                    child: NewsListView(
                      articles: articles,
                      scrollController: scrollController,
                      isLoadingNextPage: isLoadingNextPage,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
