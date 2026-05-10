import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';

/// Widget to display loading state
class NewsLoadingState extends StatelessWidget {
  const NewsLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}
