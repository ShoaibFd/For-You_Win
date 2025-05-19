import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/pages/bottom_navbar/dashboard_page.dart';
import 'package:for_u_win/pages/products/products_page.dart';
import 'package:for_u_win/pages/products/scan_page.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int currentIndex = 1;

  final List<Widget> pages = [ProductsPage(), ScanPage(), DashboardPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Image.asset(
                'assets/images/home.png',
                color: currentIndex == 0 ? Colors.cyanAccent : Colors.white,
                height: 24.h,
              ),
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
            SizedBox(width: 48.w),
            IconButton(
              icon: Image.asset(
                'assets/images/dashboard.png',
                color: currentIndex == 2 ? Colors.cyanAccent : Colors.white,
                height: 24.h,
              ),
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 70.h,
        width: 70.w,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              currentIndex = 1;
            });
          },
          backgroundColor: Colors.yellow[700],
          elevation: 6,
          shape: const CircleBorder(side: BorderSide(color: Colors.cyanAccent, width: 2)),
          child: Image.asset('assets/images/scanner.png', height: 30.h, width: 30.w, color: Colors.cyanAccent),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
