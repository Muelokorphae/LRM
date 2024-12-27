import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as PATH;
import 'package:pocketbase/pocketbase.dart';

class ShopViewModel extends ChangeNotifier {
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);
  File? selectedImage;
  bool isLoading = false;
  String userId = 'yz42e5rz20d60lt';

  TextEditingController shopNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  ShopViewModel();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> addShop() async {
    isLoading = true;
    notifyListeners();
    String shopName = shopNameController.text;
    String location = locationController.text;
    String description = descriptionController.text;

    try {
      if (selectedImage != null) {
        final data = {
          "owner_id": userId,
          "shop_name": shopName,
          "location": location,
          "description": description,
        };
        await pb.collection('shop').create(
          body: data,
          files: [
            await http.MultipartFile.fromPath(
                'thunail_shop', selectedImage!.path,
                filename: PATH.basename(selectedImage!.path)),
          ],
        );
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception("Error adding shop: $e");
    }
  }
}
