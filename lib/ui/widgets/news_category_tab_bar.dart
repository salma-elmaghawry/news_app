import 'package:flutter/material.dart';
import 'package:news_app/core/app_colors.dart';

/// TabBar widget for news categories
class NewsCategoryTabBar extends StatelessWidget {
  final List<String> categories;
  final Function(int) onCategoryChanged;

  const NewsCategoryTabBar({
    Key? key,
    required this.categories,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.blue[900],
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: onCategoryChanged,
        tabs: List.generate(
          categories.length,
          (index) => Tab(text: categories[index]),
        ),
      ),
    );
  }
}
