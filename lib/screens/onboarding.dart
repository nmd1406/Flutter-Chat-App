import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_app/screens/auth.dart';

List<Map<String, String>> _onboardingData = [
  {
    "assetPath": "assets/lottie/welcome.json",
    "title": "Chào mừng bạn đến với ChatApp!",
    "description": "Kết nối với bạn bè và người thân mọi lúc, mọi nơi."
  },
  {
    "assetPath": "assets/lottie/security.json",
    "title": "Bảo mật và riêng tư",
    "description":
        "Tin nhắn được mã hóa an toàn, bảo vệ \n quyền riêng tư của bạn."
  },
  {
    "assetPath": "assets/lottie/send_message.json",
    "title": "Trải nghiệm tuyệt vời",
    "description":
        "Dễ dàng gửi tin nhắn, hình ảnh, video \n với tốc độ nhanh chóng."
  }
];

class OnboardingSceen extends StatefulWidget {
  const OnboardingSceen({
    super.key,
  });

  @override
  State<OnboardingSceen> createState() => _OnboardingSceenState();
}

class _OnboardingSceenState extends State<OnboardingSceen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstTime", false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1400),
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, -1);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final curveAnimation =
                CurvedAnimation(parent: animation, curve: Curves.bounceOut);

            return SlideTransition(
              position: tween.animate(curveAnimation),
              child: child,
            );
          },
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
            const Spacer(),
            SizedBox(
              height: 500,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int index) {
                  setState(() {
                    _selectedPage = index;
                  });
                },
                itemBuilder: (context, index) => AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.5)).clamp(0.5, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 600,
                        width: Curves.easeOut.transform(value) * 500,
                        child: child,
                      ),
                    );
                  },
                  child: OnboardingContent(
                    assetPath: _onboardingData[index]["assetPath"]!,
                    title: _onboardingData[index]["title"]!,
                    content: _onboardingData[index]["description"]!,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedDot(isActive: _selectedPage == index),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 20),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                      Theme.of(context).primaryColor),
                  foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                ),
                onPressed: () => _completeOnboarding(),
                child: Text("Bắt đầu"),
              ),
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
      height: 5,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String assetPath;
  final String title;
  final String content;

  const OnboardingContent({
    super.key,
    required this.assetPath,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Lottie.asset(
                assetPath,
                frameRate: FrameRate(60),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
