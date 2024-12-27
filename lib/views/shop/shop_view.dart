import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/constant/color.dart'; // Ensure this file exists and defines AppColors
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase SDK
import 'package:lrm_app/views/tab_view/cart/favorite_view.dart';
import 'package:lrm_app/views/shop/shop_detail_view.dart';
import 'package:lrm_app/views/tab_view/cart/cart_view.dart';

class ShopView extends StatefulWidget {
  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  bool isLoading = true;
  int cartCount = 3;
  List<Map<String, dynamic>> shopItems =
      []; // This will hold the fetched shop data
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

  // Initialize PocketBase and fetch data
  @override
  void initState() {
    super.initState();
    fetchShopData();
  }

  // Fetch data from PocketBase
  Future<void> fetchShopData() async {
    try {
      final records = await pb.collection('shop').getFullList();
      setState(() {
        shopItems = records.map((record) {
          return {
            'id': record.id,
            'shop_name': record.data['shop_name'],
            'location': record.data['location'],
            'description': record.data['description'],
            'thunail_shop': record.data['thunail_shop'],
          };
        }).toList();
        isLoading = false; // Stop the loading state once data is fetched
      });
    } catch (e) {
      print('Error fetching shop data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildAppBarActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () {
            _navigateToScreen(
                FavoriteView(favoriteItems: [])); // Example favoriteItems
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
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.buttonDelete,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 12, color: AppColors.textBlack),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const Text(
          'Shop',
          style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopItems.isEmpty
              ? const Center(
                  child: Text(
                    'No Items Available',
                    style: TextStyle(fontSize: 18, color: AppColors.textgrey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: shopItems.length,
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailView(shopId: item['id']),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.cartColor,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  '${pb.baseURL}/api/files/shop/${item['id']}/${item['thunail_shop']}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['shop_name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item['description'] ?? 'No description',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textgrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
