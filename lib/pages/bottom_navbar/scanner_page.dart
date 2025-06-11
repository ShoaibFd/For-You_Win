// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/models/tickets/check_ticket_response.dart';
import 'package:for_u_win/data/services/tickets/ticket_services.dart';
import 'package:for_u_win/pages/tickets/click_page.dart';
import 'package:for_u_win/pages/tickets/foryou_page.dart';
import 'package:for_u_win/pages/tickets/info_page.dart';
import 'package:for_u_win/pages/tickets/mega_page.dart';
import 'package:for_u_win/pages/tickets/royal_page.dart';
import 'package:for_u_win/pages/tickets/thrill_page.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  Future<void> _handleQRCode(String code) async {
    log("Scanned code: $code");
    setState(() => _isScanned = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanned = false);
    });

    final ticketProvider = Provider.of<TicketServices>(context, listen: false);

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: AppLoading()));

    try {
      String? ticketId;

      if (code.startsWith("ticket:")) {
        ticketId = code.substring(7);
      } else if (code.contains('/check-ticket/')) {
        final uri = Uri.parse(code);
        final segments = uri.pathSegments;
        ticketId = segments.isNotEmpty ? segments.last : null;
      }

      if (ticketId != null && ticketId.isNotEmpty) {
        final response = await ticketProvider.checkTicket(ticketId);
        Get.back();

        if (response != null && response.status == "success") {
          Get.to(
            () => _getPageBasedOnProductName(response.data?.productName),
            arguments: {'ticketId': ticketId, 'ticketData': response.data},
          );
        } else {
          _navigateBasedOnProductName(ticketId, response);
        }
      } else {
        Get.back();
        AppSnackbar.showInfoSnackbar('Could not extract ticket ID from the QR code.');
      }
    } catch (e) {
      Get.back();
      log("Error handling QR code: $e");
      AppSnackbar.showErrorSnackbar('Something went wrong while processing the ticket.');
    }
  }

  void _navigateBasedOnProductName(String ticketId, CheckTicketResponse? response) {
    String? productName;
    String? message = response?.message;

    if (response != null) {
      if (response.status == "success") {
        productName = response.data?.productName;
        log("Success: Product name from data: $productName");
      } else if (response.status == "error") {
        productName = response.errors?.productName;
        log("Error: Product name from errors object: $productName");

        if (productName == null && message != null) {
          RegExp regex = RegExp(r'for ([A-Za-z0-9]+-\d+)');
          Match? match = regex.firstMatch(message);

          if (match != null) {
            productName = match.group(1);
            log("Extracted product name from error message: $productName");
          } else {
            log("Could not extract product name from error message: $message");

            // Try another regex pattern for different message formats
            RegExp altRegex = RegExp(r'([A-Za-z0-9]+-\d+)');
            Match? altMatch = altRegex.firstMatch(message);
            if (altMatch != null) {
              productName = altMatch.group(1);
              log("Extracted product name with alternative regex: $productName");
            }
          }
        }
      }
    }

    log("Final product name for navigation: $productName");
    Widget destinationPage = _getPageBasedOnProductName(productName);

    AppSnackbar.showInfoSnackbar(message ?? 'Winning numbers not announced for this ticket today.');

    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.to(
        () => destinationPage,
        arguments: {
          'ticket_id': ticketId,
          'tickets': response?.data,
          'has_winners': false,
          'product_name': productName,
        },
      );
    });
  }

  Widget _getPageBasedOnProductName(String? productName) {
    log("Getting page for product name: $productName");

    if (productName == null) {
      return InfoPage();
    }

    switch (productName.toLowerCase()) {
      case 'click-2':
        return ClickPage();
      case 'thrill-3':
        return ThrillPage();
      case 'mega-4':
        return MegaPage();
      case '4uwin-5':
        return ForYouPage();
      case 'royal-6':
        return RoyalPage();

      default:
        return InfoPage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.flash_on, color: Colors.white), onPressed: () => _controller.toggleTorch()),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (!_isScanned) {
                final code = capture.barcodes.first.rawValue;
                if (code != null) {
                  _handleQRCode(code);
                }
              }
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.transparent)),
                child: Stack(
                  children: [ClipPath(clipper: _ScannerOverlayClipper(), child: Container(color: Colors.transparent))],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Text(
                'Position QR code within the frame',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!_isScanned) Center(child: SizedBox(width: 250, height: 250, child: _ScanningAnimation())),
        ],
      ),
    );
  }
}

// Scan line animation
class _ScanningAnimation extends StatefulWidget {
  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 250).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(painter: _ScanLinePainter(_animation.value));
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double position;
  _ScanLinePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawLine(Offset(0, position), Offset(size.width, position), paint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter oldDelegate) => position != oldDelegate.position;
}

class _ScannerOverlayClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double scanAreaSize = 250;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, bottom), const Radius.circular(12)));
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
