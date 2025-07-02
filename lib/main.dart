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
import 'package:for_u_win/pages/splash/splash_page.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: MyApp(),
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
