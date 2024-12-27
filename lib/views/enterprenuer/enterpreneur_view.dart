import 'package:flutter/material.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/tab_view/cart/favorite_view.dart';
import 'package:lrm_app/views/enterprenuer/add_menu_view.dart';
import 'package:lrm_app/views/enterprenuer/add_shop_view.dart';
import 'package:lrm_app/views/enterprenuer/menu_view.dart';
import 'package:lrm_app/views/enterprenuer/order_view.dart';
import 'package:lrm_app/views/tab_view/cart/cart_view.dart';

class EnterpreneurView extends StatefulWidget {
  const EnterpreneurView({super.key});

  @override
  State<EnterpreneurView> createState() => _EnterpreneurViewState();
}

class _EnterpreneurViewState extends State<EnterpreneurView> {
  int selectedTabIndex = 0;
  int cartCount = 3; // Cart item count placeholder
  final List<String> tabs = ["Menu", "Order", "Add","Add & Edit Shop"];
  List<Map<String, dynamic>> favoriteItems = [];

  @override
  void dispose() {
    super.dispose();
  }

  // Method to handle navigation for app bar icons
  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Method to get AppBar actions (icons)
  Widget _buildAppBarActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Favorite Icon
        IconButton(
          onPressed: () {
            _navigateToScreen(FavoriteView(favoriteItems: favoriteItems));
          },
          icon: const Icon(Icons.favorite_border, color: Colors.black),
        ),
        // New Dishes Icon
        // Cart Icon with dynamic count
        IconButton(
          onPressed: () {
            _navigateToScreen(const CartView());
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart, color: Colors.blue),
              if (cartCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAppBarActions(), // Using the method to build app bar actions
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: selectedTabIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (selectedTabIndex == index)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            height: 2,
                            width: 20,
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: selectedTabIndex,
              children: [
                MenuView(),
                OrderView(),
                AddView(),
                AddShopView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
