import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lrm_app/views/auth/sign_up_view.dart'; // Adjust path to your actual file
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to LRM APP",
            body: "Your journey begins here.",
            image: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset("assets/images/start.jpg"),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              bodyTextStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          PageViewModel(
            title: "Track Your Progress",
            body: "Easily track your goals and achievements.",
            image: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset("assets/images/onb.jpg"), 
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              bodyTextStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          PageViewModel(
            title: "Achieve Your Dreams",
            body: "Let us help you reach your full potential.",
            image: Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset("assets/images/food.jpg"), 
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              bodyTextStyle: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
        next: const Text(
          "Next",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        done: const Text(
          "Get Started",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        onDone: () async {
          prefs = await SharedPreferences.getInstance();
          prefs.setBool("isOnboarded", true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpView()), 
          );
        },
      ),
    );
  }
}
