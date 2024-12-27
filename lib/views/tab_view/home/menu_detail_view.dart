import 'dart:developer';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:lrm_app/constant/color.dart';

final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

class MenuDetailView extends StatefulWidget {
  String menuId;

  MenuDetailView({Key? key, required this.menuId}) : super(key: key);

  @override
  _MenuDetailViewState createState() => _MenuDetailViewState();
}

class _MenuDetailViewState extends State<MenuDetailView> {
  Map<String, dynamic>? menuItem;
  bool isLoading = true;
  String? errorMessage;
  double _currentRating = 0.0;
  double _quantity = 1;
  double _totalPrice = 0.0;
  String userId ='yz42e5rz20d60lt';

  @override
  void initState() {
    super.initState();
    fetchMenuItem();
  }

  // Fetch menu item details from PocketBase based on the menuId
  Future<void> fetchMenuItem() async {
    try {
      // Fetch the menu item details by ID from the correct collection
      final response = await pb.collection('menu').getOne(widget.menuId);

      setState(() {
        menuItem = response.data;

        // Update other fields based on the fetched data
        _currentRating = menuItem?['rating']?.toDouble() ?? 0.0;
        _totalPrice = (menuItem?['price']?.toDouble() ?? 0.0) * _quantity;
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching menu item: $e');
      setState(() {
        errorMessage = 'Failed to load menu item';
        isLoading = false;
      });
    }
  }

  // Add item to cart in PocketBase
  Future<void> addToPocketBaseCart() async {
    if (menuItem == null) return;

    try {
      // final token = pb.authStore.token;
      // final jwt = JWT.decode(token);
      // final userId = jwt.payload['id'];

      final data = {
        "dish_id": menuItem!['id'],
        "name": menuItem!['dish_name'],
        "price": menuItem!['price'],
        "userId": userId,
        "quantity": _quantity,
        "total_price": _totalPrice,
        "rating": _currentRating,
      };

      await pb.collection('cart').create(body: data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to PocketBase cart!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding item to cart: $e')),
      );
    }
  }

  // Update the rating based on user input
  void _updateRating(double rating) {
    setState(() {
      _currentRating = rating;
    });
  }

  // Update the quantity of the item
  void _updateQuantity(int delta) {
    setState(() {
      _quantity += delta;
      if (_quantity < 1) _quantity = 1;
      _totalPrice = (menuItem?['price']?.toDouble() ?? 0.0) * _quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: const Text("Error"),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.buttonDelete, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 208, 220),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text(menuItem!['dish_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                '${pb.baseURL}/api/files/menu/${widget.menuId}/${menuItem!['thunail_menu']}',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const SizedBox(height: 20),
              Text(
                'ID: ${menuItem!['id']}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                menuItem!['dish_name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Price: \$${menuItem!['price']}',
                style:
                    const TextStyle(fontSize: 20, color: AppColors.priceColor),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Rating: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.star,
                    color: AppColors.markColor,
                    size: 20,
                  ),
                  Text(
                    _currentRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: AppColors.markColor,
                      size: 30,
                    ),
                    onPressed: () {
                      _updateRating(index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.textFieldground,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove,
                              color: AppColors.textBlack),
                          onPressed: () => _updateQuantity(-1),
                          splashRadius: 20,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.add, color: AppColors.textBlack),
                          onPressed: () => _updateQuantity(1),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.textFieldground,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Center(
                      child: Text(
                        'Total: \$${_totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.priceColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: addToPocketBaseCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(color: AppColors.textBlack),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: AppColors.tabsColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
