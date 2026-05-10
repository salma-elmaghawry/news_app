import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/core/app_colors.dart';
import 'package:news_app/models/article_model.dart';

class ArticleCardWidget extends StatelessWidget {
  final Article article;

  const ArticleCardWidget({Key? key, required this.article}) : super(key: key);

  /// Opens the article URL in external browser
  Future<void> openArticleUrl(String url) async {
    print('Attempting to open URL: $url');

    if (url.isEmpty) {
      print('Error: URL is empty');
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      // Try to launch without checking first
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('URL opened successfully');
      } else {
        print('Could not launch URL: $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _handleCardTap(BuildContext context) {
    openArticleUrl(article.url);

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening article...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleCardTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: article.urlToImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.urlToImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/no_news_image.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/no_news_image.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            // Article Content
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // Description
                  Text(
                    article.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 10),

                  // Author and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'By ${article.author}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        article.publishedAt.split('T')[0],
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
