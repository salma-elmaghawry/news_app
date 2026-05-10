import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';
import 'package:news_app/models/article_model.dart';
import 'package:news_app/ui/widgets/article_card.dart';

/// ListView widget for displaying articles with pagination
class NewsListView extends StatelessWidget {
  final List<Article> articles;
  final ScrollController scrollController;
  final bool isLoadingNextPage;

  const NewsListView({
    Key? key,
    required this.articles,
    required this.scrollController,
    required this.isLoadingNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: articles.length + (isLoadingNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at bottom
        if (index == articles.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        // Show article
        return ArticleCardWidget(article: articles[index]);
      },
    );
  }
}
