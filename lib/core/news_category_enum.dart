enum NewsCategory {
  topNews('Top News'),
  sports('Sports'),
  business('Business'),
  technology('Technology'),
  entertainment('Entertainment');

  final String label;
  const NewsCategory(this.label);
}