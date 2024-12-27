import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lrm_app/models/add_menu_model.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as PATH;

class AddViewModel extends ChangeNotifier {
  final PocketBase pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  File? selectedImage;
  bool isLoading = false;

  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController dishNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> addDish(BuildContext context, String shopId) async {
    isLoading = true;
    notifyListeners();

    final dish = DishModel(
      dishName: dishNameController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      rating: double.tryParse(ratingController.text) ?? 0.0,
      description: descriptionController.text,
      shopId: shopId,
    );

    try {
      if (selectedImage != null) {
        await pb.collection('menu').create(
          body: dish.toMap(),
          files: [
            await http.MultipartFile.fromPath(
              'thunail_menu',
              selectedImage!.path,
              filename: PATH.basename(selectedImage!.path),
            ),
          ],
        );
      } else {
        await pb.collection('menu').create(body: dish.toMap());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dish added successfully!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
