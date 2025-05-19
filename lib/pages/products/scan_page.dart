import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/carousel_slider.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            // Banner section
            BannerCarousel(),

            // Daily Results Header
            Padding(
              padding: EdgeInsets.only(left: 14.w, top: 10.h, bottom: 6.h),
              child: AppText('Daily Results', fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),

            // Promotion Bar
            Container(
              color: const Color.fromARGB(221, 17, 17, 17),
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 50.h),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AppText(
                        'BUY OUR PRODUCT & !\nGET FREE RAFFLE TICKETS',
                        color: whiteColor,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      AppText('RESULTS', color: secondaryColor, fontWeight: FontWeight.bold),
                      AppText('May 15, 2025', color: whiteColor, fontSize: 8.sp),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText('DRAW TIME', fontWeight: FontWeight.bold, color: whiteColor, fontSize: 10.sp),
                      AppText('11 PM EVERYDAY', fontWeight: FontWeight.bold, color: secondaryColor, fontSize: 10.sp),
                    ],
                  ),
                ],
              ),
            ),

            // Result Section
            Container(
              color: primaryColor,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ResultRow(
                    title: 'Royal',
                    mainCircleColor: blackColor,
                    textColor: whiteColor,
                    mainNumber: 6,
                    count: 6,
                  ),
                  SizedBox(height: 10.h),

                  ResultRow(
                    title: 'Mega',
                    mainCircleColor: Colors.green,
                    textColor: blackColor,
                    mainNumber: 6,
                    count: 4,
                  ),
                  SizedBox(height: 10.h),
                  ResultRow(
                    title: 'Thrill  ',
                    mainCircleColor: Colors.red,
                    textColor: Colors.green,
                    mainNumber: 6,
                    count: 3,
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),

            Container(
              width: double.maxFinite,
              color: blackColor,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText('Shop Online At ', color: whiteColor, fontSize: 8.sp),
                      AppText('WWW.foryouwin.com', color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10.sp),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: AppText(
                      'Meydan GrandStand, 6th floor, Meydan Road,\nNad Al Sheba, Dubai, UAE',
                      color: whiteColor,
                      fontSize: 12.sp,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Real-time QR codes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          QrImageView(
                            data: "https://wa.me/923027697472",
                            version: QrVersions.auto,
                            size: 60.w,
                            backgroundColor: whiteColor,
                          ),
                          SizedBox(height: 4.h),
                          AppText('WhatsApp', color: whiteColor, fontSize: 10.sp),
                        ],
                      ),
                      SizedBox(width: 20.w),
                      Column(
                        children: [
                          QrImageView(
                            data: "https://instagram.com/yourprofile",
                            version: QrVersions.auto,
                            size: 60.w,
                            backgroundColor: whiteColor,
                          ),
                          SizedBox(height: 4.h),
                          AppText('Instagram', color: whiteColor, fontSize: 10.sp),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String title;
  final Color mainCircleColor;
  final Color textColor;
  final int mainNumber;
  final int count;

  const ResultRow({
    super.key,
    required this.title,
    required this.mainCircleColor,
    required this.textColor,
    required this.mainNumber,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: blackColor, borderRadius: BorderRadius.circular(3.r)),
          padding: const EdgeInsets.all(6.0),
          child: AppText(title, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 15,
          backgroundColor: mainCircleColor,
          child: AppText('$mainNumber', fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(width: 10.w),
        Row(
          children: List.generate(count, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: whiteColor,
                child: AppText('${index + 1}', fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ],
    );
  }
}
