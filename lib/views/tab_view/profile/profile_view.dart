import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/auth/sign_in_view.dart';
import 'package:lrm_app/views/enterprenuer/enterpreneur_view.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:dio/dio.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _image;
  String? _imageUrl;
  bool isEntrepreneur =true;
  final pocketBaseUrl = PocketBase(dotenv.env['POCKETBASE_URL']!);
  final String collectionName = 'users';
  final dio = Dio();

  // Fake data for testing
  final Map<String, dynamic> data = {
    'Username': 'Milo',
    'userId': '4h5v74030r331u1',
    'email': 'milo@gmail.com',
    'phone': '02077846748',
    'address': 'Donkoy, Vietiane, Laos',
    'profile_picture': '',
    'isEntrepreneur': true
  };

  @override
  void initState() {
    super.initState();
    _fetchProfilePicture();
    _checkIfEntrepreneur(); // Check the entrepreneur status
  }

  // This method checks if the user is an entrepreneur from the backend
  Future<void> _checkIfEntrepreneur() async {
    try {
      final response = await dio.get(
          '$pocketBaseUrl/api/collections/$collectionName/records/${data['id']}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        setState(() {
          isEntrepreneur = responseData['isEntrepreneur'] ?? false;
        });
      }
    } catch (e) {
      print('Error fetching entrepreneur status: $e');
    }
  }

  // Fetch the profile picture from the backend
  Future<void> _fetchProfilePicture() async {
    try {
      final response = await dio.get(
          '$pocketBaseUrl/api/collections/$collectionName/records/${data['userId']}'); // Use actual userId

      if (response.statusCode == 200) {
        final responseData = response.data;
        setState(() {
          _imageUrl = responseData['profile_picture'];
        });
      }
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    try {
      final uri = Uri.parse('$pocketBaseUrl/api/files/$collectionName');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path),
      });

      final response = await dio.post(uri.toString(), data: formData);

      if (response.statusCode == 200) {
        final fileData = response.data;
        final imageUrl = fileData['fileUrl'];

        await _updateProfilePicture(imageUrl);
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateProfilePicture(String imageUrl) async {
    try {
      final response = await dio.patch(
        '$pocketBaseUrl/api/collections/$collectionName/records/${data['userId']}', // Use actual userId
        data: jsonEncode({'profile_picture': imageUrl}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = imageUrl;
        });
      } else {
        print('Failed to update profile picture');
      }
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> _deleteImage() async {
    try {
      if (_imageUrl != null) {
        // Delete the image by calling the appropriate delete API endpoint
        final response = await dio.delete(
            '$pocketBaseUrl/api/collections/$collectionName/records/${data['userId']}/file'); // Assuming delete endpoint for file

        if (response.statusCode == 200) {
          await _updateProfilePicture('');
        } else {
          print('Failed to delete image');
        }
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await dio.get(
        '$pocketBaseUrl/api/collections/$collectionName/records',
        queryParameters: {
          'sort': '-created', // Sort by 'created' field, descending
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var users = response.data['items'];
        });
      } else {
        print("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackGroundcColor,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.profileappBarColor,
        actions: [
          // Show the entrepreneur icon if isEntrepreneur is true
          if (isEntrepreneur)
            IconButton(
              icon: const Icon(Icons.business),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EnterpreneurView()),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  _showEditDeleteDialog();
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.profileGround,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_imageUrl != null ? NetworkImage('https://www.planetware.com/wpimages/2020/02/france-in-pictures-beautiful-places-to-photograph-eiffel-tower.jpg') : null),
                  child: _image == null && _imageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textgrey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                data['Username'], // Replaced with fake name data
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 10),

              // ID Section
              ListTile(
                onTap: () => print("ID management clicked"),
                leading: const Icon(Icons.account_circle,
                    color: AppColors.textBlack),
                title: const Text(
                  "ID",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  data['userId'], // Replaced with fake ID data
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textgrey,
                  ),
                ),
              ),

              // Email Section
              ListTile(
                onTap: () => print("Email management clicked"),
                leading:
                    const Icon(Icons.email_rounded, color: AppColors.textBlack),
                title: const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  data['email'], // Replaced with fake email data
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textgrey,
                  ),
                ),
              ),

              // Phone Section
              ListTile(
                onTap: () => print("Phone management clicked"),
                leading: const Icon(Icons.phone, color: AppColors.textBlack),
                title: const Text(
                  "Phone",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  data['phone'], // Replaced with fake phone data
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textgrey,
                  ),
                ),
              ),

              // Address Section
              ListTile(
                onTap: () => print("Address management clicked"),
                leading:
                    const Icon(Icons.home_outlined, color: AppColors.textBlack),
                title: const Text(
                  "Address",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  data['address'], // Replaced with fake address data
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textgrey,
                  ),
                ),
              ),
              ListTile(
                onTap: () => print("History management clicked"),
                leading:
                    const Icon(Icons.history, color: AppColors.textBlack),
                title: const Text(
                  "History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // LogOut Section
              ListTile(
                onTap: () {
                  pocketBaseUrl.authStore.clear();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignInView()));
                },
                leading: const Icon(Icons.logout_rounded,
                    color: AppColors.buttonDelete),
                title: const Text(
                  "LogOut",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Profile Picture"),
        content: const Text("Do you want to edit or delete the picture?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage();
            },
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
