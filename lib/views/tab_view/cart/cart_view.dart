import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:pocketbase/pocketbase.dart';

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool isLoading = true; // Loading state
  List<Map<String, dynamic>> carts = [];
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    try {
      final result = await fetchCart();
      setState(() {
        carts = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchCart() async {
    try {
      final result = await pb.collection('cart').getFullList();

      // Map the fetched data to the desired format
      return result.map((record) {
        return {
          'id': record.data['id'] as String?,
          'user_id': record.data['user_id'] as String?,
          'menu_id': record.data['menu_id'] as String?,
          'price': (record.data['total_price'] ?? 0).toString(),
          'quantity': (record.data['quantity'] ?? 0).toString(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching cart data: $e');
    }
  }

  void _deleteItem(int index) {
    setState(() {
      carts.removeAt(index); // Remove the item at the given index
    });
  }

  Future<void> _showDeleteConfirmation(int index) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deleteItem(index);
    }
  }

  Future<void> _showCheckoutConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Checkout'),
        content: const Text('Are you sure you want to check out this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      appBar: AppBar(
        backgroundColor: AppColors.profileappBarColor,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : carts.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: AppColors.textBlack),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    final cart = carts[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: cart['image'] != null && cart['image'] != ''
                                ? Image.network(
                                    cart['image']!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Placeholder(
                                    fallbackWidth: 100,
                                    fallbackHeight: 100,
                                  ),
                          ),
                          // Details Section
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cart['name'] ?? 'Unknown Item',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${cart['price']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.priceColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quantity: ${cart['quantity']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions Section
                          Column(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: AppColors.buttonDelete),
                                onPressed: () => _showDeleteConfirmation(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_checkout,
                                    color: AppColors.buttonOK),
                                onPressed: _showCheckoutConfirmation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
