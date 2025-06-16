// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
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
  final String prdouctImage;
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
    required this.prdouctImage,
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
          await showPdfViewer(context, pdfData);
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
          Navigator.of(context).pop();
        }
      }
    });
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

  pw.Widget buildNumbersGrid(List<dynamic> numbers) {
    List<pw.Widget> rows = [];

    // Create rows of 6 numbers each
    for (int i = 0; i < numbers.length; i += 6) {
      List<dynamic> rowNumbers = numbers.skip(i).take(6).toList();

      rows.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children:
              rowNumbers.map((number) {
                return pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      number.toString(),
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
        ),
      );

      if (i + 6 < numbers.length) {
        rows.add(pw.SizedBox(height: 8));
      }
    }

    return pw.Column(children: rows);
  }

  Future<Uint8List> generatePdf() async {
    final bytes = await rootBundle.load('assets/images/logo.png');
    final image = pw.MemoryImage(bytes.buffer.asUint8List());

    // Load product image from network or assets
    pw.MemoryImage? img;
    try {
      if (widget.prdouctImage.startsWith('http')) {
        final response = await http.get(Uri.parse(widget.prdouctImage));
        if (response.statusCode == 200) {
          img = pw.MemoryImage(response.bodyBytes);
        }
      } else {
        final byte = await rootBundle.load(widget.prdouctImage);
        img = pw.MemoryImage(byte.buffer.asUint8List());
      }
    } catch (e) {
      print('Error loading product image: $e');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header with Logo!!
              pw.Center(child: pw.Image(image, height: 60, width: 120)),
              pw.SizedBox(height: 20),

              // Dashed border container for product info!!
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

              // Product Image
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
                  child: pw.Center(
                    child: pw.Text('No Image', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Invoice Details
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    invoiceRow('Product Name:', widget.productName, fontSize: 16),
                    invoiceRow('Purchased By:', widget.purchasedBy, fontSize: 16),
                    invoiceRow('Order:', widget.orderNumber, fontSize: 16),
                    invoiceRow('VAT %:', widget.vat, fontSize: 16),
                    invoiceRow('Order Status:', widget.status, fontSize: 16),
                    invoiceRow('Total Value:', widget.amount, fontSize: 16),
                    invoiceRow('Order Date:', widget.orderDate, fontSize: 16),
                    invoiceRow('Draw Date:', widget.drawDate, fontSize: 16),
                    invoiceRow('Reflex Draw Prize:', widget.prize, bold: true, fontSize: 16),
                    invoiceRow('Order Number:', widget.orderNumber, fontSize: 16),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Numbers Grid
              buildNumbersGrid(widget.numbers),
              pw.SizedBox(height: 20),
              // Warning message
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
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: generateQRData(), width: 120, height: 120),
                    pw.SizedBox(height: 8),
                    pw.Text(widget.orderNumber, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Spacer(),

              // Footer Address
              pw.Container(
                width: double.infinity,
                child: pw.Text(widget.address, style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                child: pw.Text(
                  "Website: https://4uwin.ae",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> showPdfViewer(BuildContext context, Uint8List pdfData) async {
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
                    AppText('Generating invoice...', fontSize: 14.sp),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}

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
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(2.r)),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText('Invoice ', fontSize: 20.sp, fontWeight: FontWeight.bold),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), tooltip: 'Close'),
              ],
            ),
          ),
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
}
