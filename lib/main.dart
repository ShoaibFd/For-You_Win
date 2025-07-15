import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/core/utils/dismiss_keyboard.dart';
import 'package:for_u_win/data/providers/products_provider.dart';
import 'package:for_u_win/data/services/auth/auth_services.dart';
import 'package:for_u_win/data/services/dashboard/dashboard_services.dart';
import 'package:for_u_win/data/services/invoice/invoice_services.dart';
import 'package:for_u_win/data/services/products/products_services.dart';
import 'package:for_u_win/data/services/tickets/ticket_services.dart';
import 'package:for_u_win/pages/restriction/app_life_cycle_manager.dart';
import 'package:for_u_win/pages/splash/splash_page.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  AppLifecycleManager().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthServices()),
        ChangeNotifierProvider(create: (_) => DashboardServices()),
        ChangeNotifierProvider(create: (_) => ProductsServices()),
        ChangeNotifierProvider(create: (_) => TicketServices()),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceServices()),
      ],
      child: const MyApp(),
    ),
  );
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
            defaultTransition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 200),
            theme: ThemeData(
              appBarTheme: const AppBarTheme(backgroundColor: secondaryColor, centerTitle: true),
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: SplashPage(),
          ),
        );
      },
    );
  }
}
