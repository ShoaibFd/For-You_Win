import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/products/products_services.dart';
import 'package:for_u_win/pages/products/model/purchase_ticket_response.dart';
import 'package:provider/provider.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key, this.productId});
  final int? productId;

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final List<TextEditingController> numberControllers = List.generate(6, (_) => TextEditingController());
  List<String> gameTypes = [];
  bool isChecked = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  void _quickPick() {
    final random = Random();
    final provider = context.read<ProductsServices>();
    final numberOfField = provider.productsDetailData?.data?.numberOfCircles ?? 0;

    setState(() {
      if (numberOfField == 6) {
        // For 6 fields: generate unique numbers between 1-25
        List<int> availableNumbers = List.generate(25, (index) => index + 1);
        availableNumbers.shuffle(random);

        for (int i = 0; i < numberControllers.length && i < numberOfField; i++) {
          numberControllers[i].text = availableNumbers[i].toString().padLeft(2, '0');
        }
      } else {
        // For other fields: generate single digits (can repeat)
        for (int i = 0; i < numberControllers.length && i < numberOfField; i++) {
          numberControllers[i].text = (random.nextInt(9) + 1).toString();
        }
      }
    });
  }

  bool _isValidNumber(String value, int numberOfField) {
    if (value.isEmpty) return true;

    if (numberOfField == 6) {
      // For 6 fields: must be between 1-25
      final num = int.tryParse(value);
      return num != null && num >= 1 && num <= 25;
    } else {
      // For other fields: must be single digit 1-9
      final num = int.tryParse(value);
      return num != null && num >= 1 && num <= 9;
    }
  }

  bool _hasUniqueNumbers(int numberOfField) {
    if (numberOfField != 6) return true;

    List<String> filledValues =
        numberControllers
            .take(numberOfField)
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    return filledValues.length == filledValues.toSet().length;
  }

  int getSelectedCheckboxCount() {
    int count = 0;
    if (isChecked) count++;
    if (isChecked2) count++;
    if (isChecked3) count++;
    return count;
  }

  @override
  void dispose() {
    for (var c in numberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductsServices>();
    provider.fetchProductsDetails(widget.productId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('Buy Now', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Consumer<ProductsServices>(
          builder: (context, product, child) {
            if (product.isLoading) {
              return const Center(child: AppLoading());
            }

            final data = product.productsDetailData?.data;
            final numberOfField = data?.numberOfCircles;
            final price = data?.product?.price;
            final vat = data?.product?.vat;

            final double priceValue = double.tryParse(price ?? '0') ?? 0.0;
            final double vatValue = double.tryParse(vat ?? '0') ?? 0.0;

            int actualSelectedCount = getSelectedCheckboxCount();
            int selectedCount = actualSelectedCount == 0 ? 1 : actualSelectedCount;

            final double totalAmount = priceValue * selectedCount;
            final double vatAmount = (priceValue * vatValue * selectedCount) / 100;

            if (data == null) {
              return const Center(child: AppText('Nothing found!!'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText("Choose Your Number", fontSize: 18.sp, fontWeight: FontWeight.bold),
                  Divider(thickness: 2, height: 24.h),
                  AppText("Total Amount: AED ${totalAmount.toStringAsFixed(2)}", fontSize: 16.sp),
                  AppText(
                    "VAT (${vatValue.toStringAsFixed(0)}%): AED ${vatAmount.toStringAsFixed(4)}",
                    fontSize: 16.sp,
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16.r)),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText("Ticket #1", color: Colors.red, fontWeight: FontWeight.bold),
                              TextButton(
                                onPressed: _quickPick,
                                child: AppText("Quick Pick", color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.w,
                          children: List.generate(numberOfField ?? 0, (index) {
                            return SizedBox(
                              width: 45.w,
                              height: 45.w,
                              child: TextFormField(
                                controller: numberControllers[index],
                                textAlign: TextAlign.center,
                                maxLength: numberOfField == 6 ? 2 : 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  if (numberOfField == 6)
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                      if (newValue.text.isEmpty) return newValue;
                                      final num = int.tryParse(newValue.text);
                                      if (num == null || num < 1 || num > 25) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    })
                                  else
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                      if (newValue.text.isEmpty) return newValue;
                                      final num = int.tryParse(newValue.text);
                                      if (num == null || num < 1 || num > 9) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    }),
                                ],
                                onChanged: (value) {
                                  if (numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0)) {
                                    // Show warning for duplicate numbers in 6-field mode
                                    setState(() {});
                                  }
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: secondaryColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide:
                                        numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0)
                                            ? const BorderSide(color: Colors.red, width: 2)
                                            : BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide:
                                        numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0)
                                            ? const BorderSide(color: Colors.red, width: 2)
                                            : BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    borderSide:
                                        numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0)
                                            ? const BorderSide(color: Colors.red, width: 2)
                                            : const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                ),
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                              ),
                            );
                          }),
                        ),
                        if (numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0))
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: AppText("Numbers must be unique (1-25)", color: Colors.red, fontSize: 12.sp),
                          ),
                        SizedBox(height: 16.h),
                        numberOfField == 6
                            ? SizedBox()
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _checkbox('Straight', isChecked, (val) {
                                  setState(() {
                                    isChecked = val ?? false;
                                  });
                                }),
                                _checkbox('Rumble', isChecked2, (val) {
                                  setState(() {
                                    isChecked2 = val ?? false;
                                  });
                                }),
                                _checkbox('Chance', isChecked3, (val) {
                                  setState(() {
                                    isChecked3 = val ?? false;
                                  });
                                }),
                              ],
                            ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Consumer<ProductsServices>(
                    builder: (context, product, child) {
                      return PrimaryButton(
                        isLoading: product.isLoading,
                        onTap: () {
                          // Check if checkboxes are required (for non-6 field games)
                          if (numberOfField != 6 && actualSelectedCount == 0) {
                            AppSnackbar.showInfoSnackbar('Please select any checkbox to continue');
                          } else if (numberOfField == 6 && !_hasUniqueNumbers(numberOfField ?? 0)) {
                            AppSnackbar.showInfoSnackbar('Please ensure all numbers are unique');
                          } else {
                            // Collect numbers from controllers
                            List<int> numbers = [];
                            for (int i = 0; i < (numberOfField ?? 0); i++) {
                              if (i < numberControllers.length && numberControllers[i].text.isNotEmpty) {
                                final num = int.tryParse(numberControllers[i].text);
                                if (num != null) {
                                  numbers.add(num);
                                }
                              }
                            }

                            // Check if all required fields are filled
                            if (numbers.length != (numberOfField ?? 0)) {
                              AppSnackbar.showInfoSnackbar('Please fill all number fields');
                              return;
                            }

                            // Collect game types from checkboxes
                            List<String> selectedGameTypes = [];
                            if (numberOfField == 6) {
                              // For 6-field games, no game types are needed (checkboxes are hidden)
                              selectedGameTypes = [];
                            } else {
                              // For other games, collect selected game types
                              if (isChecked) selectedGameTypes.add('Straight');
                              if (isChecked2) selectedGameTypes.add('Rumble');
                              if (isChecked3) selectedGameTypes.add('Chance');
                            }

                            // Make the purchase
                            product.purchaseTicket(
                              PurchaseTicketModel(
                                productId: widget.productId ?? 0,
                                tickets: [Ticket(numbers: numbers, gameTypes: selectedGameTypes)],
                              ),
                            );
                          }
                        },
                        title: 'Confirm Purchase',
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _checkbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(children: [CupertinoCheckbox(value: value, onChanged: onChanged), SizedBox(width: 8.w), AppText(label)]);
  }
}
