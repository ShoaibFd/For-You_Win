import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class InvoicePrintService {
  static bool _isInitialized = false;
  static const int _maxRetries = 3;
  static const int _statusDelayMs = 1000;
  static final SunmiPrinterPlus _printer = SunmiPrinterPlus();

  static Future<bool> _isSunmiDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.manufacturer.toLowerCase().contains('sunmi');
      }
      return false;
    } catch (e) {
      debugPrint('Failed to check device type: $e');
      return false;
    }
  }

  // Generate QR data for invoice
  static String _generateInvoiceQRData({
    required String invoiceNumber,
    required String candidateName,
    required String dateRange,
    required String totalAmount,
  }) {
    return 'Invoice:$invoiceNumber|Candidate:$candidateName|Period:$dateRange|Amount:$totalAmount';
  }

  static Future<void> _printAssetImage(String assetPath, {int width = 120}) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      await _printer.printImage(bytes, align: SunmiPrintAlign.CENTER);
      await _printer.lineWrap(times: 1);
      debugPrint('Asset image printed successfully');
    } catch (e) {
      debugPrint('Asset image printing failed: $e');
    }
  }

  // Helper to format date
  static String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return date;
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    }
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return date.toString();
  }

  // Helper to format currency
  static String _formatCurrency(dynamic amount, {int decimals = 2}) {
    if (amount == null) return 'AED 0.00';
    final value = double.tryParse(amount.toString()) ?? 0.0;
    return 'AED ${value.toStringAsFixed(decimals)}';
  }

  // Print invoice details section
  static Future<void> _printInvoiceDetails(Map<String, dynamic> data) async {
    await _printer.printText(
      text: 'INVOICE DETAILS',
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 12, bold: true),
    );
    await _printer.printText(text: '--------------------------------');
    await _printer.lineWrap(times: 1);

    // Candidate info
    String candidateName = data['candidate']?['name'] ?? 'N/A';
    String candidateId = data['candidate']?['id']?.toString() ?? 'N/A';

    await _printer.printText(
      text: 'Candidate: $candidateName',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10, bold: true),
    );
    await _printer.printText(
      text: 'ID: $candidateId',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.lineWrap(times: 1);

    // Date range
    String startDate = _formatDate(data['startDate']);
    String endDate = _formatDate(data['endDate']);
    await _printer.printText(
      text: 'Period: $startDate - $endDate',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.lineWrap(times: 1);

    // Financial details
    await _printer.printText(
      text: 'Total Tickets: ${data['totalTickets'] ?? 0}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Sales Amount: ${_formatCurrency(data['totalSalesAmount'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Commission: ${_formatCurrency(data['commission'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Total Paid: ${_formatCurrency(data['totalPaidAmount'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Revenue: ${_formatCurrency(data['totalRevenue'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Company Paid: ${_formatCurrency(data['companyPaidAmount'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
    );
    await _printer.printText(
      text: 'Final Payment: ${_formatCurrency(data['companyPayment'])}',
      style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 11, bold: true),
    );
  }

  // Generate invoice summary widget for PDF
  static pw.Widget invoiceSummary(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        infoRow('Agent Name:', data['candidate']?['name'] ?? 'N/A'),
        // infoRow('Earning Period:', '${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}'),
        pw.Divider(thickness: 0.5),
        infoRow('Total Tickets:', '${data['totalTickets'] ?? 0}'),
        infoRow('Sales Amount:', _formatCurrency(data['totalSalesAmount'])),
        infoRow('Commission:', _formatCurrency(data['commission'])),
        infoRow('Total Paid:', _formatCurrency(data['totalPaidAmount'])),
        infoRow('Revenue:', _formatCurrency(data['totalRevenue'])),
        infoRow('Company Paid:', _formatCurrency(data['companyPaidAmount'])),
        infoRow('Company Payment:', _formatCurrency(data['companyPayment'])),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget infoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  static Future<bool> initialize({int retryCount = 0}) async {
    if (_isInitialized) {
      debugPrint('Printer already initialized');
      return true;
    }

    if (!await _isSunmiDevice()) {
      debugPrint('Non-Sunmi device detected, skipping printer status check');
      return false;
    }

    try {
      debugPrint('Checking printer status (Attempt ${retryCount + 1})...');
      final status = await _printer.getStatus();
      debugPrint('Printer status: $status');
      await Future.delayed(Duration(milliseconds: _statusDelayMs));

      if (status == PrinterStatus.READY) {
        await _printer.printText(text: 'Printer Ready', style: SunmiTextStyle());
        await _printer.lineWrap(times: 1);
        debugPrint('Test print successful');
        _isInitialized = true;
        debugPrint('Sunmi Printer is ready');
        return true;
      } else {
        debugPrint('Printer status is not READY: $status');
        if (retryCount < _maxRetries) {
          debugPrint('Retrying status check (Attempt ${retryCount + 2})...');
          await Future.delayed(Duration(milliseconds: _statusDelayMs));
          return await initialize(retryCount: retryCount + 1);
        }
        return false;
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('Printer status check failed: $e');
      if (retryCount < _maxRetries && e.toString().contains('lateinit')) {
        debugPrint('Retrying status check (Attempt ${retryCount + 2})...');
        await Future.delayed(Duration(milliseconds: _statusDelayMs));
        return await initialize(retryCount: retryCount + 1);
      }
      return false;
    }
  }

  static void reset() {
    _isInitialized = false;
    debugPrint('Printer state reset');
  }

  static bool get isReady => _isInitialized;

  static Future<bool> safePrint(Function printFunction, {required Function pdfFunction}) async {
    try {
      if (!await _isSunmiDevice()) {
        debugPrint('Non-Sunmi device, generating PDF instead...');
        await pdfFunction();
        return true;
      }

      if (!_isInitialized) {
        debugPrint('Printer not initialized, checking status...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('Status check failed, falling back to PDF...');
          await pdfFunction();
          return true;
        }
      }

      // ✅ FIXED: Always generate PDF first, then print
      debugPrint('Generating PDF on device...');
      await pdfFunction();

      debugPrint('Starting POS printing...');
      await printFunction();
      debugPrint('Print operation completed');
      return true;
    } catch (e) {
      debugPrint('Safe print failed: $e');
      if (e.toString().contains('lateinit')) {
        debugPrint('Retrying due to initialization error...');
        reset();
        final reinitialized = await initialize();
        if (reinitialized) {
          try {
            // ✅ FIXED: Generate PDF even on retry
            debugPrint('Generating PDF on device (retry)...');
            await pdfFunction();

            await printFunction();
            debugPrint('Retry print successful');
            return true;
          } catch (retryError) {
            debugPrint('Retry failed: $retryError, PDF already generated');
            return true; // PDF was already generated
          }
        } else {
          debugPrint('Retry status check failed, PDF already generated');
          return true; 
        }
      }
      debugPrint('Error occurred, but PDF should be generated');
      // Try to generate PDF if it wasn't generated yet
      try {
        await pdfFunction();
      } catch (pdfError) {
        debugPrint('PDF generation also failed: $pdfError');
      }
      return true; // Return true since we attempted PDF generation
    }
  }

  /// Throws on fatal errors so the caller can decide what to do.
  static Future<String> generateInvoicePdf({
    required Map<String, dynamic> invoiceData,
    String? companyAddress,
    String? assetImagePath, 
  }) async {
    // ── 1.  helpers 
    Future<pw.MemoryImage?> tryLoadLogo() async {
      try {
        final bd = await rootBundle.load('assets/images/logo.png');
        return pw.MemoryImage(bd.buffer.asUint8List());
      } catch (e, st) {
        debugPrint('[PDF] logo asset missing → $e\n$st');
        return null; 
      }
    }

    String fmtDate(dynamic d) => _formatDate(d); 
    String cur(dynamic a) => _formatCurrency(a); 

    // ── 2.  prepare data 
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    _generateInvoiceQRData(
      invoiceNumber: invoiceNumber,
      candidateName: invoiceData['candidate']?['name'] ?? '',
      dateRange:
          '${fmtDate(invoiceData['startDate'])}-'
          '${fmtDate(invoiceData['endDate'])}',
      totalAmount: cur(invoiceData['companyPayment']),
    );

    // ── 3.  build pdf ──────────────────────────────────────────────────────────
    final pdf = pw.Document();
    final logo = await tryLoadLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build:
            (_) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null) pw.Image(logo, height: 50),
                pw.SizedBox(height: 16),

                pw.Text('EARNINGS INVOICE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),

                // ── summary block ──
                pw.Align(alignment: pw.Alignment.centerLeft, child: invoiceSummary(invoiceData)),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Generated: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
      ),
    );

    // ── 4. save file ───────────────────────────────────────────────────────────
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    debugPrint('[PDF] saved: ${file.path}');
    return file.path; // let caller decide what to do with it
  }

  static Future<bool> printInvoice({
    required Map<String, dynamic> invoiceData,
    String? companyAddress,
    String? assetImagePath,
  }) async {
    return await safePrint(
      () async {
        debugPrint('Starting invoice print...');

        // Generate invoice number
        final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

        // Print logo
        try {
          await _printAssetImage('assets/images/logo.png', width: 120);
        } catch (e) {
          await _printer.printText(
            text: 'LOGO',
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 14, bold: true),
          );
          await _printer.lineWrap(times: 1);
        }

        // Print header
        await _printer.printText(
          text: 'EARNINGS INVOICE',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true, fontSize: 14),
        );
        await _printer.printText(text: '................................');
        await _printer.printText(
          text: 'Invoice #: $invoiceNumber',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true, fontSize: 12),
        );
        await _printer.printText(text: '................................');
        await _printer.lineWrap(times: 2);

        // Print invoice details
        await _printInvoiceDetails(invoiceData);
        await _printer.lineWrap(times: 2);

        // Print generation time
        await _printer.printText(
          text: 'Generated: ${DateTime.now().toString().split('.')[0]}',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 8),
        );
        await _printer.lineWrap(times: 2);

        // Print QR code
        try {
          final qrData = _generateInvoiceQRData(
            invoiceNumber: invoiceNumber,
            candidateName: invoiceData['candidate']?['name'] ?? '',
            dateRange: '${_formatDate(invoiceData['startDate'])}-${_formatDate(invoiceData['endDate'])}',
            totalAmount: _formatCurrency(invoiceData['companyPayment']),
          );

          await SunmiPrinter.printQRCode(
            qrData,
            style: SunmiQrcodeStyle(qrcodeSize: 6, errorLevel: SunmiQrcodeLevel.LEVEL_H),
          );
          await _printer.lineWrap(times: 1);
          await _printer.printText(
            text: invoiceNumber,
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10, bold: true),
          );
          await _printer.lineWrap(times: 2);
          debugPrint('QR code printed successfully');
        } catch (qrError) {
          debugPrint('QR code printing failed: $qrError');
        }

        // Print footer
        await _printer.printText(
          text: companyAddress ?? 'Company Address',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
        );
        await _printer.printText(
          text: 'Website: https://foryouwin.com/',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
        );
        await _printer.lineWrap(times: 3);
        await _printer.cutPaper();
        debugPrint('Invoice print completed');
      },
      pdfFunction: () async {
        final pdfPath = await generateInvoicePdf(
          invoiceData: invoiceData,
          companyAddress: companyAddress,
          assetImagePath: assetImagePath,
        );
        if (pdfPath.isNotEmpty) {
          debugPrint('PDF generated successfully at: $pdfPath');
        } else {
          debugPrint('PDF generation failed');
        }
      },
    );
  }

  static Future<bool> testPrint() async {
    // Test data
    Map<String, dynamic> testInvoiceData = {
      'candidate': {'name': 'John Doe', 'id': 12345},
      'startDate': '2025-01-01',
      'endDate': '2025-01-31',
      'totalTickets': 150,
      'totalSalesAmount': 3000.50,
      'commission': 300.05,
      'totalPaidAmount': 2700.45,
      'totalRevenue': 2400.40,
      'companyPaidAmount': 1800.30,
      'companyPayment': 1500.25,
    };

    return await safePrint(
      () async {
        debugPrint('Starting test invoice print...');
        await _printer.printText(
          text: '=== TEST INVOICE ===',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true, fontSize: 16),
        );
        await _printer.lineWrap(times: 1);
        await _printer.printText(
          text: 'Printer is working!',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 12),
        );
        await _printer.printText(text: '------------------------');

        // Print test invoice details
        await _printInvoiceDetails(testInvoiceData);

        // Test QR code
        try {
          final testQrData = _generateInvoiceQRData(
            invoiceNumber: 'TEST-INV-123',
            candidateName: 'John Doe',
            dateRange: '01/01/2025-31/01/2025',
            totalAmount: 'AED 1500.25',
          );
          await SunmiPrinter.printQRCode(
            testQrData,
            style: SunmiQrcodeStyle(qrcodeSize: 5, errorLevel: SunmiQrcodeLevel.LEVEL_H),
          );
          await SunmiPrinter.lineWrap(1);
          debugPrint('Test QR code printed');
        } catch (qrError) {
          debugPrint('Test QR code failed: $qrError');
        }

        await _printer.printText(text: '------------------------');
        await _printer.lineWrap(times: 2);
        await _printer.cutPaper();
        debugPrint('Test invoice print completed');
      },
      pdfFunction: () async {
        final pdf = pw.Document();

        final testQrData = _generateInvoiceQRData(
          invoiceNumber: 'TEST-INV-123',
          candidateName: 'John Doe',
          dateRange: '01/01/2025-31/01/2025',
          totalAmount: 'AED 1500.25',
        );

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.roll57,
            build:
                (pw.Context context) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('=== TEST INVOICE ===', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Printer is working!', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('------------------------'),
                    pw.SizedBox(height: 10),
                    invoiceSummary(testInvoiceData),
                    pw.SizedBox(height: 10),
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: testQrData, width: 60, height: 60),
                    pw.SizedBox(height: 10),
                    pw.Text('------------------------'),
                  ],
                ),
          ),
        );

        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/test_invoice.pdf');
        await file.writeAsBytes(await pdf.save());
        debugPrint('Test invoice PDF saved at: ${file.path}');
      },
    );
  }

  static Future<bool> checkPrinterAvailability() async {
    try {
      if (!await _isSunmiDevice()) {
        debugPrint('Non-Sunmi device, skipping availability check');
        return false;
      }

      if (!_isInitialized) {
        debugPrint('Checking printer status for availability...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('Printer status check failed during availability check');
          return false;
        }
      }

      debugPrint('Printer is available');
      return true;
    } catch (e) {
      debugPrint('Printer availability check failed: $e');
      return false;
    }
  }
}
