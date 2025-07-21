// ✅ File: generate_invoice_page.dart - FIXED VERSION WITH SMOOTH NAVIGATION

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/pages/products/invoice_page/components/generate_qr_component.dart';
import 'package:for_u_win/pages/products/invoice_page/components/header.dart';
import 'package:for_u_win/pages/products/invoice_page/components/invoice_detail.dart';
import 'package:for_u_win/pages/products/invoice_page/components/product_name_card.dart';
import 'package:for_u_win/pages/products/invoice_page/components/quote.dart';
import 'package:for_u_win/pages/products/invoice_page/components/ticket_number_component.dart';
import 'package:for_u_win/pages/products/invoice_page/invoice_service.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class GenerateInvoicePage extends StatefulWidget {
  final String img;
  final String productName;
  final String orderNumber;
  final String status;
  final String orderDate;
  final String amount;
  final String purchasedBy;
  final String vat;
  final String prize;
  final String address;
  final String drawDate;
  final String productImage;
  final List<Map<String, bool>>? ticketDetails;
  final List<dynamic> numbers;
  const GenerateInvoicePage({
    super.key,
    required this.img,

    required this.productName,
    required this.orderNumber,
    required this.status,
    required this.orderDate,
    required this.amount,
    required this.purchasedBy,
    required this.vat,
    required this.prize,
    required this.address,
    required this.drawDate,
    required this.numbers,
    required this.productImage,
    required this.ticketDetails,
  });

  @override
  State<GenerateInvoicePage> createState() => _GenerateInvoicePageState();
}

class _GenerateInvoicePageState extends State<GenerateInvoicePage> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _printController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _printAnimation;
  bool _isPrinting = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _printController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _printAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: _printController, curve: Curves.easeInOut));

    // Add animation listener to handle navigation
    _printController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isNavigating) {
        _performNavigation();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _requestPermissions().then((_) {
        Future.delayed(const Duration(milliseconds: 1000), _handlePrintWithService);
      });
    });
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      final permissions = [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.storage,
      ];
      for (var permission in permissions) {
        if (await permission.isDenied) {
          await permission.request();
        }
      }
      debugPrint('Permissions requested');
    } catch (e) {
      debugPrint('Permission request failed: $e');
      AppSnackbar.showErrorSnackbar('Permission request failed: $e');
    }
  }

  Future<void> _handlePrintWithService() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);

    try {
      AppSnackbar.showSuccessSnackbar('🖨️ Processing invoice...');

      // Print or generate PDF
      final success = await SunmiPrintService.printInvoice(
        orderNumber: widget.orderNumber,
        productName: widget.productName,
        orderDate: widget.orderDate,
        amount: widget.amount,
        drawDate: widget.drawDate,
        purchasedBy: widget.purchasedBy,
        vat: widget.vat,
        // ticketDetail: widget.ticketDetails,
        prize: widget.prize,
        status: widget.status,
        numbers: widget.numbers,
        address: widget.address,
      );

      if (success) {
        final pdfPath = await SunmiPrintService.generatePdfInvoice(
          orderNumber: widget.orderNumber,
          productName: widget.productName,
          orderDate: widget.orderDate,
          amount: widget.amount,
          productImg: widget.productImage,
          drawDate: widget.drawDate,
          purchasedBy: widget.purchasedBy,
          vat: widget.vat,
          prize: widget.prize,
          ticketDetail: widget.ticketDetails,
          status: widget.status,
          numbers: widget.numbers,
          address: widget.address,
        );
        if (pdfPath.isNotEmpty) {
          AppSnackbar.showSuccessSnackbar('Invoice processed. PDF saved at: $pdfPath');
          await OpenFile.open(pdfPath);
        } else {
          AppSnackbar.showSuccessSnackbar('Invoice printed successfully!');
        }
        HapticFeedback.heavyImpact();

        _printController.forward();
      } else {
        throw Exception('Invoice processing failed');
      }
    } catch (e) {
      debugPrint('Print service error: $e');
      String errorMessage = 'Invoice processing failed';
      if (e.toString().contains('lateinit')) {
        errorMessage = 'Printer not initialized. Please use a Sunmi POS device or check connection.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'Printer not found. Check device compatibility.';
      } else if (e.toString().contains('paper')) {
        errorMessage = 'Printer out of paper. Please check paper roll.';
      }
      AppSnackbar.showErrorSnackbar(errorMessage);
      _printController.reset();
      await Future.delayed(const Duration(seconds: 2));
      _navigateBack();
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  // Perform navigation when animation completes
  void _performNavigation() {
    if (_isNavigating) return;
    _isNavigating = true;

    if (mounted) {
      Get.offAll(() => BottomNavigationBarPage(), transition: Transition.noTransition, duration: Duration.zero);
    }
  }

  // Test print for debugging

  Future<void> handleTestPrint() async {
    final success = await SunmiPrintService.testPrint();
    if (success) {
      AppSnackbar.showSuccessSnackbar('Test print successful or PDF generated!');
    } else {
      AppSnackbar.showErrorSnackbar('Test print failed');
    }
  }

  // Check printer availability for debugging
  Future<void> checkPrinterAvailability() async {
    final isAvailable = await SunmiPrintService.checkPrinterAvailability();
    AppSnackbar.showInfoSnackbar('Printer ${isAvailable ? 'Available' : 'Not Available'}');
  }

  // Manually check printer status for debugging
  Future<void> checkPrinterStatus() async {
    final initialized = await SunmiPrintService.initialize();
    AppSnackbar.showInfoSnackbar('Printer Status: ${initialized ? 'Ready' : 'Not Ready'}');
  }

  void _navigateBack() {
    if (_isNavigating) return;
    _isNavigating = true;

    if (mounted) {
      Get.offAll(
        () => BottomNavigationBarPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _printController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPrinting ? Colors.transparent : Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          if (_isPrinting) BottomNavigationBarPage(),

          // Overlay content
          GestureDetector(
            onTap: _isPrinting ? null : _navigateBack,
            child: SlideTransition(
              position: _printAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Header(isPrinting: _isPrinting, onClose: _navigateBack),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                Image.asset('assets/images/logo.png', height: 80.h),
                                SizedBox(height: 16.h),
                                ProductNameCard(widget.productName),
                                SizedBox(height: 16.h),
                                InvoiceDetails(widget: widget),
                                SizedBox(height: 24.h),
                                TicketNumbersWidget(numbers: widget.numbers),
                                SizedBox(height: 24.h),
                                GenerateQrComponent(
                                  orderNumber: widget.orderNumber,
                                  productName: widget.productName,
                                  orderDate: widget.orderDate,
                                ),
                                SizedBox(height: 16.h),
                                MotivationalQuote(
                                  content:
                                      "Don't give up! You could be the next millionaire or winner in the upcoming draws.",
                                ),
                                SizedBox(height: 16.h),
                                AppText(
                                  widget.address,
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24.h),

                                // if (kDebugMode)
                                //   Row(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       ElevatedButton(onPressed: _handleTestPrint, child: const Text('Test Print')),
                                //       const SizedBox(width: 16),
                                //       ElevatedButton(
                                //         onPressed: _checkPrinterAvailability,
                                //         child: const Text('Check Printer'),
                                //       ),
                                //       const SizedBox(width: 16),
                                //       ElevatedButton(onPressed: _checkPrinterStatus, child: const Text('Check Status')),
                                //     ],
                                //   ),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
