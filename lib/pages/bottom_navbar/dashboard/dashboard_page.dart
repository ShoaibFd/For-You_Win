import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/carousel_slider.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/dashboard/dashboard_services.dart';
import 'package:for_u_win/pages/bottom_navbar/dashboard/product_detail_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data List
  final List<Map<String, dynamic>> data = [
    {"image": "assets/images/premium.png", "title": "Royal-6"},
    {"image": "assets/images/trophy.png", "title": "Mega-4"},
    {"image": "assets/images/star.png", "title": "Thrill-3"},
  ];
  @override
  void initState() {
    Provider.of<DashboardServices>(context, listen: false).fetchDashboardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Drawer
      drawer: AppDrawer(),
      // AppBar
      appBar: AppBar(title: AppText('Dashboard', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Banner section
            BannerCarousel(),
            // Daily Results Header
            Padding(
              padding: EdgeInsets.only(left: 14.w, top: 10.h, bottom: 6.h),
              child: AppText('Daily Results', fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            // Promotion Bar
            Consumer<DashboardServices>(
              builder: (context, product, child) {
                if (product.isLoading) {
                  return Center(child: AppLoading());
                }

                final bannerImage = product.dashboardData?.data?.banner?.url;
                if (bannerImage == null || bannerImage.isEmpty) {
                  return SizedBox();
                }
                return Container(
                  height: 234.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(bannerImage), fit: BoxFit.cover),
                  ),
                );
              },
            ),
            SizedBox(height: 30.h),
            // Products Section
            Consumer<DashboardServices>(
              builder: (context, product, child) {
                if (product.isLoading) {
                  return Center(child: AppLoading());
                }

                final productList = product.dashboardData?.data?.products?.data;

                if (productList == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.block, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        AppText('No products!', fontSize: 15.sp, color: Colors.grey),
                        SizedBox(height: 50.h),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: productList.length,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final products = productList[index];

                    // Cycle through local data images!!
                    final localImage = data[index % data.length]['image'];

                    return GestureDetector(
                      onTap: () {
                        final pageName = products.name;
                        debugPrint('Product Id :${products.name}');
                        Get.to(() => ProductDetailPage(pageName: pageName.toString()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10.r)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Stack(
                                      children: [
                                        Image.asset('assets/images/badge.png', height: 70.h),
                                        Positioned(left: 18.w, top: 20.h, child: Image.asset(localImage, height: 40.h)),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: AppText(products.name ?? "", fontSize: 16.sp, textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Divider(thickness: 2, color: blackColor),
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    AppText('Entry Prize', fontSize: 16.sp),
                                    AppText(products.price ?? "", fontSize: 16.sp),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
