import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_app/screens/auth.dart';

List<String> _content = [];

class OnboardingSceen extends StatefulWidget {
  const OnboardingSceen({
    super.key,
  });

  @override
  State<OnboardingSceen> createState() => _OnboardingSceenState();
}

class _OnboardingSceenState extends State<OnboardingSceen> {
  int _selectedPage = 0;

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstTime", false);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageView.builder(
              itemCount: _content.length,
              onPageChanged: (int index) {
                setState(() {
                  _selectedPage = index;
                });
              },
              itemBuilder: (context, index) => OnboardingContent(
                imagePath: "",
                title: "",
                content: "",
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _content.length,
                (index) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedDot(isActive: _selectedPage == index),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _completeOnboarding(),
              child: Text("Bắt đầu"),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDot extends StatelessWidget {
  final bool isActive;

  const AnimatedDot({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      width: isActive ? 20 : 6,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String content;

  const OnboardingContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset("path"),
          ),
        ),
        const SizedBox(height: 12),
        Text("Title"),
        const SizedBox(height: 10),
        Text("Content..."),
      ],
    );
  }
}
