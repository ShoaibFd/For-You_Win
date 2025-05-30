import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final SharedPrefs _sharedPrefs = SharedPrefs();

  @override
  void initState() {
    super.initState();

    // Animation controller!
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Delay for 2 seconds and then navigate to onboarding page!
    Future.delayed(const Duration(seconds: 2), () {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final token = await _sharedPrefs.getToken();
    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const BottomNavigationBarPage());
    } else {
      Get.offAll(() => LoginPage());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background Image!
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/splash_bg.png'), fit: BoxFit.cover),
        ),
        // Rotating logo!
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: ClipOval(
              child: Image.asset('assets/images/splash_logo.png', height: 250.h, width: 250.h, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
