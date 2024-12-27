import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/tab_view/cart/favorite_view.dart';
import 'package:lrm_app/views/tab_view/cart/cart_view.dart';
import 'package:pocketbase/pocketbase.dart';

class ShopDetailView extends StatefulWidget {
  final String shopId;
  ShopDetailView({required this.shopId});

  @override
  State<ShopDetailView> createState() => _ShopDetailViewState();
}

class _ShopDetailViewState extends State<ShopDetailView> {
  int cartCount = 0;
  List<Map<String, dynamic>> favoriteItems = [];
  bool isLoading = true; // Loading state
  List<Map<String, dynamic>> filteredMenuItems = [];
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

  // Declare shopItem to store shop data
  Map<String, dynamic> shopItem = {};

  @override
  void initState() {
    super.initState();
    fetchShopData();
    fetchData(); // Fetch menu data during initialization
  }

  // Fetch a single shop record from PocketBase
  Future<void> fetchShopData() async {
    try {
      final record = await pb.collection('shop').getOne(widget.shopId);
      setState(() {
        shopItem = {
          'id': record.id,
          'shop_name': record.data['shop_name'],
          'location': record.data['location'],
          'description': record.data['description'],
          'thunail_shop': record.data['thunail_shop'],
        };
        isLoading = false; // Stop the loading state once data is fetched
      });
    } catch (e) {
      print('Error fetching shop data: $e');
    }
  }

  // Fetch menu data from PocketBase
  Future<void> fetchData() async {
    try {
      final menuResponse = await pb.collection('menu').getFullList();
      final fetchedMenuData = menuResponse.map((e) {
        return {
          'id': e.data['id'],
          'name': e.data['dish_name'],
          'price': e.data['price'],
          'rating': e.data['rating'],
          'image': e.data['thunail_menu'], // Ensure image is correctly fetched
        };
      }).toList();
      
      setState(() {
        filteredMenuItems = fetchedMenuData;
      });
    } catch (e) {
      log('Error fetching menu data: $e');
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildAppBarActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            _navigateToScreen(FavoriteView(favoriteItems: favoriteItems));
          },
          icon: const Icon(Icons.favorite_border, color: AppColors.textBlack),
        ),
        IconButton(
          onPressed: () {
            _navigateToScreen(const CartView());
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart, color: AppColors.tabsColor),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder for favorite toggle (implement as needed)
  void toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      if (favoriteItems.contains(item)) {
        favoriteItems.remove(item);
      } else {
        favoriteItems.add(item);
      }
    });
  }

  bool isFavorite(Map<String, dynamic> item) {
    return favoriteItems.contains(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileappBarColor, // Light blue background
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const Text(
          'Shop',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAppBarActions(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              '${pb.baseURL}/api/files/shop/${widget.shopId}/${shopItem['thunail_shop']}'), // Use dynamic image from the fetched shop data
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Menu list',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredMenuItems[index];
                        return GestureDetector(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        '${pb.baseURL}/api/files/menu/${item['id']}/${item['image']}', // Use NetworkImage for remote images
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                        onTap: () => toggleFavorite(item),
                                        child: Icon(
                                          isFavorite(item)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite(item)
                                              ? AppColors.markColor
                                              : AppColors.textgrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textBlack,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        item['price']?.toString() ?? 'No Price',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppColors.priceColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, bottom: 1, right: 8, left: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.star,
                                              color: AppColors.markColor,
                                              size: 18),
                                          Text(
                                            item['rating']?.toString() ?? 'No Rating',
                                            style:
                                                const TextStyle(fontSize: 15),
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
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
