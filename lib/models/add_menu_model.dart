class DishModel {
  final String dishName;
  final double price;
  final double rating;
  final String description;
  final String shopId;

  DishModel({
    required this.dishName,
    required this.price,
    required this.rating,
    required this.description,
    required this.shopId,
   
  });

  Map<String, dynamic> toMap() {
    return {
      'dish_name': dishName,
      'price': price,
      'rating': rating,
      'description': description,
      'shop_id': shopId,
    };
  }
}
