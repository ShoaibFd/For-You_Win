// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/invoice/invoice_services.dart';
import 'package:for_u_win/pages/invoice/print_services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  String reportType = 'daily';
  DateTime? startDate;
  DateTime? endDate;
  bool showInvoice = false;
  bool isPrinting = false;
  Map<String, dynamic>? invoiceData;
  bool _isPageActive = true;

  final Map<String, String> reportTypeOptions = {'Daily': 'daily', 'Weekly': 'weekly'};

  // Animation controllers
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController printController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> printSlideAnimation;

  final GlobalKey invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isPageActive = true;
    _setDefaultDates();
    _initializeAnimations();

    // Clear data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearPageData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Additional safety check
    if (!_isPageActive) {
      _clearPageData();
    }
  }

  void _initializeAnimations() {
    slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    fadeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    printController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _isPageActive = false;
      _scheduleClearPageData();
    } else if (state == AppLifecycleState.resumed) {
      _isPageActive = true;
    }
  }

  // ✅ ENHANCED: Multiple clearing mechanisms
  @override
  void deactivate() {
    super.deactivate();
    _isPageActive = false;
    _scheduleClearPageData();
  }

  // ✅ NEW: Clear data when route is popped
  @override
  void didPopNext() {
    super.didPopNext();
    _clearPageData();
  }

  // ✅ NEW: Clear data when route is pushed away
  @override
  void didPushNext() {
    super.didPushNext();
    _isPageActive = false;
    _scheduleClearPageData();
  }

  void _scheduleClearPageData() {
    // Use addPostFrameCallback to ensure this runs after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearPageData();
    });
  }

  // ✅ ENHANCED: More thorough data clearing
  void _clearPageData() {
    if (!mounted) return;

    try {
      debugPrint('🧹 Clearing invoice page data...');

      // Clear invoice service data
      final invoice = Provider.of<InvoiceServices>(context, listen: false);
      invoice.clearEarningData();

      // Reset local state safely
      if (mounted) {
        setState(() {
          showInvoice = false;
          isPrinting = false;
          invoiceData = null;
          reportType = 'daily';
          _setDefaultDates();
        });
      }

      // Reset animations
      if (slideController.isAnimating) slideController.stop();
      if (fadeController.isAnimating) fadeController.stop();
      if (printController.isAnimating) printController.stop();

      slideController.reset();
      fadeController.reset();
      printController.reset();

      debugPrint('✅ Invoice page data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing invoice data: $e');
    }
  }

  // ✅ NEW: Force clear method for manual clearing
  void _forceClearData() {
    _clearPageData();
    if (mounted) {
      AppSnackbar.showInfoSnackbar('Data cleared');
    }
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    if (reportType == 'weekly') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate!.add(const Duration(days: 6));
    } else if (reportType == 'daily') {
      startDate = now;
      endDate = now;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return '';
      return '${parsed.day}/${parsed.month}/${parsed.year}';
    }
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  String _formatCurrency(dynamic amount, {int? number}) {
    if (amount == null) return 'AED 0.00';
    return 'AED ${double.tryParse(amount.toString())?.toStringAsFixed(number ?? 2) ?? '0.00'}';
  }

  void showInvoiceAnimation() {
    if (!mounted || !_isPageActive) return;
    setState(() {
      showInvoice = true;
    });
    slideController.forward();
    fadeController.forward();
  }

  void hideInvoice() {
    if (!mounted) return;
    setState(() {
      showInvoice = false;
      isPrinting = false;
    });
    slideController.reset();
    fadeController.reset();
    printController.reset();
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
      if (mounted) {
        AppSnackbar.showErrorSnackbar('Permission request failed: $e');
      }
    }
  }

  // Updated print handler
  Future<void> _handlePrint() async {
    if (isPrinting || !mounted || !_isPageActive) return;

    final localContext = context;
    final invoice = Provider.of<InvoiceServices>(localContext, listen: false);
    final data = invoice.earningData;

    if (data == null) {
      if (mounted) {
        AppSnackbar.showErrorSnackbar('No invoice data available');
      }
      return;
    }

    setState(() {
      invoiceData = data;
      isPrinting = true;
    });

    showInvoiceAnimation();

    try {
      log('Starting invoice processing with InvoicePrintService...');
      await _requestPermissions();

      if (mounted) {
        AppSnackbar.showSuccessSnackbar('🖨️ Processing invoice...');
      }

      // Prepare invoice data for InvoicePrintService
      final invoiceDataForPrint = {
        'candidate': {'name': data['candidate']?['name'] ?? 'Unknown User', 'id': data['candidate']?['id'] ?? 'N/A'},
        'startDate': startDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'endDate': endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'totalTickets': data['totalTickets'] ?? 0,
        'totalSalesAmount': double.tryParse(data['totalSalesAmount']?.toString() ?? '0') ?? 0.0,
        'commission': double.tryParse(data['commission']?.toString() ?? '0') ?? 0.0,
        'totalPaidAmount': double.tryParse(data['totalPaidAmount']?.toString() ?? '0') ?? 0.0,
        'totalRevenue': double.tryParse(data['totalRevenue']?.toString() ?? '0') ?? 0.0,
        'companyPaidAmount': double.tryParse(data['companyPaidAmount']?.toString() ?? '0') ?? 0.0,
        'companyPayment': double.tryParse(data['companyPayment']?.toString() ?? '0') ?? 0.0,
      };

      // Print or generate PDF
      final success = await InvoicePrintService.printInvoice(
        invoiceData: invoiceDataForPrint,
        companyAddress: 'For U Win Company\n123 Business Street\nDubai, UAE',
        assetImagePath: 'assets/images/logo.png',
      );

      if (success) {
        // Generate PDF separately for opening
        final pdfPath = await InvoicePrintService.generateInvoicePdf(
          invoiceData: invoiceDataForPrint,
          companyAddress: 'For U Win Company\n123 Business Street\nDubai, UAE',
          assetImagePath: 'assets/images/logo.png',
        );

        if (pdfPath.isNotEmpty && mounted) {
          AppSnackbar.showSuccessSnackbar('Invoice processed. PDF saved at: $pdfPath');
          await OpenFile.open(pdfPath);
        } else if (mounted) {
          AppSnackbar.showSuccessSnackbar('Invoice printed successfully!');
        }

        HapticFeedback.heavyImpact();
        printController.forward();

        // Auto-hide after successful processing
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _isPageActive) {
            hideInvoice();
          }
        });
      } else {
        throw Exception('Invoice processing failed');
      }
    } catch (e) {
      log('Print service error: $e');
      String errorMessage = 'Invoice processing failed';

      if (e.toString().contains('lateinit')) {
        errorMessage = 'Printer not initialized. Please use a Sunmi POS device or check connection.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'Printer not found. Check device compatibility.';
      } else if (e.toString().contains('paper')) {
        errorMessage = 'Printer out of paper. Please check paper roll.';
      }

      if (mounted) {
        AppSnackbar.showErrorSnackbar(errorMessage);
        printController.reset();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isPageActive) {
            hideInvoice();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isPrinting = false;
        });
      }
    }
  }

  // Test print for debugging
  Future<void> _handleTestPrint() async {
    final success = await InvoicePrintService.testPrint();
    if (mounted) {
      if (success) {
        AppSnackbar.showSuccessSnackbar('Test print successful or PDF generated!');
      } else {
        AppSnackbar.showErrorSnackbar('Test print failed');
      }
    }
  }

  // Check printer availability for debugging
  Future<void> _checkPrinterAvailability() async {
    final isAvailable = await InvoicePrintService.checkPrinterAvailability();
    if (mounted) {
      AppSnackbar.showInfoSnackbar('Printer ${isAvailable ? 'Available' : 'Not Available'}');
    }
  }

  // Check printer status for debugging
  Future<void> _checkPrinterStatus() async {
    final initialized = await InvoicePrintService.initialize();
    if (mounted) {
      AppSnackbar.showInfoSnackbar('Printer Status: ${initialized ? 'Ready' : 'Not Ready'}');
    }
  }

  // PDF generation method for backup/archival
  Future<Uint8List> generatePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    // Load logo
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(logoImage, height: 60, width: 120)),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Earnings Invoice Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                data['candidate']?['name'] != null ? "Report for ${data['candidate']['name']}" : "Report for User",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Date Range: ${(data['startDate'])} to ${(data['endDate'])}",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfRow('Total Tickets Sold:', '${data['totalTickets'] ?? 0}'),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Total Sales Amount:', _formatCurrency(data['totalSalesAmount'])),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Commission:', _formatCurrency(data['commission'])),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Total Paid Amount:', _formatCurrency(data['totalPaidAmount'])),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Total Revenue:', _formatCurrency(data['totalRevenue'])),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Company Paid Amount:', _formatCurrency(data['companyPaidAmount'])),
                  pw.SizedBox(height: 8),
                  _buildPdfRow('Company Payment:', _formatCurrency(data['companyPayment']), isBold: true),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Generated on: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 14, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
      ],
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing invoice page...');
    _isPageActive = false;

    // Clear data before disposing
    _clearPageData();

    WidgetsBinding.instance.removeObserver(this);

    // Stop and dispose animations
    slideController.stop();
    fadeController.stop();
    printController.stop();
    slideController.dispose();
    fadeController.dispose();
    printController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _clearPageData();
        return true;
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(title: AppText('Invoice', fontSize: 16.sp, fontWeight: FontWeight.w600)),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText("My Earnings", fontSize: 22.sp, fontWeight: FontWeight.bold),
                  SizedBox(height: 16.h),
                  AppText("Report Type", fontWeight: FontWeight.bold),
                  const Divider(thickness: 2),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          value: reportType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: primaryColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items:
                              reportTypeOptions.entries
                                  .map((entry) => DropdownMenuItem(value: entry.value, child: AppText(entry.key)))
                                  .toList(),
                          onChanged: (value) {
                            if (value != null && mounted) {
                              setState(() {
                                reportType = value;
                                _setDefaultDates();
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Consumer<InvoiceServices>(
                        builder: (context, invoice, child) {
                          return PrimaryButton(
                            isLoading: invoice.isLoading,
                            onTap: () async {
                              final success = await invoice.postEarning(
                                reportType,
                                startDate: startDate,
                                endDate: endDate,
                              );
                              if (success && mounted) {
                                setState(() {});
                              }
                            },
                            height: 50.h,
                            width: 100.h,
                            title: 'Check',
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  if (reportType == 'weekly')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("Date Range", fontWeight: FontWeight.bold),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: _dateBox(_formatDate(startDate), 'Start Date'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: _dateBox(_formatDate(endDate), 'End Date'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  Consumer<InvoiceServices>(
                    builder: (context, invoice, child) {
                      final data = invoice.earningData;
                      return data == null
                          ? const SizedBox.shrink()
                          : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: secondaryColor, width: 2.w),
                            ),
                            padding: EdgeInsets.all(8.r),
                            margin: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  "Report for ${data['candidate']?['name'] ?? 'User'}",
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 4.h),
                                AppText("Date Range: ${(data['startDate'])} to ${(data['endDate'])}", fontSize: 12.sp),
                                SizedBox(height: 10.h),
                                Table(
                                  border: TableBorder.all(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2)},
                                  children: [
                                    tableRow("Total Tickets Sold", "${data['totalTickets'] ?? 0}"),
                                    tableRow(
                                      "Total Sales Amount",
                                      _formatCurrency(data['totalSalesAmount'], number: 0),
                                    ),
                                    tableRow("Commission", _formatCurrency(data['commission'])),
                                    tableRow("Total Paid Amount", _formatCurrency(data['totalPaidAmount'])),
                                    tableRow("Total Revenue", _formatCurrency(data['totalRevenue'])),
                                    tableRow("Company Paid Amount", _formatCurrency(data['companyPaidAmount'])),
                                    tableRow("Company Payment", _formatCurrency(data['companyPayment'])),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: invoice.earningData != null && !isPrinting ? _handlePrint : null,
                                    child: Opacity(
                                      opacity: invoice.earningData != null && !isPrinting ? 1.0 : 0.5,
                                      child: Ink(
                                        height: 50.h,
                                        width: 120.w,
                                        decoration: BoxDecoration(
                                          color: isPrinting ? Colors.orange[400] : secondaryColor,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Center(
                                          child:
                                              isPrinting
                                                  ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 16.w,
                                                        height: 16.h,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      AppText(
                                                        'Processing...',
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  )
                                                  : AppText('Print Invoice', fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                    },
                  ),
                  // ✅ NEW: Debug section with clear button
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            if (showInvoice && invoiceData != null)
              GestureDetector(
                onTap: isPrinting ? null : hideInvoice,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
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
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
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
                                    color: isPrinting ? Colors.orange[300] : Colors.grey[300],
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
                                        isPrinting ? 'Processing...' : 'Invoice Report',
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isPrinting ? Colors.orange[600] : null,
                                      ),
                                      if (!isPrinting)
                                        GestureDetector(
                                          onTap: hideInvoice,
                                          child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                                        )
                                      else
                                        Icon(Icons.print, size: 24.sp, color: Colors.orange[600]),
                                    ],
                                  ),
                                ),
                                // Content
                                Expanded(
                                  child: RepaintBoundary(
                                    key: invoiceKey,
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 16.h),
                                          AppText(
                                            "Report for ${invoiceData!['candidate']?['name'] ?? 'User'}",
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(height: 8.h),
                                          AppText(
                                            "Date Range: ${_formatDate(invoiceData!['startDate'])} to ${_formatDate(invoiceData!['endDate'])}",
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
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
                                                _infoRow('Total Tickets Sold', '${invoiceData!['totalTickets'] ?? 0}'),
                                                Divider(),
                                                _infoRow(
                                                  'Total Sales Amount',
                                                  _formatCurrency(invoiceData!['totalSalesAmount']),
                                                ),
                                                Divider(),
                                                _infoRow('Commission', _formatCurrency(invoiceData!['commission'])),
                                                Divider(),
                                                _infoRow(
                                                  'Total Paid Amount',
                                                  _formatCurrency(invoiceData!['totalPaidAmount']),
                                                ),
                                                Divider(),
                                                _infoRow(
                                                  'Total Revenue',
                                                  _formatCurrency(invoiceData!['totalRevenue']),
                                                ),
                                                Divider(),
                                                _infoRow(
                                                  'Company Paid Amount',
                                                  _formatCurrency(invoiceData!['companyPaidAmount']),
                                                ),
                                                Divider(),
                                                _infoRow(
                                                  'Company Payment',
                                                  _formatCurrency(invoiceData!['companyPayment']),
                                                  isHighlighted: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          AppText(
                                            'Generated on: ${DateTime.now().toString().split('.')[0]}',
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(height: 24.h),
                                          if (isPrinting) ...[
                                            Container(
                                              padding: EdgeInsets.all(16.w),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius: BorderRadius.circular(12.r),
                                                border: Border.all(color: Colors.orange[200]!),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20.w,
                                                    height: 20.h,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.w),
                                                  AppText(
                                                    'Processing invoice...',
                                                    fontSize: 16.sp,
                                                    color: Colors.orange[600],
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
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String text, String placeholder) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16.sp),
          SizedBox(width: 8.w),
          AppText(text.isNotEmpty ? text : placeholder, fontSize: 14.sp),
        ],
      ),
    );
  }

  TableRow tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: AppText(label, fontWeight: FontWeight.bold)),
        Padding(padding: const EdgeInsets.all(8.0), child: AppText(value, textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, fontSize: 14.sp, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal),
          AppText(
            value,
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.green[800] : null,
          ),
        ],
      ),
    );
  }
}
