import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ... (existing imports remain the same)

class PrintButton extends StatefulWidget {
  const PrintButton({
    super.key,
    required this.orderNumber,
    required this.productName,
    required this.purchasedBy,
    required this.vat,
    required this.status,
    required this.amount,
    required this.orderDate,
    required this.drawDate,
    required this.prize,
    required this.productImage,
    required this.numbers,
    required this.address,
    required this.printController, // Added
    required this.onPrintComplete, // Added
  });

  final String orderNumber;
  final String productName;
  final String purchasedBy;
  final String vat;
  final String status;
  final String amount;
  final String orderDate;
  final String drawDate;
  final String prize;
  final String productImage;
  final List<dynamic> numbers;
  final String address;
  final AnimationController printController; // Added
  final VoidCallback onPrintComplete; // Added

  @override
  State<PrintButton> createState() => _PrintButtonState();
}

class _PrintButtonState extends State<PrintButton> {
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToProductsPage(BuildContext context) {
    Get.offAll(() => BottomNavigationBarPage());
  }

  Future<void> _handlePrint() async {
    setState(() {
      _isPrinting = true;
    });
    try {
      HapticFeedback.lightImpact();
      final pdfData = await generatePdf();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice_${widget.orderNumber}.pdf');
      await file.writeAsBytes(pdfData);

      if (mounted) {
        AppSnackbar.showSuccessSnackbar('Invoice prepared for printing');
      }
    } catch (e) {
      log('Error preparing print: $e');
      if (mounted) {
        AppSnackbar.showErrorSnackbar('Error preparing print: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
        widget.onPrintComplete(); // Trigger parent's animation and navigation
      }
    }
  }

  Future<Uint8List> generatePdf() async {
    final bytes = await rootBundle.load('assets/images/logo.png');
    final logo = pw.MemoryImage(bytes.buffer.asUint8List());

    pw.MemoryImage? productImg;
    try {
      if (widget.productImage.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.productImage));
        if (response.statusCode == 200) {
          productImg = pw.MemoryImage(response.bodyBytes);
        }
      } else {
        final byte = await rootBundle.load(widget.productImage);
        productImg = pw.MemoryImage(byte.buffer.asUint8List());
      }
    } catch (e) {
      log('Error loading product image: $e');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build:
            (context) => [
              pw.Center(child: pw.Image(logo, height: 60, width: 120)),
              pw.SizedBox(height: 20),
              pw.Container(
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
              productImg != null
                  ? pw.Center(child: pw.Image(productImg, height: 100, width: 80))
                  : pw.Container(
                    height: 100,
                    width: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Center(
                      child: pw.Text('No Image', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                    ),
                  ),
              pw.SizedBox(height: 20),
              pw.Column(
                children: [
                  invoiceRow('Product Name:', widget.productName),
                  invoiceRow('Purchased By:', widget.purchasedBy),
                  invoiceRow('Order:', widget.orderNumber),
                  invoiceRow('VAT %:', widget.vat),
                  invoiceRow('Order Status:', widget.status),
                  invoiceRow('Total Value:', widget.amount),
                  invoiceRow('Order Date:', widget.orderDate),
                  invoiceRow('Draw Date:', widget.drawDate),
                  invoiceRow('Reflex Draw Prize:', widget.prize, bold: true),
                  invoiceRow('Total Tickets:', widget.numbers.length.toString()),
                ],
              ),
              pw.SizedBox(height: 20),
              buildAllTicketsGrid(widget.numbers),
              pw.SizedBox(height: 20),
              pw.Text(
                "Don't give up! You could be the next millionaire or winner in the upcoming draws.",
                style: pw.TextStyle(fontSize: 16, color: PdfColors.red),
                textAlign: pw.TextAlign.center,
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
            ],
        footer:
            (context) => pw.Column(
              children: [
                pw.Text(widget.address, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 8),
                pw.Text(
                  "Website: https://foryouwin.com/user/login",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  String generateQRData() {
    return "Order: ${widget.orderNumber}, Buyer: ${widget.purchasedBy}";
  }

  pw.Widget invoiceRow(String title, String value, {bool bold = false, double fontSize = 14}) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: fontSize)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget buildAllTicketsGrid(List<dynamic> numbers) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          numbers
              .map(
                (num) => pw.Container(
                  width: 50,
                  height: 50,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(num, style: pw.TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isPrinting ? null : _handlePrint,
      icon:
          _isPrinting
              ? SizedBox(height: 20.h, width: 20.h, child: Center(child: CircularProgressIndicator(color: whiteColor)))
              : const Icon(Icons.print),
      label: AppText(_isPrinting ? 'Printing..' : 'Print', fontSize: 14.sp, color: whiteColor),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

//
// PrintButton(
//                                   orderNumber: widget.orderNumber,
//                                   productName: widget.productName,
//                                   purchasedBy: widget.purchasedBy,
//                                   vat: widget.vat,
//                                   status: widget.status,
//                                   amount: widget.amount,
//                                   orderDate: widget.orderDate,
//                                   drawDate: widget.drawDate,
//                                   prize: widget.prize,
//                                   productImage: widget.productImage,
//                                   numbers: widget.numbers.map((e) => e.toString()).toList(),
//                                   address: widget.address,
//                                   printController: _printController,
//                                   onPrintComplete: _onPrintComplete,
//                                 ),
