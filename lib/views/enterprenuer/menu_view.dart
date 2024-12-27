import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/enterprenuer/edit_view.dart';
import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';

class MenuView extends StatefulWidget {
  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  bool isLoading = false;
  List<Map<String, dynamic>> allItems = [];
  final PocketBase pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  final Dio dio = Dio(BaseOptions(
    baseUrl: dotenv.env['POCKETBASE_URL']!,
  ));

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch menu items from the API
      final menuResponse = await dio.get('/api/collections/menu/records');
      final menuRecords = menuResponse.data['items'] as List<dynamic>;

      // Fetch shop details
      final shopResponse = await dio.get('/api/collections/shop/records');
      final shopRecords = shopResponse.data['items'] as List<dynamic>;

      // Create a mapping of shop_id to shop details for quick lookup
      final shopDetailsMap = {
        for (var shop in shopRecords)
          shop['id']: {
            'shop_name': shop['shop_name'] ?? 'Unknown Shop',
            'address': shop['address'] ?? 'No Address',
          }
      };

      // Combine menu items with their respective shop details
      final fetchedItems = menuRecords.map<Map<String, dynamic>>((record) {
        final shopDetails = shopDetailsMap[record['shop_id']] ?? {};
        return {
          'id': record['id'],
          'name': record['dish_name'] ?? 'Unnamed Dish',
          'price': '\$${record['price'] ?? '0.0'}',
          'rating': (record['rating'] ?? 0).toDouble(),
          // 'description': record['description'] ?? 'No description',
          'image': record['thunail_menu'] ?? 'https://via.placeholder.com/120',
          'shopid': record['shop_id'] ?? '',
          'shop_name': shopDetails['shop_name'] ?? 'Unknown Shop',
          'address': shopDetails['address'] ?? 'No Address',
        };
      }).toList();

      setState(() {
        allItems = fetchedItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching menu or shop items: $error');
    }
  }

  void _navigateToEditPage(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditView(item: item),
      ),
    ).then((updatedItem) {
      if (updatedItem != null) {
        setState(() {
          final index = allItems
              .indexWhere((menuItem) => menuItem['id'] == updatedItem['id']);
          if (index != -1) {
            allItems[index] = updatedItem;
          }
        });
      }
    });
  }

  void _deleteItem(BuildContext context, String itemId, int index) async {
    try {
      setState(() {
        isLoading = true;
      });

      // Make a delete request to the backend
      await dio.delete('/api/collections/menu/records/$itemId');

      // Remove the item from the local list
      setState(() {
        allItems.removeAt(index);
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $error')),
      );
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, String itemName, String itemId, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to delete $itemName?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteItem(context, itemId, index); // Call delete function
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.buttonDelete),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Just close the dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.buttonCancel),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : allItems.isEmpty
              ? const Center(
                  child: Text(
                    'No Items Available',
                    style: TextStyle(fontSize: 18, color: AppColors.textgrey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: allItems.length,
                  itemBuilder: (context, index) {
                    final item = allItems[index];
                    return Card(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '${pb.baseURL}/api/files/menu/${item['id']}/${item['image']}',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['price'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.priceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.markColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['rating']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['shop_name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _navigateToEditPage(context, item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.buttonDelete,
                                  ),
                                  onPressed: () => _showDeleteConfirmation(
                                      context, item['name'], item['id'], index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
