import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/products/purchase_page.dart';
import 'package:get/get.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Map<String, dynamic>> productList = [
    {'image': 'assets/images/cup.png', 'title': 'Royal-6'},
    {'image': 'assets/images/key.png', 'title': 'mega-4'},
    {'image': 'assets/images/pencil.png', 'title': 'Thrill-3'},
  ];

  // Track quantity for each product
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = List.generate(productList.length, (index) => 1); // Default quantity is 1
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('All Products', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: ListView.builder(
          itemCount: productList.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              width: double.maxFinite,
              margin: EdgeInsets.only(bottom: 6.h, top: 10.h),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.r)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 110.h,
                    width: 90.w,
                    alignment: Alignment.center,
                    child: Image.asset(productList[index]['image'], height: 90.h, width: 90.w, fit: BoxFit.contain),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Product: ${productList[index]['title']}',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 4.h),
                          AppText('Price: AED 4.75', fontSize: 14.sp),
                          AppText('VAT: 5.00%', fontSize: 14.sp),
                          SizedBox(height: 4.h),
                          AppText('Quantity', fontSize: 14.sp),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Container(
                                height: 34.h,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, size: 16.sp),
                                      onPressed: () {
                                        setState(() {
                                          if (quantities[index] > 1) {
                                            quantities[index]--;
                                          }
                                        });
                                      },
                                    ),
                                    AppText(quantities[index].toString(), fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    IconButton(
                                      icon: Icon(Icons.add, size: 16.sp),
                                      onPressed: () {
                                        setState(() {
                                          quantities[index]++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ChooseNumberPage());
                                },
                                child: Container(
                                  height: 34.h,
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                                  child: Center(
                                    child: AppText('Buy Now', fontSize: 14.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
