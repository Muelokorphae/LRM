import 'package:flutter/material.dart';
import 'package:lrm_app/constant/color.dart';

class OrderService {
  Future<List<Map<String, String>>> fetchedOrder() async {
    // Simulating a network delay
    await Future.delayed(const Duration(seconds: 2));

    // Returning mock cart data
    return [
      {
        'id': '1',
        'name': 'Spaghetti Bolognese',
        'price': '\$12.99',
        'image': 'assets/images/steak_beef.jpeg',
        'quantity': '3',
        'userId': 'aldkflajkladsfa;fdja',
        'username': 'name',
        'address': 'Laos',
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
      },
    ];
  }
}

class OrderView extends StatefulWidget {
  const OrderView({Key? key}) : super(key: key);

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  bool isLoading = true; // Loading state
  List<Map<String, String>> orders = [];

  final OrderService orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _loadCart(); // Load the cart data
  }

  // Fetch cart data using the CartService
  Future<void> _loadCart() async {
    try {
      final fetchedOrder = await orderService.fetchedOrder();
      setState(() {
        orders = fetchedOrder;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );
    }
  }

  // Function to delete an item from the cart
  void _deleteItem(int index) {
    setState(() {
      orders.removeAt(index); // Remove the item at the given index
    });
  }

  // Show confirmation dialog for delete
  Future<void> _showDeleteConfirmation(int index) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deleteItem(index);
    }
  }

  // Show confirmation dialog for checkout
  Future<void> _showCheckoutConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Checkout'),
        content: const Text('Are you sure you want to confirm this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirmation completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Text(
                    'Your Order is empty',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical:3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image Section
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.asset(
                              order['image']!,
                              width: 125,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Details Section
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  Text(
                                    order['price']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.priceColor,
                                    ),
                                  ),
                                
                                  Text(
                                    'Quantity: ${order['quantity']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(
                                    'User: ${order['username']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                               
                                  Text(
                                    'Address: ${order['address']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions Section (Delete and Checkout Buttons)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmation(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart_checkout, color: Colors.green),
                                  onPressed: _showCheckoutConfirmation,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
