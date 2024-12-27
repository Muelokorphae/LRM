import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart'; // Import image picker
import 'dart:io';

import 'package:lrm_app/constant/color.dart';
import 'package:pocketbase/pocketbase.dart';

class EditView extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditView({Key? key, required this.item}) : super(key: key);

  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _descriptionController;
  File? _imageFile;
  bool _isLoading = false;


  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name']);
    _priceController =
        TextEditingController(text: widget.item['price'].toString());
    _ratingController =
        TextEditingController(text: widget.item['rating'].toString());
    _descriptionController =
        TextEditingController(text: widget.item['description'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateMenu() async {
    setState(() => _isLoading = true);
    try {
      final updatedData = {
        'dish_name': _nameController.text,
        'price': _priceController.text,
        'rating': _ratingController.text,
        'description': _descriptionController.text,
      };

      if (_imageFile != null) {
        await pb.collection('menu').update(
          widget.item['id'],
          body: updatedData,
          files: [
            await MultipartFile.fromPath('thunail_menu', _imageFile!.path),
          ],
        );
      } else {
        await pb.collection('menu').update(
              widget.item['id'],
              body: updatedData,
            );
      }

      Navigator.pop(context, 'Shop updated successfully!');
    } catch (e) {
      debugPrint('Error updating shop: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update shop.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundcColor,
      appBar: AppBar(title: const Text('Edit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: _isLoading
                          ? const NetworkImage('https://via.placeholder.com/120')
                          : (_imageFile == null
                              ? NetworkImage(
                                  '${pb.baseURL}/api/files/menu/${widget.item['id']}/${widget.item['image']}'
                                 
                              )
                              : FileImage(_imageFile!) as ImageProvider),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Item Name',
                fillColor: Colors.white,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Price',
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
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rating',
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
            TextField(
              controller: _descriptionController,
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateMenu, // Connect the button to updateMenu
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
