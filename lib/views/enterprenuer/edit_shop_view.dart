import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:pocketbase/pocketbase.dart';

class EditShopView extends StatefulWidget {
  final String shopId;

  const EditShopView({Key? key, required this.shopId}) : super(key: key);

  @override
  _EditShopViewState createState() => _EditShopViewState();
}

class _EditShopViewState extends State<EditShopView> {
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? selectedImage;
  String? existingImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  // Fetch the existing shop details, including the thumbnail URL
  Future<void> _fetchShopDetails() async {
    setState(() => isLoading = true);
    try {
      final shop = await pb.collection('shop').getOne(widget.shopId);
      setState(() {
        nameController.text = shop.data['shop_name'] ?? '';
        locationController.text = shop.data['location'] ?? '';
        descriptionController.text = shop.data['description'] ?? '';

        // Construct the full thumbnail URL if it exists
        if (shop.data['thunail_shop'] != null) {
          existingImageUrl =
              '${pb.baseURL}/api/files/shop/${widget.shopId}/${shop.data['thunail_shop']}';
        } else {
          existingImageUrl = null;
        }
      });
    } catch (e) {
      debugPrint('Error fetching shop details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // Update the shop details and thumbnail
  Future<void> _updateShop() async {
    setState(() => isLoading = true);
    try {
      final updatedData = {
        'shop_name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim()
      };

      if (selectedImage != null) {
        await pb.collection('shop').update(
          widget.shopId,
          body: updatedData,
          files: [
            await MultipartFile.fromPath('thunail_shop', selectedImage!.path)
          ],
        );
      } else {
        await pb.collection('shop').update(widget.shopId, body: updatedData);
      }

      Navigator.pop(context, 'Shop updated successfully!');
    } catch (e) {
      debugPrint('Error updating shop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update shop.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Helper method to build text fields for shop details
  Widget _buildTextField(String label,
      {required TextEditingController controller, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      appBar: AppBar(
        title: const Text('Edit Shop'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Shop name',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Location',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: isLoading
                                ? const NetworkImage(
                                    'https://via.placeholder.com/120')
                                : (selectedImage == null
                                    ? NetworkImage('${existingImageUrl}')
                                    : FileImage(selectedImage!)
                                        as ImageProvider),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : null,
                      ),
                    ),
                  ),

                  // Update shop button
                   const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateShop, // Connect the button to updateMenu
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: const Size(150, 50),
                  backgroundColor: AppColors.buttonOK,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, color: AppColors.cartColor),
                ),
              ),
            ),
                ],
              ),
            ),
    );
  }
}
