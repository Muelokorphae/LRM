import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/tab_view/cart/favorite_view.dart';
import 'package:lrm_app/views/tab_view/cart/cart_view.dart';
import 'package:lrm_app/views/tab_view/home/menu_detail_view.dart'; 
import 'package:pocketbase/pocketbase.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int selectedTabIndex = 0;
  int currentImageIndex = 0;
  Timer? timer;
  int cartCount = 3;

  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredMenuItems = [];
  List<Map<String, dynamic>> favoriteItems = [];
  List<Map<String, dynamic>> shopData = []; 

  Future<void> fetchData() async {
    final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

    try {
      final shopResponse = await pb.collection('shop').getFullList();
      final fetchedShopData = shopResponse.map((e) {
        return {
          'id': e.data['id'],
          'name': e.data['shop_name'],
          'image': e.data['thunail_shop'],
        };
      }).toList();

      final menuResponse = await pb.collection('menu').getFullList();
      final fetchedMenuData = menuResponse.map((e) {
        return {
          'id': e.data['id'],
          'name': e.data['dish_name'],
          'price': e.data['price'],
          'rating': e.data['rating'],
          'image': e.data['thunail_menu'],
        };
      }).toList();

      setState(() {
        shopData = fetchedShopData;
        filteredMenuItems = fetchedMenuData;
      });

      startImageSlider();
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  void startImageSlider() {
    if (filteredMenuItems.isNotEmpty) {
      timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
        if (mounted) {
          setState(() {
            currentImageIndex = (currentImageIndex + 1) % filteredMenuItems.length;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    timer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void filterMenuItems(String query) {
    setState(() {
      filteredMenuItems = filteredMenuItems
          .where((item) =>
              item['name']?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    });
  }

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
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: filterMenuItems,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.textFieldground,
                        hintText: "Search foods and shop",
                        prefixIcon: const Icon(Icons.search, color: AppColors.textgrey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteView(favoriteItems: favoriteItems),
                        ),
                      );
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
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: filteredMenuItems.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          '${PocketBase(dotenv.env['POCKETBASE_URL']!).baseURL}/api/files/menu/${filteredMenuItems[currentImageIndex]['id']}/${filteredMenuItems[currentImageIndex]['image']}',
                        ),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 8),
            child: const Text(
              "Shop",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: shopData.length,
              itemBuilder: (context, index) {
                final shop = shopData[index];
                final shopName = shop['name'] ?? 'Shop Name';
                final displayName = shopName.length > 5 ? shopName.substring(0, 5) : shopName;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.textgrey,
                          backgroundImage: NetworkImage(
                              '${PocketBase(dotenv.env['POCKETBASE_URL']!).baseURL}/api/files/shop/${shop['id']}/${shop['image']}'),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 14),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenuItems[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuDetailView(menuId: item['id']),
                            ),
                          );
                        },
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
                                      '${PocketBase(dotenv.env['POCKETBASE_URL']!).baseURL}/api/files/menu/${item['id']}/${item['image']}',
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
                                        isFavorite(item) ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite(item) ? AppColors.markColor : AppColors.textgrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                padding: const EdgeInsets.only(top: 0, bottom: 1, right: 8, left: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                      color: AppColors.markColor,
                                    ),
                                    Text(
                                      item['rating']?.toString() ?? 'No Rating',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
