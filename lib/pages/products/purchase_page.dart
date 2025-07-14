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
import 'package:for_u_win/pages/products/invoice_page/generate_invoice_page.dart';
import 'package:for_u_win/pages/products/model/purchase_ticket_response.dart';
import 'package:get/get.dart';
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
      List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
      List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

      allTicketControllers.add(controllers);
      allTicketFocusNodes.add(focusNodes);

      // ✅ FIXED: Add focus listeners to handle auto-padding when focus changes
      for (int fieldIndex = 0; fieldIndex < 6; fieldIndex++) {
        focusNodes[fieldIndex].addListener(() {
          if (!focusNodes[fieldIndex].hasFocus) {
            // Focus lost - check if we need to pad
            _handleFocusLost(ticketIndex, fieldIndex);
          }
        });
      }

      // Initialize game types for each ticket
      allTicketGameTypes.add({'Straight': false, 'Rumble': false, 'Chance': false});
    }
  }

  // ✅ FIXED: Handle auto-padding when focus is lost
  void _handleFocusLost(int ticketIndex, int fieldIndex) {
    final provider = context.read<ProductsServices>();
    final numberOfField = provider.productsDetailData?.data?.numberOfCircles ?? 0;

    if (numberOfField == 6) {
      final controller = allTicketControllers[ticketIndex][fieldIndex];
      final currentText = controller.text.trim();

      if (currentText.isNotEmpty && currentText.length == 1) {
        // Auto-pad with zero
        final paddedValue = currentText.padLeft(2, '0');
        controller.text = paddedValue;
        setState(() {}); // Update UI
      }
    }
  }

  void _quickPick(int ticketIndex) {
    final random = Random();
    final provider = context.read<ProductsServices>();
    final numberOfField = provider.productsDetailData?.data?.numberOfCircles ?? 0;
    setState(() {
      if (numberOfField == 6) {
        List<int> availableNumbers = List.generate(25, (index) => index + 1);
        List<int> selectedNumbers = [];
        // Try to generate a unique combination
        int attempts = 0;
        while (attempts < 100) {
          // Prevent infinite loop
          availableNumbers.shuffle(random);
          selectedNumbers = availableNumbers.take(numberOfField).toList();
          selectedNumbers.sort();
          if (!_isTicketCombinationDuplicate(ticketIndex, selectedNumbers)) {
            break;
          }
          attempts++;
        }
        // Fill the controllers with the selected numbers (preserve leading zeros)
        for (int i = 0; i < allTicketControllers[ticketIndex].length && i < numberOfField; i++) {
          allTicketControllers[ticketIndex][i].text = selectedNumbers[i].toString().padLeft(2, '0');
        }
      } else {
        List<int> selectedNumbers = [];
        int attempts = 0;
        while (attempts < 100) {
          selectedNumbers.clear();
          for (int i = 0; i < numberOfField; i++) {
            selectedNumbers.add(random.nextInt(10));
          }
          if (!_isTicketCombinationDuplicate(ticketIndex, selectedNumbers)) {
            break;
          }
          attempts++;
        }
        for (int i = 0; i < allTicketControllers[ticketIndex].length && i < numberOfField; i++) {
          allTicketControllers[ticketIndex][i].text = selectedNumbers[i].toString();
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

  // New helper function to validate 2-digit numbers
  bool _hasValidTwoDigitNumbers(int ticketIndex, int numberOfField) {
    if (numberOfField != 6) return true;
    for (int i = 0; i < numberOfField; i++) {
      final text = allTicketControllers[ticketIndex][i].text.trim();
      if (text.isEmpty || text.length != 2) {
        return false;
      }
      final num = int.tryParse(text);
      if (num == null || num < 1 || num > 25) {
        return false;
      }
    }
    return true;
  }

  // Updated function to check if a ticket combination is duplicate (works with strings)
  bool _isTicketCombinationDuplicate(int currentTicketIndex, List<dynamic> numbersToCheck) {
    final provider = context.read<ProductsServices>();
    final numberOfField = provider.productsDetailData?.data?.numberOfCircles ?? 0;
    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      if (ticketIndex == currentTicketIndex) continue; // Skip current ticket
      // Get numbers from other ticket
      List<String> otherTicketNumbers = [];
      bool allFieldsFilled = true;
      for (int i = 0; i < numberOfField; i++) {
        if (i >= allTicketControllers[ticketIndex].length) {
          allFieldsFilled = false;
          break;
        }
        final text = allTicketControllers[ticketIndex][i].text.trim();
        if (text.isEmpty) {
          allFieldsFilled = false;
          break;
        }
        otherTicketNumbers.add(text);
      }
      if (!allFieldsFilled) continue;
      // Convert numbersToCheck to string format for comparison
      List<String> currentTicketNumbers = [];
      for (var num in numbersToCheck) {
        if (num is int) {
          if (numberOfField == 6) {
            currentTicketNumbers.add(num.toString().padLeft(2, '0'));
          } else {
            currentTicketNumbers.add(num.toString());
          }
        } else {
          currentTicketNumbers.add(num.toString());
        }
      }
      // Sort both lists for comparison
      List<String> sortedCurrent = List.from(currentTicketNumbers)..sort();
      List<String> sortedOther = List.from(otherTicketNumbers)..sort();
      // Check if they are identical
      if (sortedCurrent.length == sortedOther.length) {
        bool identical = true;
        for (int i = 0; i < sortedCurrent.length; i++) {
          if (sortedCurrent[i] != sortedOther[i]) {
            identical = false;
            break;
          }
        }
        if (identical) {
          return true;
        }
      }
    }
    return false;
  }

  // Updated function to check if current ticket has duplicate numbers with other tickets
  bool _hasTicketDuplicates(int ticketIndex, int numberOfField) {
    // Get current ticket numbers as strings
    List<String> currentNumbers = [];
    for (int i = 0; i < numberOfField; i++) {
      if (i >= allTicketControllers[ticketIndex].length) return false;
      final text = allTicketControllers[ticketIndex][i].text.trim();
      if (text.isEmpty) return false;
      currentNumbers.add(text);
    }
    return _isTicketCombinationDuplicate(ticketIndex, currentNumbers);
  }

  int getSelectedCheckboxCount(int ticketIndex) {
    int count = 0;
    allTicketGameTypes[ticketIndex].forEach((key, value) {
      if (value) count++;
    });
    return count;
  }

  // Fixed function to collect game types with proper formatting
  List<String> getSelectedGameTypes(int ticketIndex) {
    List<String> selectedGameTypes = [];
    allTicketGameTypes[ticketIndex].forEach((gameType, isSelected) {
      if (isSelected) {
        // Convert to uppercase format expected by API
        selectedGameTypes.add(gameType.toUpperCase());
      }
    });
    return selectedGameTypes;
  }

  double calculateTotalPrice(double basePrice, double vatPercentage, int numberOfField) {
    double totalPrice = 0;
    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      int selectedGameTypes = getSelectedCheckboxCount(ticketIndex);
      int multiplier = numberOfField == 6 ? 1 : (selectedGameTypes == 0 ? 1 : selectedGameTypes);
      double pricePerTicket = basePrice * multiplier;
      // Calculate VAT for this ticket
      double vatAmount = pricePerTicket * (vatPercentage / 100);
      totalPrice += pricePerTicket + vatAmount;
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

  // Updated validation function
  bool _validateTicket(int ticketIndex, int numberOfField) {
    // Check if all number fields are filled
    for (int i = 0; i < numberOfField; i++) {
      if (i >= allTicketControllers[ticketIndex].length || allTicketControllers[ticketIndex][i].text.trim().isEmpty) {
        return false;
      }
    }
    // For 6-field games, check 2-digit requirement and unique numbers
    if (numberOfField == 6) {
      if (!_hasValidTwoDigitNumbers(ticketIndex, numberOfField)) {
        return false;
      }
      if (!_hasUniqueNumbers(ticketIndex, numberOfField)) {
        return false;
      }
      // Check for duplicate tickets
      if (_hasTicketDuplicates(ticketIndex, numberOfField)) {
        return false;
      }
    } else {
      // For other games, check if at least one game type is selected
      if (getSelectedCheckboxCount(ticketIndex) == 0) {
        return false;
      }
      // Check for duplicate tickets
      if (_hasTicketDuplicates(ticketIndex, numberOfField)) {
        return false;
      }
    }
    return true;
  }

  // ✅ FIXED: Ensure all numbers are properly padded before submission
  void _ensureProperPadding(int numberOfField) {
    if (numberOfField == 6) {
      for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
        for (int fieldIndex = 0; fieldIndex < numberOfField; fieldIndex++) {
          final controller = allTicketControllers[ticketIndex][fieldIndex];
          final currentText = controller.text.trim();

          if (currentText.isNotEmpty && currentText.length == 1) {
            // Auto-pad with zero
            controller.text = currentText.padLeft(2, '0');
          }
        }
      }
      setState(() {}); // Update UI to reflect changes
    }
  }

  Future<void> _handlePurchase() async {
    final provider = context.read<ProductsServices>();
    final data = provider.productsDetailData?.data;
    final numberOfField = data?.numberOfCircles ?? 0;

    _ensureProperPadding(numberOfField);

    List<Ticket> allTickets = [];
    List<List<String>> allTicketsNumbers = [];

    // Validate all tickets first
    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      if (!_validateTicket(ticketIndex, numberOfField)) {
        String errorMessage;
        if (numberOfField == 6) {
          if (!_hasValidTwoDigitNumbers(ticketIndex, numberOfField)) {
            errorMessage = 'Please enter exactly 2 digits (01-25) in each field for Ticket #${ticketIndex + 1}';
          } else if (!_hasUniqueNumbers(ticketIndex, numberOfField)) {
            errorMessage = 'Please ensure all numbers are unique for Ticket #${ticketIndex + 1}';
          } else if (_hasTicketDuplicates(ticketIndex, numberOfField)) {
            errorMessage =
                'Ticket #${ticketIndex + 1} has the same numbers as another ticket. Please choose different numbers.';
          } else {
            errorMessage = 'Please fill all number fields for Ticket #${ticketIndex + 1}';
          }
        } else {
          if (getSelectedCheckboxCount(ticketIndex) == 0) {
            errorMessage = 'Please select at least one game type for Ticket #${ticketIndex + 1}';
          } else if (_hasTicketDuplicates(ticketIndex, numberOfField)) {
            errorMessage =
                'Ticket #${ticketIndex + 1} has the same numbers as another ticket. Please choose different numbers.';
          } else {
            errorMessage = 'Please fill all number fields for Ticket #${ticketIndex + 1}';
          }
        }
        AppSnackbar.showInfoSnackbar(errorMessage);
        return;
      }
    }

    // Collect all ticket data
    for (int ticketIndex = 0; ticketIndex < widget.quantity; ticketIndex++) {
      List<String> numbers = [];
      print('Numbers: $numbers');
      for (int i = 0; i < numberOfField; i++) {
        final text = allTicketControllers[ticketIndex][i].text.trim();
        if (text.isNotEmpty) {
          if (numberOfField == 6) {
            numbers.add(text);
          } else {
            numbers.add(text);
          }
        }
      }

      List<String> selectedGameTypes = [];
      if (numberOfField != 6) {
        selectedGameTypes = getSelectedGameTypes(ticketIndex);
      }

      List<int> numbersForAPI = [];
      if (numberOfField == 6) {
        numbersForAPI = numbers.map((e) => int.tryParse(e) ?? 0).toList();
      } else {
        numbersForAPI = numbers.map((e) => int.tryParse(e) ?? 0).toList();
      }

      allTickets.add(Ticket(numbers: numbersForAPI.map((e) => e.toString()).toList(), gameTypes: selectedGameTypes));
      allTicketsNumbers.add(numbers);
    }

    // Make the purchase
    try {
      final orderNumber = await provider.purchaseTicket(
        PurchaseTicketModel(
          productId: widget.productId ?? 0,
          tickets:
              allTicketsNumbers.asMap().entries.map((entry) {
                int ticketIndex = entry.key;
                List<String> selectedGameTypes = getSelectedGameTypes(ticketIndex);
                return Ticket(numbers: entry.value, gameTypes: selectedGameTypes);
              }).toList(),
        ),
      );
      print('All Ticket Numbers: $allTicketsNumbers');
      if (orderNumber != null) {
        await provider.fetchInvoice(orderNumber, allTicketsNumbers, allTicketGameTypes);
        final invoiceData = provider.invoiceResponse;
        if (invoiceData != null) {
          final List<Map<String, bool>> ticketDetails =
              invoiceData.tickets.map((ticket) {
                return {'straight': ticket.straight == 1, 'rumble': ticket.rumble == 1, 'chance': ticket.chance == 1};
              }).toList() ??
              [];
          Get.to(
            () => GenerateInvoicePage(
              img: invoiceData.productImage,
              productName: invoiceData.productName,
              orderNumber: orderNumber,
              status: invoiceData.orderStatus,
              orderDate: invoiceData.orderDate,
              amount: invoiceData.totalAmount.toString(),
              purchasedBy: invoiceData.purchasedBy,
              vat: invoiceData.vat.toString(),
              prize: data?.product?.price ?? '',
              address: invoiceData.companyDetails.address,
              drawDate: invoiceData.drawDate,
              productImage: data?.product?.image ?? '',
              numbers: allTicketsNumbers,
              ticketDetails: ticketDetails,
            ),
          );
        } else {
          AppSnackbar.showErrorSnackbar('Failed to fetch invoice data');
        }
      } else {
        AppSnackbar.showErrorSnackbar('Purchase failed. No order number received.');
      }
    } catch (e) {
      AppSnackbar.showErrorSnackbar('Purchase failed: ${e.toString()}');
    }
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
    super.build(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('Buy Now', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Consumer<ProductsServices>(
          builder: (context, product, child) {
            final data = product.productsDetailData?.data;
            if (product.isLoading || data == null) {
              return const Center(child: AppLoading());
            }
            final numberOfField = data.numberOfCircles ?? 0;
            final price = data.product?.price;
            final vat = data.product?.vat;
            final double priceValue = double.tryParse(price ?? '0') ?? 0.0;
            final double vatValue = double.tryParse(vat ?? '0') ?? 0.0;
            final double totalAmount = calculateTotalPrice(priceValue, vatValue, numberOfField);
            final double finalPrice = totalAmount;
            final double vatAmount = calculateTotalVAT(priceValue, vatValue, numberOfField);

            if (_dataFetched && data == null && !product.isLoading) {
              return const Center(child: AppText('Nothing found!!'));
            }

            // Ensure controllers are initialized when data is loaded
            if (allTicketControllers.isEmpty) {
              _initializeControllers();
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
                        AppText("Total Amount: AED ${finalPrice.toStringAsFixed(0)}", fontSize: 16.sp),
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
                    bool hasDuplicates = _hasTicketDuplicates(ticketIndex, numberOfField);
                    bool hasUniqueNumbers = _hasUniqueNumbers(ticketIndex, numberOfField);
                    bool hasValidTwoDigitNumbers = _hasValidTwoDigitNumbers(ticketIndex, numberOfField);
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: hasDuplicates ? Border.all(color: Colors.red, width: 2) : null,
                      ),
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
                                width: 42.w,
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
                                      // Only for 6-field tickets
                                      if (numberOfField == 6) {
                                        if (newValue.text.length > 2) return oldValue;
                                        final currentText = newValue.text;
                                        final parsed = int.tryParse(currentText);
                                        if (parsed == null) return oldValue;
                                        // Only check duplicates for full 2-digit numbers
                                        if (currentText.length == 2) {
                                          // Get all other values in this ticket
                                          final otherValues =
                                              allTicketControllers[ticketIndex]
                                                  .asMap()
                                                  .entries
                                                  .where((entry) => entry.key != fieldIndex) // skip current field
                                                  .map((entry) => entry.value.text.trim())
                                                  .where((text) => text.length == 2)
                                                  .toSet();
                                          if (otherValues.contains(currentText)) {
                                            // Duplicate found — block input
                                            AppSnackbar.showInfoSnackbar("Duplicate number not allowed: $currentText");
                                            return oldValue;
                                          }
                                          // Range check
                                          if (parsed < 1 || parsed > 25) {
                                            return oldValue;
                                          }
                                        }
                                        return newValue;
                                      }
                                      // For other games
                                      if (newValue.text.length > 1) return oldValue;
                                      final num = int.tryParse(newValue.text);
                                      if (num == null || num < 0 || num > 9) return oldValue;
                                      return newValue;
                                    }),
                                  ],
                                  onChanged: (value) {
                                    // ✅ FIXED: Only auto-navigate when 2 digits are entered for 6-field games
                                    if (numberOfField == 6) {
                                      if (value.length == 2) {
                                        // Move focus when 2 digits are entered
                                        if (fieldIndex < numberOfField - 1) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(allTicketFocusNodes[ticketIndex][fieldIndex + 1]);
                                        } else {
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                      // No auto-navigation for single digits - let user manually navigate
                                    } else {
                                      // For other games: move focus after 1 digit
                                      if (value.length == 1) {
                                        if (fieldIndex < numberOfField - 1) {
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(allTicketFocusNodes[ticketIndex][fieldIndex + 1]);
                                        } else {
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                    }
                                    // Update UI state
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: secondaryColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          (numberOfField == 6 && (!hasUniqueNumbers || !hasValidTwoDigitNumbers)) ||
                                                  hasDuplicates
                                              ? const BorderSide(color: Color.fromARGB(255, 146, 60, 53), width: 2)
                                              : BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          (numberOfField == 6 && (!hasUniqueNumbers || !hasValidTwoDigitNumbers)) ||
                                                  hasDuplicates
                                              ? const BorderSide(color: Colors.red, width: 2)
                                              : BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          (numberOfField == 6 && (!hasUniqueNumbers || !hasValidTwoDigitNumbers)) ||
                                                  hasDuplicates
                                              ? const BorderSide(color: Colors.red, width: 2)
                                              : const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              );
                            }),
                          ),
                          if ((numberOfField == 6 && (!hasUniqueNumbers || !hasValidTwoDigitNumbers)) || hasDuplicates)
                            if (!hasValidTwoDigitNumbers || hasDuplicates || !hasUniqueNumbers)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: AppText(
                                  hasDuplicates
                                      ? "This ticket has the same numbers as another ticket."
                                      : !hasValidTwoDigitNumbers
                                      ? ""
                                      : "Numbers must be unique (01-25)",
                                  color: const Color.fromARGB(255, 232, 23, 8),
                                  fontSize: 12.sp,
                                  textAlign: TextAlign.center,
                                ),
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
                  Consumer<ProductsServices>(
                    builder: (context, product, child) {
                      return PrimaryButton(
                        isLoading: product.isLoading,
                        onTap: _handlePurchase,
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
