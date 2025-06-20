// ignore_for_file: deprecated_member_use

import 'dart:math';

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
import 'package:for_u_win/pages/products/components/checkbox.dart';
import 'package:for_u_win/pages/products/model/purchase_ticket_response.dart';
import 'package:provider/provider.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key, this.productId, this.quantity = 1});
  final int? productId;
  final int quantity;

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> with AutomaticKeepAliveClientMixin {
  // Controllers!!
  List<List<TextEditingController>> allTicketControllers = [];
  List<Map<String, bool>> allTicketGameTypes = [];
  List<List<FocusNode>> allTicketFocusNodes = [];

  bool _isInitialized = false;
  bool _dataFetched = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeOnce();
  }

  void _initializeOnce() {
    if (!_isInitialized) {
      _initializeControllers();
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_dataFetched) {
          _fetchData();
        }
      });
    }
  }

  void _fetchData() {
    if (!_dataFetched) {
      final provider = context.read<ProductsServices>();
      provider.fetchProductsDetails(widget.productId ?? 0);
      _dataFetched = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeOnce();
    }
  }

  void _initializeControllers() {
    if (allTicketControllers.isNotEmpty) return; 

    allTicketControllers.clear();
    allTicketGameTypes.clear();
    allTicketFocusNodes.clear();

    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      // Create 6 controllers for each ticket
      allTicketControllers.add(List.generate(6, (_) => TextEditingController()));
      allTicketFocusNodes.add(List.generate(6, (_) => FocusNode()));

      // Initialize game types for each ticket
      allTicketGameTypes.add({'Straight': false, 'Rumble': false, 'Chance': false});
    }
  }

  void _quickPick(int ticketIndex) {
    final random = Random();
    final provider = context.read<ProductsServices>();
    final numberOfField = provider.productsDetailData?.data?.numberOfCircles ?? 0;

    setState(() {
      if (numberOfField == 6) {
        // For 6 fields: generate unique numbers between 1-25, format with leading zeros
        List<int> availableNumbers = List.generate(25, (index) => index + 1);
        availableNumbers.shuffle(random);

        for (int i = 0; i < allTicketControllers[ticketIndex].length && i < numberOfField; i++) {
          allTicketControllers[ticketIndex][i].text = availableNumbers[i].toString().padLeft(2, '0');
        }
      } else {
        // For other fields: generate single digits (1-9, no zero)
        for (int i = 0; i < allTicketControllers[ticketIndex].length && i < numberOfField; i++) {
          allTicketControllers[ticketIndex][i].text = (random.nextInt(9) + 1).toString();
        }
      }
    });
  }

  bool _hasUniqueNumbers(int ticketIndex, int numberOfField) {
    if (numberOfField != 6) return true;

    List<String> filledValues =
        allTicketControllers[ticketIndex]
            .take(numberOfField)
            .map((controller) => controller.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

    return filledValues.length == filledValues.toSet().length;
  }

  int getSelectedCheckboxCount(int ticketIndex) {
    int count = 0;
    allTicketGameTypes[ticketIndex].forEach((key, value) {
      if (value) count++;
    });
    return count;
  }

  double calculateTotalPrice(double basePrice, double vatPercentage, int numberOfField) {
    double totalPrice = 0;

    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      int selectedGameTypes = getSelectedCheckboxCount(ticketIndex);

      if (numberOfField == 6) {
        // For 6-field games, each ticket costs the base price
        totalPrice += basePrice;
      } else {
        // For other games, price multiplies by selected game types (minimum 1)
        int multiplier = selectedGameTypes == 0 ? 1 : selectedGameTypes;
        totalPrice += basePrice * multiplier;
      }
    }

    return totalPrice;
  }

  double calculateTotalVAT(double basePrice, double vatPercentage, int numberOfField) {
    double totalVAT = 0;

    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      int selectedGameTypes = getSelectedCheckboxCount(ticketIndex);

      if (numberOfField == 6) {
        // For 6-field games, VAT on base price
        totalVAT += (basePrice * vatPercentage) / 100;
      } else {
        // For other games, VAT on multiplied price
        int multiplier = selectedGameTypes == 0 ? 1 : selectedGameTypes;
        totalVAT += (basePrice * multiplier * vatPercentage) / 100;
      }
    }

    return totalVAT;
  }

  @override
  void dispose() {
    for (var ticketControllers in allTicketControllers) {
      for (var controller in ticketControllers) {
        controller.dispose();
      }
    }
    for (var ticketFocusNodes in allTicketFocusNodes) {
      for (var node in ticketFocusNodes) {
        node.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('Buy Now', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Consumer<ProductsServices>(
          builder: (context, product, child) {
            // Show loading only on initial load
            if (product.isLoading && !_dataFetched) {
              return const Center(child: AppLoading());
            }

            final data = product.productsDetailData?.data;
            final numberOfField = data?.numberOfCircles ?? 0;
            final price = data?.product?.price;
            final vat = data?.product?.vat;

            final double priceValue = double.tryParse(price ?? '0') ?? 0.0;
            final double vatValue = double.tryParse(vat ?? '0') ?? 0.0;

            final double totalAmount = calculateTotalPrice(priceValue, vatValue, numberOfField);
            final double vatAmount = calculateTotalVAT(priceValue, vatValue, numberOfField);

            if (data == null && _dataFetched) {
              return const Center(child: AppText('Nothing found!!'));
            }

            // Ensure controllers are initialized when data is loaded
            if (allTicketControllers.isEmpty && data != null) {
              _initializeControllers();
            }

            // Show loading if data is still null but we haven't fetched yet
            if (data == null) {
              return const Center(child: AppLoading());
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        AppText("Choose Your Numbers", fontSize: 16.sp, fontWeight: FontWeight.bold),
                        AppText("Quantity: ${widget.quantity}", fontSize: 16.sp, fontWeight: FontWeight.w500),
                        Divider(thickness: 2, height: 24.h),
                        AppText("Total Amount: AED ${totalAmount.toStringAsFixed(2)}", fontSize: 16.sp),
                        AppText(
                          "VAT (${vatValue.toStringAsFixed(0)}%): AED ${vatAmount.toStringAsFixed(4)}",
                          fontSize: 16.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Generate ticket containers based on quantity
                  ...List.generate(widget.quantity, (ticketIndex) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16.r)),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText("Ticket #${ticketIndex + 1}", color: whiteColor, fontWeight: FontWeight.bold),
                                GestureDetector(
                                  onTap: () => _quickPick(ticketIndex),
                                  child: Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Center(child: AppText('Quick Pick', color: whiteColor)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10.w,
                            children: List.generate(numberOfField, (fieldIndex) {
                              return SizedBox(
                                width: 45.w,
                                height: 50.w,
                                child: TextFormField(
                                  controller: allTicketControllers[ticketIndex][fieldIndex],
                                  focusNode: allTicketFocusNodes[ticketIndex][fieldIndex],
                                  textAlign: TextAlign.center,
                                  maxLength: numberOfField == 6 ? 2 : 1,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                      if (newValue.text.isEmpty) return newValue;
                                      if (numberOfField == 6) {
                                        // maxLength == 2
                                        if (newValue.text.length > 2) return oldValue;
                                        // Allow 00-25
                                        final num = int.tryParse(newValue.text);
                                        if (num == null || num < 0 || num > 25) return oldValue;
                                        return newValue;
                                      } else {
                                        // maxLength == 1
                                        if (newValue.text.length > 1) return oldValue;
                                        // Allow 0-9
                                        final num = int.tryParse(newValue.text);
                                        if (num == null || num < 0 || num > 9) return oldValue;
                                        return newValue;
                                      }
                                    }),
                                  ],
                                  onChanged: (value) {
                                    // Move focus to next field if maxLength reached
                                    int maxLength = numberOfField == 6 ? 2 : 1;
                                    if (value.length == maxLength) {
                                      if (fieldIndex < numberOfField - 1) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(allTicketFocusNodes[ticketIndex][fieldIndex + 1]);
                                      } else {
                                        FocusScope.of(context).unfocus();
                                      }
                                    }
                                    if (numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField)) {
                                      setState(() {});
                                    } else {
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
                                          numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField)
                                              ? const BorderSide(color: Colors.red, width: 2)
                                              : BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField)
                                              ? const BorderSide(color: Colors.red, width: 2)
                                              : BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField)
                                              ? const BorderSide(color: Colors.red, width: 2)
                                              : const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 17.sp),
                                ),
                              );
                            }),
                          ),
                          if (numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField))
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: AppText("Numbers must be unique (01-25)", color: Colors.red, fontSize: 12.sp),
                            ),
                          SizedBox(height: 16.h),
                          numberOfField == 6
                              ? SizedBox()
                              : Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: whiteColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomCheckbox(
                                      label: 'Straight',
                                      value: allTicketGameTypes[ticketIndex]['Straight'] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          allTicketGameTypes[ticketIndex]['Straight'] = val ?? false;
                                        });
                                      },
                                    ),
                                    CustomCheckbox(
                                      label: 'Rumble',
                                      value: allTicketGameTypes[ticketIndex]['Rumble'] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          allTicketGameTypes[ticketIndex]['Rumble'] = val ?? false;
                                        });
                                      },
                                    ),
                                    CustomCheckbox(
                                      label: 'Chance',
                                      value: allTicketGameTypes[ticketIndex]['Chance'] ?? false,
                                      onChanged: (val) {
                                        setState(() {
                                          allTicketGameTypes[ticketIndex]['Chance'] = val ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 20.h),

                  // Confirm Purchase Button!!
                  // Replace the Confirm Purchase Button section in your PurchasePage with this fixed version
                  Consumer<ProductsServices>(
                    builder: (context, product, child) {
                      return PrimaryButton(
                        isLoading: product.isLoading,
                        onTap: () async {
                          List<Ticket> allTickets = [];
                          List<List<int>> allTicketsNumbers = []; // Add this to collect all ticket numbers

                          for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
                            int selectedCount = getSelectedCheckboxCount(ticketIndex);

                            if (numberOfField != 6 && selectedCount == 0) {
                              AppSnackbar.showInfoSnackbar(
                                'Please select at least one checkbox for Ticket #${ticketIndex + 1}',
                              );
                              return;
                            }

                            if (numberOfField == 6 && !_hasUniqueNumbers(ticketIndex, numberOfField)) {
                              AppSnackbar.showInfoSnackbar(
                                'Please ensure all numbers are unique for Ticket #${ticketIndex + 1}',
                              );
                              return;
                            }

                            // Collect numbers
                            List<int> numbers = [];
                            for (int i = 0; i < numberOfField; i++) {
                              if (i < allTicketControllers[ticketIndex].length &&
                                  allTicketControllers[ticketIndex][i].text.isNotEmpty) {
                                final num = int.tryParse(allTicketControllers[ticketIndex][i].text);
                                if (num != null) {
                                  numbers.add(num);
                                }
                              }
                            }

                            if (numbers.length != numberOfField) {
                              AppSnackbar.showInfoSnackbar(
                                'Please fill all number fields for Ticket #${ticketIndex + 1}',
                              );
                              return;
                            }

                            // Collect game types
                            List<String> selectedGameTypes = [];
                            if (numberOfField != 6) {
                              allTicketGameTypes[ticketIndex].forEach((gameType, isSelected) {
                                if (isSelected) selectedGameTypes.add(gameType);
                              });
                            }

                            allTickets.add(Ticket(numbers: numbers, gameTypes: selectedGameTypes));
                            allTicketsNumbers.add(numbers); 
                          }

                          final orderNumber = await product.purchaseTicket(
                            PurchaseTicketModel(productId: widget.productId ?? 0, tickets: allTickets),
                          );

                          await product.fetchInvoice(orderNumber, allTicketsNumbers);
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
}
