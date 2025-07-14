import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/pages/restriction/restriction_page.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

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
    tz.initializeTimeZones();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    Future.delayed(const Duration(seconds: 2), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final token = await _sharedPrefs.getToken();
    Widget destination;
    if (token != null && token.isNotEmpty) {
      destination = const BottomNavigationBarPage();
    } else {
      destination = const LoginPage();
    }
    // Wrap the destination with RestrictedTimePage
    Get.offAll(() => RestrictedTimePage(child: destination));
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
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/splash_bg.png'), fit: BoxFit.cover),
        ),
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
