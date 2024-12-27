import 'dart:developer';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:lrm_app/views/auth/sign_up_view.dart';
import 'package:lrm_app/constant/color.dart';
import 'package:lrm_app/views/tab_view/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final pb = PocketBase(dotenv.env['POCKETBASE_URL']!);

  bool isLoading = false;
  String? emailError;
  String? passwordError;
  String? profileImageUrl;
  List<dynamic> usersList = [];

  // Sign-in function
  void _validateAndSignIn() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Input validation
    if (email.isEmpty) {
      setState(() {
        emailError = 'Email is required.';
      });
      return;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        emailError = 'Enter a valid email address.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = 'Password is required.';
      });
      return;
    } else if (password.length < 6) {
      setState(() {
        passwordError = 'Password must be at least 6 characters.';
      });
      return;
    }

    // Sign-in process
    setState(() {
      isLoading = true;
    });

    try {
      final authData = await pb.collection('users').authWithPassword(
            email,
            password,
          );
      final token = pb.authStore.token;
      final jwt = JWT.decode(token);
      final userId = jwt.payload['id'];

      prefs = await SharedPreferences.getInstance();
      prefs.setBool("isOnboarded", true);
      if (prefs != false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Tabs()),
        );
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('invalid identifier or password')) {
          emailError = 'Invalid email or password.';
        } else {
          emailError = 'An error occurred. Please try again.';
        }
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackGroundcColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to ',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    errorText: emailError,
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    errorText: passwordError,
                    icon: Icons.lock,
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: 150,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _validateAndSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonOK,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textFieldground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Please'),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpView()));
                          },
                          child: const Text(
                            'SignUp',
                            style: TextStyle(
                                fontSize: 20,
                                color: AppColors.tabsColor,
                                decoration: TextDecoration.underline),
                          )),
                      const Text('If you don\'t have an account'),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
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
    String? errorText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textBlack),
            hintText: hintText,
            filled: true,
            fillColor: AppColors.textFieldground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            hintStyle: TextStyle(
              color: AppColors.textBlack.withOpacity(0.5),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppColors.buttonDelete,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
