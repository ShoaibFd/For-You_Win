import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/models/buy_now_model.dart';
import 'package:for_u_win/data/providers/products_provider.dart';
import 'package:for_u_win/data/services/products/products_services.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    Provider.of<ProductsServices>(context, listen: false).fetchProducts();
    super.initState();
  }

  bool isLoading = false;
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
            quantitiesProvider.initialize(productList.length);
          }

          return Padding(
            padding: EdgeInsets.only(left: 14.w, bottom: 30.h, right: 14.w),
            child: ListView.builder(
              itemCount: productList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final product = productList[index];
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
                        child: Image.network(product.image ?? "", height: 90.h, width: 90.w, fit: BoxFit.contain),
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
                                            quantitiesProvider.decrease(index);
                                          },
                                        ),
                                        AppText(
                                          quantitiesProvider.quantities[index].toString(),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 16.sp),
                                          onPressed: () {
                                            // final quantity = quantitiesProvider.quantities[index];
                                            // final productId = product.id.toString();
                                            // bool success = await ProductOrderService.postOrder(
                                            //   productId: productId,
                                            //   quantity: quantity,
                                            // );
                                            quantitiesProvider.increase(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Consumer<ProductsServices>(
                                    builder: (context, products, child) {
                                      return GestureDetector(
                                        onTap: () {
                                          final quantity = quantitiesProvider.quantities[index];
                                          final productId = int.tryParse(product.id.toString()) ?? 0;

                                          final price = double.tryParse(product.price.toString()) ?? 0;
                                          final vat = double.tryParse(product.vat.toString()) ?? 0;

                                          final double vatAmount = (price * vat) / 100;
                                          log(
                                            'ProductId: $productId,Quantity: $quantity, Vat: $vat, , price:$price, vatPercentage:${vatAmount.toStringAsFixed(2)}',
                                          );

                                          products.buyProduct(
                                            BuyNowModel(
                                              productId: productId,
                                              quantity: quantity,
                                              vatPercentage: vatAmount.toStringAsFixed(2),
                                              vat: vat,
                                              totalAmount: price,
                                            ),
                                            productId,
                                          );
                                        },

                                        child: Container(
                                          height: 34.h,
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                                          child: Center(
                                            child:
                                                products.isLoading
                                                    ? AppLoading(color: primaryColor)
                                                    : AppText('Buy Now', fontSize: 14.sp, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    },
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
