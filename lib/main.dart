import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/splash/splash_page.dart';
import 'package:for_u_win/core/utils/dismiss_keyboard.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DismissKeyboard(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'For-U-Win',
            theme: ThemeData(
              appBarTheme: AppBarTheme(backgroundColor: secondaryColor, centerTitle: true),
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}
