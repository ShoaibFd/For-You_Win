// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  });

  @override
  State<GenerateInvoicePage> createState() => _GenerateInvoicePageState();
}

class _GenerateInvoicePageState extends State<GenerateInvoicePage> {
  bool _isGeneratingPdf = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final pdfData = await generatePdf();
        if (mounted) {
          setState(() {
            _isGeneratingPdf = false;
          });
          // Show PDF directly and pop when closed
          await _showPdfViewer(context, pdfData);
          // Return to previous page after PDF viewer is closed
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isGeneratingPdf = false;
          });
          AppSnackbar.showErrorSnackbar('Error generating PDF: $e');
          // Return to previous page on error
          Navigator.of(context).pop();
        }
      }
    });
  }

  String _generateQRData() {
    return 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              pw.Text('Product: ${widget.productName}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Order Number: ${widget.orderNumber}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Order Status: ${widget.status}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Purchased By: ${widget.purchasedBy}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Amount: ${widget.amount}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('VAT: ${widget.vat}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Prize: ${widget.prize}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Order Date: ${widget.orderDate}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Draw Date: ${widget.drawDate}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Address: ${widget.address}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Numbers: ${widget.numbers.join(', ')}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: _generateQRData(), width: 130, height: 130),
                    pw.SizedBox(height: 8),
                    pw.Text(widget.orderNumber, style: pw.TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _showPdfViewer(BuildContext context, Uint8List pdfData) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => PdfViewerBottomSheet(pdfData: pdfData, orderNumber: widget.orderNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isGeneratingPdf
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoading(),
                    SizedBox(height: 16.h),
                    AppText('Generating invoice...', fontSize: 16.sp),
                  ],
                ),
              )
              : const SizedBox.shrink(), // Hide content after PDF is shown
    );
  }
}

// Alternative PDF Viewer using the printing package
class PdfViewerBottomSheet extends StatelessWidget {
  final Uint8List pdfData;
  final String orderNumber;

  const PdfViewerBottomSheet({super.key, required this.pdfData, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2.r)),
          ),
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Invoice Preview', fontSize: 18.sp, fontWeight: FontWeight.bold),
                Row(
                  children: [
                    IconButton(onPressed: () => _printPdf(context), icon: const Icon(Icons.print), tooltip: 'Print'),
                    IconButton(onPressed: () => _sharePdf(context), icon: const Icon(Icons.share), tooltip: 'Share'),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PDF Preview
          Expanded(
            child: PdfPreview(
              build: (format) => pdfData,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canDebug: false,
              maxPageWidth: MediaQuery.of(context).size.width,
              pdfFileName: 'invoice_$orderNumber.pdf',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(onLayout: (format) async => pdfData);
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showErrorSnackbar('Error printing PDF: $e');
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await Printing.sharePdf(bytes: pdfData, filename: 'invoice_$orderNumber.pdf');
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showErrorSnackbar('Error sharing PDF: $e');
      }
    }
  }
}
