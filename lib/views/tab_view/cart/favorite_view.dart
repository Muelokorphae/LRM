import 'package:flutter/material.dart';
import 'package:lrm_app/constant/color.dart';

class FavoriteView extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;

  const FavoriteView({super.key, required this.favoriteItems});

  @override
  _FavoriteViewState createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a delay to fetch the data
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false; // Data fetching is complete
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      appBar: AppBar(
        backgroundColor: AppColors.profileappBarColor,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Loading indicator
            )
          : widget.favoriteItems.isEmpty
              ? const Center(
                  child: Text(
                    "Empty",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textgrey,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: widget.favoriteItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.favoriteItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Item Image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              child: Image.asset(
                                item['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Item Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlack,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item['price'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.buttonOK,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: AppColors.markColor, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          item['rating'].toString(),
                                          style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Favorite Icon
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.favorite,
                                color: AppColors.markColor,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FavoriteView(
      favoriteItems: [
        {
          'id': '1',
          'name': 'Spaghetti Bolognese',
          'price': '\$12.99',
          'image': 'assets/images/steak_beef.jpeg',
          'quantity': '3',
          'userId': 'aldkflajkladsfa;fdja',
          'username': 'name',
          'address': 'Laos',
          'rating': 4.5,
        },
        {
          'id': '2',
          'name': 'Cheeseburger',
          'price': '\$9.99',
          'image': 'assets/images/food.jpg',
          'quantity': '2',
          'userId': 'aldkflajkl;fdja',
          'username': 'name',
          'address': 'Laos',
          'rating': 4.3,
        },
        {
          'id': '3',
          'name': 'Caesar Salad',
          'price': '\$7.99',
          'image': 'assets/images/selmon_salad.jpeg',
          'quantity': '1',
          'userId': 'aldkflafsfs;fdja',
          'username': 'name',
          'address': 'Laos',
          'rating': 4.1,
        },
      ],
    ),
  ));
}
