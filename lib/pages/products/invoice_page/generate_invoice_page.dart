// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/pages/products/invoice_page/components/generate_qr_component.dart';
import 'package:for_u_win/pages/products/invoice_page/components/info_row.dart';
import 'package:for_u_win/pages/products/invoice_page/components/quote.dart';
import 'package:for_u_win/pages/products/invoice_page/components/ticket_number_component.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
  });

  @override
  State<GenerateInvoicePage> createState() => _GenerateInvoicePageState();
}

class _GenerateInvoicePageState extends State<GenerateInvoicePage> with TickerProviderStateMixin {
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController printController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> printSlideAnimation;

  bool isVisible = false;
  bool isPrinting = false;

  final GlobalKey invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    fadeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    printController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeIn));

    printSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: printController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInvoice();
      handlePrint();
      Future.delayed(const Duration(seconds: 0), () {
        if (mounted) {}
      });
    });
  }

  void showInvoice() {
    setState(() {
      isVisible = true;
    });
    slideController.forward();
    fadeController.forward();
  }

  void _navigateToProductsPage(BuildContext context) async {
    Get.offAll(() => BottomNavigationBarPage());
  }

  Future<void> handlePrint() async {
    setState(() {
      isPrinting = true;
    });

    try {
      HapticFeedback.lightImpact();
      final pdfData = await generatePdf();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice_${widget.orderNumber}.pdf');
      await file.writeAsBytes(pdfData);

      printController.forward();
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        AppSnackbar.showSuccessSnackbar('Invoice printed successfully!!');
      }
    } catch (e) {
      log('Error preparing print: $e');
      if (mounted) {
        AppSnackbar.showErrorSnackbar('Error preparing print: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isPrinting = false;
        });
        _navigateToProductsPage(context);
      }
    }
  }

  String generateQRData() {
    return 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
  }

  pw.Widget invoiceRow(String title, String value, {bool bold = false, double fontSize = 18}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget buildAllTicketsGrid(List<dynamic> allTicketsNumbers) {
    List<pw.Widget> ticketWidgets = [];

    for (int ticketIndex = 0; ticketIndex < allTicketsNumbers.length; ticketIndex++) {
      List<dynamic> ticketNumbers = allTicketsNumbers[ticketIndex];

      ticketWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Text(
            'Ticket #${ticketIndex + 1}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );

      ticketWidgets.add(buildSingleTicketGrid(ticketNumbers));

      if (ticketIndex < allTicketsNumbers.length - 1) {
        ticketWidgets.add(pw.SizedBox(height: 16));
      }
    }

    return pw.Column(children: ticketWidgets);
  }

  pw.Widget buildSingleTicketGrid(List<dynamic> numbers) {
    List<pw.Widget> rows = [];

    for (int i = 0; i < numbers.length; i += 6) {
      List<dynamic> rowNumbers = numbers.skip(i).take(6).toList();

      rows.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children:
              rowNumbers.map((number) {
                return pw.Container(
                  width: 40,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      number.toString().padLeft(2, '0'),
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
        ),
      );

      if (i + 6 < numbers.length) {
        rows.add(pw.SizedBox(height: 6));
      }
    }

    return pw.Column(children: rows);
  }

  Future<Uint8List> generatePdf() async {
    final bytes = await rootBundle.load('assets/images/logo.png');
    final image = pw.MemoryImage(bytes.buffer.asUint8List());

    pw.MemoryImage? img;
    try {
      if (widget.productImage.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.productImage));
        if (response.statusCode == 200) {
          img = pw.MemoryImage(response.bodyBytes);
        }
      } else {
        final byte = await rootBundle.load(widget.productImage);
        img = pw.MemoryImage(byte.buffer.asUint8List());
      }
    } catch (e) {
      log('Error loading product image: $e');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Center(child: pw.Image(image, height: 60, width: 120)),
            pw.SizedBox(height: 20),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(widget.productName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
            ),
            pw.SizedBox(height: 20),
            if (img != null) ...[
              pw.Center(child: pw.Image(img, height: 100, width: 80)),
              pw.SizedBox(height: 20),
            ] else ...[
              pw.Container(
                height: 100,
                width: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(child: pw.Text('No Image', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey))),
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                children: [
                  invoiceRow('Product Name:', widget.productName, fontSize: 16),
                  invoiceRow('Purchased By:', widget.purchasedBy, fontSize: 16),
                  invoiceRow('Order No:', widget.orderNumber, fontSize: 16),
                  invoiceRow('VAT %:', widget.vat, fontSize: 16),
                  invoiceRow('Order Status:', widget.status, fontSize: 16),
                  invoiceRow('Total Value:', widget.amount, fontSize: 16),
                  invoiceRow('Order Date:', widget.orderDate, fontSize: 16),
                  invoiceRow('Draw Date:', widget.drawDate, fontSize: 16),
                  invoiceRow('Reflex Draw Prize:', widget.prize, bold: true, fontSize: 16),
                  // invoiceRow('Total Tickets:', widget.numbers.length.toString(), fontSize: 16),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            buildAllTicketsGrid(widget.numbers),
            pw.SizedBox(height: 20),
            pw.Container(
              width: double.infinity,
              child: pw.Text(
                "Don't give up! You could be the next millionaire or winner in the upcoming draws.",
                style: pw.TextStyle(fontSize: 16, color: PdfColors.red),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: generateQRData(), width: 120, height: 120),
                  pw.SizedBox(height: 8),
                  pw.Text(widget.orderNumber, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ];
        },
        footer:
            (context) => pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(widget.address, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    "Website: https://foryouwin.com/user/login",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    printController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: GestureDetector(
        onTap: () => _navigateToProductsPage(context),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SlideTransition(
            position: printSlideAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
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
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
                        ),
                        Container(
                          padding: EdgeInsets.all(20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText('Invoice', fontSize: 20.sp, fontWeight: FontWeight.bold),
                              GestureDetector(
                                onTap: () => _navigateToProductsPage(context),
                                child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: RepaintBoundary(
                            key: invoiceKey,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/logo.png', height: 80.h),
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: AppText(
                                      widget.productName,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.network(widget.productImage, height: 60.h),
                                        SizedBox(height: 10.h),
                                        infoRow('Product:', widget.productName),
                                        Divider(),
                                        infoRow(
                                          'Total Price:',
                                          '${(double.tryParse(widget.amount) ?? 0).toStringAsFixed(0)} AED',
                                        ),
                                        Divider(),
                                        infoRow('Order No:', '#${widget.orderNumber}'),
                                        Divider(),
                                        infoRow('VAT %:', widget.vat),
                                        Divider(),
                                        infoRow('Order Status:', widget.status, isHighlighted: true),
                                        Divider(),
                                        infoRow('Order Date:', widget.orderDate),
                                        Divider(),
                                        infoRow('Draw Date:', widget.drawDate),
                                        Divider(),
                                        infoRow('Reflex Draw Prize:', 'Rs.${widget.prize}', isHighlighted: true),
                                        Divider(),
                                        // infoRow('Total Tickets:', widget.numbers.length.toString()),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  // Ticket Numbers Components!!
                                  TicketNumbersWidget(numbers: widget.numbers),
                                  SizedBox(height: 24.h),
                                  // Generate QR Code Components!!
                                  GenerateQrComponent(
                                    orderNumber: widget.orderNumber,
                                    productName: widget.productName,
                                    orderDate: widget.orderDate,
                                  ),
                                  SizedBox(height: 16.h),
                                  // Motivational Quote!!
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
                                  SizedBox(height: 8.h),
                                  AppText(
                                    'Website: https://foryouwin.com/user/login',
                                    fontSize: 12.sp,
                                    color: Colors.blue,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24.h),
                                  // Show printing status
                                  if (isPrinting) ...[
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          AppText(
                                            'Printing invoice...',
                                            fontSize: 16.sp,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                  ],
                                ],
                              ),
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
        ),
      ),
    );
  }
}
