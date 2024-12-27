import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/auth/sign_in_view.dart';
import 'package:lrm_app/views/tab_view/tabs.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:io'; // For file handling
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as PATH;

final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isEntrepreneur = false; // Toggle state
  bool isLoading = false; // Loading state
  File? _avatarImage; // Avatar image file

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final regex = RegExp(
        r'^\+?[0-9]{1,3}?[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{1,4}[-.\s]?[0-9]{1,9}$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _addressController.clear();
    _phoneController.clear();
    _passwordController.clear();
    setState(() {
      isEntrepreneur = false; // Reset toggle
      _avatarImage = null; // Reset avatar image
    });
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  // Sign-up logic
  Future<void> _signUpUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final data = <String, dynamic>{
        "password": _passwordController.text,
        "passwordConfirm": _passwordController.text,
        "email": _emailController.text,
        "emailVisibility": true,
        "name": _nameController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "isEntrepreneur": isEntrepreneur,
      };

      try {
        if (_avatarImage != null) {
          final userRecord = await pb.collection('users').create(
            body: data,
            files: [
              await http.MultipartFile.fromPath('avatar', _avatarImage!.path,
                  filename: PATH.basename(_avatarImage!.path)),
            ],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign Up Successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Tabs()),
          );
        } else {
          final userRecord = await pb.collection('users').create(
                body: data,
              );
          _clearFields();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign Up Successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Tabs()),
          );
        }
      } catch (e) {
        final message = e.toString().contains('409')
            ? 'User with this email already exists'
            : 'Sign Up Failed ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        log('$e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log(pb.baseURL.toString());
    return Scaffold(
      backgroundColor: AppColors.profileBackGroundcColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickAvatarImage, // Pick image when tapped
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : AssetImage('assets/icons/download.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      obscureText: false,
                      validator: _validateName,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: _validateEmail,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _addressController,
                      hintText: 'Village, district, province...etc',
                      obscureText: false,
                      validator: null,
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      keyboardType: TextInputType.number,
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      obscureText: false,
                      validator: _validatePhone,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      validator: _validatePassword,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Are you an entrepreneur?',
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: isEntrepreneur,
                          onChanged: (value) {
                            setState(() {
                              isEntrepreneur = value;
                            });
                          },
                          activeColor: AppColors.buttonOK,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : _signUpUser, // Disable button if loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonOK,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.textFieldground,
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textFieldground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Please'),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInView()));
                            },
                            child: const Text(
                              'SignIn',
                              style:
                                  TextStyle(fontSize: 20, color: AppColors.tabsColor,decoration: TextDecoration.underline),
                            )),
                        const Text('If already have an account'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required FormFieldValidator<String>? validator,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        filled: true,
        fillColor: AppColors.textFieldground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      validator: validator,
    );
  }
}
