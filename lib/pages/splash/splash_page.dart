import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/pages/onboarding/onboarding_page.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      Get.to(() => const OnboardingPage());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/splash_bg.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: ClipOval(
              child: Image.asset('assets/images/splash_logo.png', height: 200.h, width: 200.h, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
