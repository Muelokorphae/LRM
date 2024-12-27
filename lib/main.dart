import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lrm_app/ViewModels/add_menu_view_model.dart';
import 'package:lrm_app/ViewModels/add_shop_view_model.dart';
import 'package:lrm_app/views/auth/sign_in_view.dart';
import 'package:lrm_app/views/onboarding_view.dart';

import 'package:lrm_app/views/tab_view/tabs.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    log("Failed to load .env file: $e");
  }

  prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ShopViewModel()),
      ChangeNotifierProvider(create: (_) => AddViewModel()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget route;

    bool isOnboarded = prefs.getBool("isOnboarded") ?? false;
    bool isSignInView = prefs.getBool("isSigninView") ?? false;

    if (isOnboarded) {
      route = SignInView();
    } else if (isSignInView) {
      route = Tabs();
    } else {
      route = OnboardingView();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: route,
    );
  }
}
