// ignore_for_file: deprecated_member_use
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/tickets/ticket_services.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/pages/products/invoice_page/components/info_row.dart';
import 'package:for_u_win/pages/tickets/services/lottery_print_service.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MegaPage extends StatefulWidget {
  const MegaPage({super.key});

  @override
  State<MegaPage> createState() => _MegaPageState();
}

class _MegaPageState extends State<MegaPage> with TickerProviderStateMixin {
  // Controllers
  final searchController = TextEditingController();
  late AnimationController slideController;
  late AnimationController printController;
  late Animation<Offset> slideAnimation;
  late Animation<Offset> printAnimation;

  // State variables
  bool isVisible = false;
  bool isPrinting = false;
  bool isNavigating = false;
  bool showInvoice = false;
  bool hasAutoSearched = false;
  bool isPaymentProcessing = false;

  // Data variables
  Map<String, dynamic>? invoiceData;
  Set<String> paidOrderNumbers = {}; // ✅ Changed to track order numbers instead of individual ticket IDs

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _clearMegaData(); // Clear data on init for fresh state
    _setupPostFrameCallback();
  }

  void _initializeAnimations() {
    slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    printController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic));

    printAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: printController, curve: Curves.easeInOut));

    printController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isNavigating) {
        _performNavigation();
      }
    });
  }

  void _setupPostFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleQRCodeArguments();
    });
  }

  /// Clear all page data and reset TicketServices
  void _clearMegaData() {
    if (mounted) {
      setState(() {
        isVisible = false;
        isPrinting = false;
        isNavigating = false;
        showInvoice = false;
        hasAutoSearched = false;
        isPaymentProcessing = false;
        invoiceData = null;
        paidOrderNumbers.clear(); // ✅ Clear paid order numbers
        searchController.clear();
      });
    }

    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ticket = Provider.of<TicketServices>(context, listen: false);
        ticket.clearData(); // Clear all ticket data for all screens
        log('🧹 Cleared MegaPage data and all TicketServices data');
      }
    });
  }

  /// Handle QR code arguments and perform auto search
  void _handleQRCodeArguments() {
    try {
      final arguments = Get.arguments;
      if (arguments != null && arguments is Map<String, dynamic> && !hasAutoSearched) {
        final ticketId = arguments['ticket_id']?.toString();
        if (ticketId != null && ticketId.isNotEmpty) {
          log('🔍 Auto-searching for ticket ID from QR: $ticketId');
          searchController.text = ticketId;
          _performSearch(ticketId);
          hasAutoSearched = true;
        }
      }
    } catch (e) {
      log('❌ Error handling QR code arguments: $e');
      AppSnackbar.showErrorSnackbar('Error processing QR code');
    }
  }

  /// Perform search with validation
  void _performSearch(String orderNumber) {
    if (orderNumber.trim().isEmpty) {
      AppSnackbar.showErrorSnackbar('Please enter an order number');
      return;
    }

    try {
      final ticket = Provider.of<TicketServices>(context, listen: false);
      ticket.megaTicketSearch(orderNumber.trim());
      log('🔍 Searching for Mega-4 order number: $orderNumber');
      
      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            paidOrderNumbers.clear(); // ✅ Clear paid order numbers on new search
          });
        }
      });
    } catch (e) {
      log('❌ Search error: $e');
      AppSnackbar.showErrorSnackbar('Search failed. Please try again.');
    }
  }

  /// Handle search button tap
  void _onSearchButtonTap() {
    final order = searchController.text.trim();
    if (order.isNotEmpty) {
      _performSearch(order);
      searchController.clear();
    } else {
      AppSnackbar.showErrorSnackbar('Please enter an order number');
    }
  }

  /// Show invoice animation
  void showInvoiceAnimation() {
    if (mounted) {
      setState(() {
        isVisible = true;
        showInvoice = true;
      });
      slideController.forward();
    }
  }

  /// Hide invoice
  void hideInvoice() {
    if (mounted) {
      setState(() {
        showInvoice = false;
        isVisible = false;
      });
      slideController.reset();
      printController.reset();
    }
  }

  /// Request permissions
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
          final result = await permission.request();
          if (result.isPermanentlyDenied) {
            AppSnackbar.showErrorSnackbar('Permission denied. Please enable in settings.');
            return;
          }
        }
      }
      debugPrint('🖨️ Permissions granted');
    } catch (e) {
      debugPrint('❌ Permission request failed: $e');
      AppSnackbar.showErrorSnackbar('Permission request failed: $e');
    }
  }

  // ✅ NEW: Calculate total matched price for all winning tickets
  double _calculateTotalMatchedPrice(List<Map<String, dynamic>> winningTickets) {
    double total = 0.0;
    for (var ticket in winningTickets) {
      final matchedPrice = double.tryParse(ticket['matched_price']?.toString() ?? '0') ?? 0.0;
      total += matchedPrice;
    }
    return total;
  }

  // ✅ NEW: Handle payment for all winning tickets at once
  Future<void> handleBulkPayment(TicketServices ticket, List<Map<String, dynamic>> winningTickets) async {
    if (isPaymentProcessing || winningTickets.isEmpty) return;

    final orderNumber = ticket.megaTicketData?['order_number']?.toString();
    if (orderNumber == null) {
      log('❌ Order number is null');
      AppSnackbar.showErrorSnackbar('Order number is missing');
      return;
    }

    if (mounted) {
      setState(() => isPaymentProcessing = true);
    }

    try {
      // Calculate total amount
      final totalAmount = _calculateTotalMatchedPrice(winningTickets);
      
      // Pay for each ticket individually (if your API requires individual payments)
      for (var matchedTicket in winningTickets) {
        final rawTicketId = matchedTicket['id'];
        if (rawTicketId == null) continue;

        final ticketId = int.tryParse(rawTicketId.toString());
        if (ticketId == null) continue;

        await ticket.payTicket(ticketId, matchedTicket['matched_price'].toString());
        log('✅ Payment successful for ticket ID: $ticketId');
        
        // Update ticket status
        matchedTicket['order_status'] = 1;
      }

      // Create consolidated invoice data
      invoiceData = {
        'tickets': winningTickets,
        'orderNumber': orderNumber,
        'status': 'Paid',
        'totalAmount': totalAmount,
        'hasWinners': ticket.megaTicketData?['hasWinners'],
        'ticketCount': winningTickets.length,
      };

      showInvoiceAnimation();
      await _handleBulkPrintWithLotteryService(winningTickets, totalAmount, orderNumber);

      if (mounted) {
        setState(() {
          paidOrderNumbers.add(orderNumber); // ✅ Mark this order as paid
        });
      }

    } catch (e) {
      log('❌ Bulk payment failed: $e');
      AppSnackbar.showErrorSnackbar('Payment failed: $e');
    } finally {
      if (mounted) {
        setState(() => isPaymentProcessing = false);
      }
    }
  }

  // ✅ NEW: Handle bulk print with lottery service
  Future<void> _handleBulkPrintWithLotteryService(
    List<Map<String, dynamic>> winningTickets, 
    double totalAmount, 
    String orderNumber
  ) async {
    if (isPrinting) return;

    if (mounted) {
      setState(() => isPrinting = true);
    }

    try {
      await _requestPermissions();
      AppSnackbar.showSuccessSnackbar('Processing consolidated receipt...');

      // Get candidate name from first ticket (assuming same purchaser)
      String candidateName = _extractCandidateName(winningTickets.first);

      final success = await LotteryPrintService.printLotteryInvoice(
        orderNumber: orderNumber,
        purchasedBy: candidateName,
        amount: 'AED ${totalAmount.toStringAsFixed(2)}',
        drawDate: winningTickets.first['draw_date'].toString().split(' ')[0],
        additionalInfo: 'Total Winning Tickets: ${winningTickets.length}',
        ticketCount: winningTickets.length,
        individualTickets: winningTickets,
      );

      if (success) {
        final pdfPath = await LotteryPrintService.generateLotteryPdfInvoice(
          orderNumber: orderNumber,
          purchasedBy: candidateName,
          amount: 'AED ${totalAmount.toStringAsFixed(2)}',
          drawDate: winningTickets.first['draw_date'].toString().split(' ')[0],
          additionalInfo: 'Total Winning Tickets: ${winningTickets.length}',
          ticketCount: winningTickets.length,
          individualTickets: winningTickets,
        );

        if (pdfPath.isNotEmpty) {
          AppSnackbar.showSuccessSnackbar('Consolidated receipt processed. PDF saved at: $pdfPath');
          await OpenFile.open(pdfPath);
        } else {
          AppSnackbar.showSuccessSnackbar('Consolidated receipt printed successfully!');
        }

        HapticFeedback.heavyImpact();
        printController.forward();
      } else {
        throw Exception('Receipt processing failed');
      }
    } catch (e) {
      log('❌ Print service error: $e');
      AppSnackbar.showErrorSnackbar(_getErrorMessage(e.toString()));
      printController.reset();
      await Future.delayed(const Duration(seconds: 2));
      _navigateBack();
    } finally {
      if (mounted) {
        setState(() => isPrinting = false);
      }
    }
  }

  /// Get appropriate error message
  String _getErrorMessage(String error) {
    if (error.contains('lateinit')) return 'Printer not initialized. Please use a Sunmi POS device.';
    if (error.contains('not found')) return 'Printer not found. Check device compatibility.';
    if (error.contains('paper')) return 'Printer out of paper. Please check paper roll.';
    return 'Receipt processing failed. Please try again.';
  }

  /// Perform navigation after animation
  void _performNavigation() {
    if (isNavigating) return;
    isNavigating = true;
    if (mounted) {
      Get.offAll(() => BottomNavigationBarPage(), transition: Transition.noTransition, duration: Duration.zero);
    }
  }

  /// Navigate back
  void _navigateBack() {
    if (isNavigating) return;
    isNavigating = true;
    if (mounted) {
      Get.offAll(
        () => BottomNavigationBarPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  /// Find all winning tickets from response
  List<Map<String, dynamic>> _findWinningTickets(TicketServices ticket) {
    if (ticket.megaTicketData == null || ticket.megaTicketData!['validTickets'] == null) return [];

    final validTickets = ticket.megaTicketData!['validTickets'] as List<dynamic>;
    final winningTickets = <Map<String, dynamic>>[];

    for (var ticketData in validTickets) {
      final matchedPrice = double.tryParse(ticketData['matched_price']?.toString() ?? '0') ?? 0.0;
      if (matchedPrice > 0) {
        log('✅ Found winning ticket with ID: ${ticketData['id']}, matched_price: $matchedPrice');
        winningTickets.add(ticketData);
      }
    }

    if (winningTickets.isEmpty) {
      log('❌ No tickets with matched_price > 0 found');
    }

    return winningTickets;
  }

  /// Extract candidate name safely
  String _extractCandidateName(Map<String, dynamic> ticket) {
    final candidate = ticket['candidate'];
    if (candidate == null) return 'Unknown';
    return candidate is Map ? candidate['name']?.toString() ?? 'Unknown' : candidate.toString();
  }

  // ✅ NEW: Check if order is already paid
  bool _isOrderPaid(TicketServices ticket, List<Map<String, dynamic>> winningTickets) {
    final orderNumber = ticket.megaTicketData?['order_number']?.toString();
    if (orderNumber == null) return false;

    // Check if order is marked as paid
    if (paidOrderNumbers.contains(orderNumber)) return true;

    // Check if all tickets in this order are already paid
    return winningTickets.every((ticket) => ticket['order_status'] == 1);
  }

  @override
  void dispose() {
    _clearMegaData(); // Clear data when leaving
    slideController.dispose();
    printController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _clearMegaData(); // Clear data on back navigation
        return true;
      },
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(title: AppText('Mega-4', fontSize: 16.sp, fontWeight: FontWeight.bold)),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Consumer<TicketServices>(
                builder: (context, ticket, child) {
                  final winningTickets = _findWinningTickets(ticket);
                  final totalMatchedPrice = _calculateTotalMatchedPrice(winningTickets); // ✅ Calculate total
                  final isOrderPaid = _isOrderPaid(ticket, winningTickets); // ✅ Check if order is paid

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Center(child: AppText('Mega-4 Ticket Search', fontSize: 20.sp)),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 55.h,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: searchController,
                          cursorColor: secondaryColor,
                          onFieldSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _performSearch(value.trim());
                              searchController.clear();
                            }
                          },
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: _onSearchButtonTap,
                              child: Container(
                                width: 80.w,
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(child: AppText('Search', fontWeight: FontWeight.bold)),
                              ),
                            ),
                            filled: true,
                            fillColor: primaryColor,
                            hintText: 'Enter Order Number',
                            hintStyle: TextStyle(fontSize: 11.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      if (ticket.isLoading) Center(child: AppLoading()),
                      if (winningTickets.isNotEmpty && !ticket.isLoading)
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: winningTickets.length,
                                  itemBuilder: (context, index) {
                                    final currentWinningTicket = winningTickets[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: index == 0 ? 0 : 24.h),
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.r),
                                            border: Border.all(color: Colors.green[300]!, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              AppText(
                                                'Winning Ticket Details',
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800],
                                              ),
                                              SizedBox(height: 16.h),
                                              _buildDetailRow(
                                                'Order Number:',
                                                ticket.megaTicketData!['order_number'].toString(),
                                              ),
                                              _buildDetailRow(
                                                'Order Date:',
                                                currentWinningTicket['order_date'].toString().split(' ')[0],
                                              ),
                                              _buildDetailRow('Agent Name:', _extractCandidateName(currentWinningTicket)),
                                              _buildDetailRow(
                                                'Total Amount:',
                                                'AED ${currentWinningTicket['matched_price']}',
                                                isHighlighted: true,
                                              ),
                                              _buildDetailRow(
                                                'Draw Date:',
                                                currentWinningTicket['draw_date'].toString().split(' ')[0],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 24.h),
                              
                              // ✅ NEW: Single payment button for all tickets with total amount
                              if (isOrderPaid)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                                      SizedBox(width: 12.w),
                                      AppText(
                                        'All Payments Completed',
                                        fontSize: 16.sp,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                PrimaryButton(
                                  isLoading: isPaymentProcessing,
                                  onTap: () async => await handleBulkPayment(ticket, winningTickets),
                                  title: winningTickets.length > 1 
                                    ? 'Pay All (${winningTickets.length} tickets) - AED ${totalMatchedPrice.toStringAsFixed(2)}'
                                    : 'Pay Now - AED ${totalMatchedPrice.toStringAsFixed(2)}',
                                ),
                              
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      if (ticket.megaTicketData != null && winningTickets.isEmpty && !ticket.isLoading)
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 50.sp, color: Colors.grey[400]),
                                SizedBox(height: 16.h),
                                AppText(
                                  'No Winning Tickets Found',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 8.h),
                                AppText(
                                  'This order does not contain any winning tickets.',
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (showInvoice && invoiceData != null)
              GestureDetector(
                onTap: isPrinting ? null : hideInvoice,
                child: Stack(
                  children: [
                    if (isPrinting) BottomNavigationBarPage(),
                    SlideTransition(
                      position: printAnimation,
                      child: SlideTransition(
                        position: slideAnimation,
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
                                Container(
                                  margin: EdgeInsets.only(top: 12.h),
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(20.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText('Payment Receipt', fontSize: 20.sp, fontWeight: FontWeight.bold),
                                      GestureDetector(
                                        onTap: isPrinting ? null : hideInvoice,
                                        child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
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
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: AppText(
                                            '🎉 Mega-4 Winner${invoiceData!['ticketCount'] > 1 ? 's' : ''}! 🎉',
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            textAlign: TextAlign.center,
                                            color: Colors.green[800],
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
                                              infoRow('Order Number:', invoiceData!['orderNumber'].toString()),
                                              Divider(),
                                              infoRow('Purchased By:', _extractCandidateName(invoiceData!['tickets'][0])),
                                              Divider(),
                                              infoRow('Winning Tickets:', '${invoiceData!['ticketCount']}'),
                                              Divider(),
                                              infoRow(
                                                'Total Amount:',
                                                'AED ${invoiceData!['totalAmount'].toStringAsFixed(2)}',
                                                isHighlighted: true,
                                              ),
                                              Divider(),
                                              infoRow(
                                                'Draw Date:',
                                                invoiceData!['tickets'][0]['draw_date'].toString().split(' ')[0],
                                              ),
                                              Divider(),
                                              infoRow('Payment Date:', DateTime.now().toString().split(' ')[0]),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: AppText(
                                            "🎉 Congratulations! You have ${invoiceData!['ticketCount']} winning ticket${invoiceData!['ticketCount'] > 1 ? 's' : ''}! Keep playing for more chances to win! 🎉",
                                            fontSize: 14.sp,
                                            color: Colors.orange[800],
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        AppText(
                                          'Website: https://foryouwin.com/user/login',
                                          fontSize: 12.sp,
                                          color: Colors.blue,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 24.h),
                                        if (isPrinting)
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
                                                  'Printing receipt...',
                                                  fontSize: 16.sp,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String title, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(title, fontSize: 14.sp, fontWeight: FontWeight.w500),
          AppText(
            value,
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.green[700] : Colors.black,
          ),
        ],
      ),
    );
  }
}
