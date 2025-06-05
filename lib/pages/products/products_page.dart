import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/providers/products_provider.dart';
import 'package:for_u_win/data/services/products/products_services.dart';
import 'package:for_u_win/pages/products/purchase_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsServices>(context, listen: false).fetchProducts();
    });
  }

  void _initializeQuantities(QuantityProvider quantitiesProvider, int length) {
    if (!_initialized && quantitiesProvider.quantities.length != length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          quantitiesProvider.initialize(length);
          setState(() {
            _initialized = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('All Products', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Consumer2<ProductsServices, QuantityProvider>(
        builder: (context, products, quantitiesProvider, _) {
          if (products.isLoading) {
            return Center(child: AppLoading());
          }

          final productList = products.productsData?.data;
          if (productList == null || productList.isEmpty) {
            return Center(child: AppText('No Products!!'));
          }

          if (quantitiesProvider.quantities.length != productList.length) {
            _initializeQuantities(quantitiesProvider, productList.length);
            if (!_initialized) {
              return Center(child: AppLoading());
            }
          }

          return Padding(
            padding: EdgeInsets.only(left: 14.w, bottom: 30.h, right: 14.w),
            child: ListView.builder(
              itemCount: productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final product = productList[index];

                if (index >= quantitiesProvider.quantities.length) {
                  return const SizedBox.shrink();
                }

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
                        child: Image.network(
                          product.image ?? "",
                          height: 90.h,
                          width: 90.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported, size: 50.sp);
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(product.name ?? "", fontSize: 16.sp, fontWeight: FontWeight.bold),
                              SizedBox(height: 4.h),
                              AppText(product.price ?? "", fontSize: 14.sp),
                              AppText(product.vat ?? "", fontSize: 14.sp),
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
                                            if (index < quantitiesProvider.quantities.length) {
                                              quantitiesProvider.decrease(index);
                                            }
                                          },
                                        ),
                                        AppText(
                                          (index < quantitiesProvider.quantities.length
                                                  ? quantitiesProvider.quantities[index]
                                                  : 1)
                                              .toString(),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 16.sp),
                                          onPressed: () {
                                            if (index < quantitiesProvider.quantities.length) {
                                              quantitiesProvider.increase(index);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Buy Now Button!!
                                  GestureDetector(
                                    onTap: () {
                                      final quantity =
                                          index < quantitiesProvider.quantities.length
                                              ? quantitiesProvider.quantities[index]
                                              : 1;
                                      final productId = int.tryParse(product.id.toString()) ?? 0;

                                      Get.to(() => PurchasePage(productId: productId, quantity: quantity));
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
          );
        },
      ),
    );
  }
}
