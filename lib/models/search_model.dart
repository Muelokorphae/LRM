class SearchItem {
  final String id;
  final String name;
  final String image;
  final String price;
  final SearchItemType type;

  SearchItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.type,
  });
}

enum SearchItemType { shop, dish }