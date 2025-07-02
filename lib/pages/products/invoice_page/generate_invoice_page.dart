// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/pages/products/invoice_page/components/generate_qr_component.dart';
import 'package:for_u_win/pages/products/invoice_page/components/info_row.dart';
import 'package:for_u_win/pages/products/invoice_page/components/quote.dart';
import 'package:for_u_win/pages/products/invoice_page/components/ticket_number_component.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

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
  late AnimationController _slideController;
  late AnimationController _printController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _printAnimation;

  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();

    // Controller for initial slide in
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    // Controller for print slide up animation
    _printController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _printAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: _printController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();

      Future.delayed(const Duration(milliseconds: 800), () {
        _handlePrint();
      });
    });
  }

  Future<void> _printTextRow(String title, String value) async {
    await SunmiPrinter.printText('$title $value');
  }

  Future<void> _handlePrint() async {
    if (_isPrinting) return;

    setState(() {
      _isPrinting = true;
    });

    try {
      final isAvailable = await SunmiPrinter.bindingPrinter();
      if (isAvailable ?? true) {
        AppSnackbar.showErrorSnackbar('Printer not connected.');
        return;
      }
      AppSnackbar.showSuccessSnackbar('Printing...');
      HapticFeedback.mediumImpact();
      _printController.forward();

      await SunmiPrinter.startTransactionPrint(true);

      // Logo
      final ByteData byteData = await rootBundle.load('assets/images/logo.png');
      final Uint8List imageBytes = byteData.buffer.asUint8List();
      await SunmiPrinter.setAlignment(Alignment.center);
      await SunmiPrinter.printImage(imageBytes);

      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(widget.productName);
      await SunmiPrinter.line();

      await SunmiPrinter.setAlignment(Alignment.bottomLeft);
      await _printTextRow('Order No:', widget.orderNumber);
      await _printTextRow('Order Date:', widget.orderDate);
      await _printTextRow('Status:', widget.status);
      await _printTextRow('Buyer:', widget.purchasedBy);
      await _printTextRow('Total:', 'PKR ${widget.amount}');
      await _printTextRow('Draw Date:', widget.drawDate);
      await _printTextRow('Prize:', widget.prize);
      await SunmiPrinter.lineWrap(1);

      for (int i = 0; i < widget.numbers.length; i++) {
        await SunmiPrinter.printText('Ticket #${i + 1}');
        final numberLine = widget.numbers[i].map((n) => n.toString().padLeft(2, '0')).join('  ');
        await SunmiPrinter.printText(numberLine);
        await SunmiPrinter.lineWrap(1);
      }

      await SunmiPrinter.line();
      await SunmiPrinter.setAlignment(Alignment.center);
      await SunmiPrinter.printText("Don't give up! You could be the next winner.");
      await SunmiPrinter.lineWrap(1);

      String qrData = 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
      await SunmiPrinter.printQRCode(qrData);

      await SunmiPrinter.lineWrap(2);
      await SunmiPrinter.printText(widget.address);

      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.exitTransactionPrint(true);

      AppSnackbar.showSuccessSnackbar('✅ Printed Successfully!');
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(seconds: 1), _navigateBack);
    } catch (e) {
      log('❌ Print error: $e');
      AppSnackbar.showErrorSnackbar('Print failed: ${e.toString()}');
      _printController.reset();
      Future.delayed(const Duration(seconds: 1), _navigateBack);
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  void _navigateBack() {
    Get.offAll(() => BottomNavigationBarPage());
  }

  String _generateQRData() {
    return 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    // Load logo
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Load product image
    pw.MemoryImage? productImg;
    try {
      if (widget.productImage.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.productImage));
        if (response.statusCode == 200) {
          productImg = pw.MemoryImage(response.bodyBytes);
        }
      } else {
        final bytes = await rootBundle.load(widget.productImage);
        productImg = pw.MemoryImage(bytes.buffer.asUint8List());
      }
    } catch (e) {
      log('Product image load error: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              // Header
              pw.Center(child: pw.Image(logoImage, height: 60, width: 120)),
              pw.SizedBox(height: 20),

              // Product name
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(widget.productName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.SizedBox(height: 20),

              // Product image
              if (productImg != null) ...[
                pw.Center(child: pw.Image(productImg, height: 100, width: 80)),
                pw.SizedBox(height: 20),
              ],

              // Invoice details
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    _pdfRow('Product Name:', widget.productName),
                    _pdfRow('Purchased By:', widget.purchasedBy),
                    _pdfRow('Order No:', widget.orderNumber),
                    _pdfRow('VAT %:', widget.vat),
                    _pdfRow('Order Status:', widget.status),
                    _pdfRow('Total Value:', widget.amount),
                    _pdfRow('Order Date:', widget.orderDate),
                    _pdfRow('Draw Date:', widget.drawDate),
                    _pdfRow('Reflex Draw Prize:', widget.prize, bold: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Ticket numbers
              _buildTicketsGrid(widget.numbers),
              pw.SizedBox(height: 20),

              // Motivational quote
              pw.Container(
                width: double.infinity,
                child: pw.Text(
                  "Don't give up! You could be the next millionaire or winner in the upcoming draws.",
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.red),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 20),

              // QR Code
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: _generateQRData(), width: 120, height: 120),
                    pw.SizedBox(height: 8),
                    pw.Text(widget.orderNumber, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
        footer:
            (context) => pw.Container(
              width: double.infinity,
              child: pw.Text(widget.address, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
            ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String title, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 16)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTicketsGrid(List<dynamic> allTickets) {
    List<pw.Widget> ticketWidgets = [];

    for (int i = 0; i < allTickets.length; i++) {
      List<dynamic> ticketNumbers = allTickets[i];

      // Ticket header
      ticketWidgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Text(
            'Ticket #${i + 1}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      );

      // Ticket numbers grid
      List<pw.Widget> rows = [];
      for (int j = 0; j < ticketNumbers.length; j += 6) {
        List<dynamic> rowNumbers = ticketNumbers.skip(j).take(6).toList();

        rows.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children:
                rowNumbers
                    .map(
                      (number) => pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.black),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            number.toString().padLeft(2, '0'),
                            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        );

        if (j + 6 < ticketNumbers.length) {
          rows.add(pw.SizedBox(height: 6));
        }
      }

      ticketWidgets.add(pw.Column(children: rows));

      if (i < allTickets.length - 1) {
        ticketWidgets.add(pw.SizedBox(height: 16));
      }
    }

    return pw.Column(children: ticketWidgets);
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
      backgroundColor: Colors.black.withOpacity(0.5),
      body: GestureDetector(
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
                    // Handle bar
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: _isPrinting ? Colors.orange[300] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header
                    Container(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            _isPrinting ? 'Printing...' : 'Invoice',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: _isPrinting ? Colors.orange[600] : null,
                          ),
                          if (!_isPrinting)
                            GestureDetector(
                              onTap: _navigateBack,
                              child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                            )
                          else
                            Icon(Icons.print, size: 24.sp, color: Colors.orange[600]),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo
                            Image.asset('assets/images/logo.png', height: 80.h),
                            SizedBox(height: 16.h),

                            // Product name
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

                            // Invoice details
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
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // Ticket numbers
                            TicketNumbersWidget(numbers: widget.numbers),
                            SizedBox(height: 24.h),

                            // QR Code
                            GenerateQrComponent(
                              orderNumber: widget.orderNumber,
                              productName: widget.productName,
                              orderDate: widget.orderDate,
                            ),
                            SizedBox(height: 16.h),

                            // Motivational quote
                            MotivationalQuote(
                              content:
                                  "Don't give up! You could be the next millionaire or winner in the upcoming draws.",
                            ),
                            SizedBox(height: 16.h),

                            // Address
                            AppText(
                              widget.address,
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              textAlign: TextAlign.center,
                            ),
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
    );
  }
}
