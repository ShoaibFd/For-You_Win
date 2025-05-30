// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../tickets/tickets_search_page.dart';


class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  // Handle different QR code types
  void _handleQRCode(String code) {
    log("Scanned code: $code");

    // Reset scanning state after a delay to allow for new scans
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanned = false;
        });
      }
    });

    if (code.startsWith("ticket:")) {
      // QR code for tickets
      final ticketId = code.substring(7); // Remove "ticket:" prefix
      Get.to(() => TicketsSearchPage(), arguments: {'ticketId': ticketId});
    } else if (code.startsWith("http://") || code.startsWith("https://")) {
      // Handle URL QR codes
      // You could launch the URL or navigate to a web view
      Get.snackbar(
        'URL Detected',
        'Scanned URL: $code',
        backgroundColor: Colors.green,
        colorText: whiteColor,
        duration: const Duration(seconds: 3),
      );

      // Uncomment if you have a WebViewPage
      // Get.to(() => WebViewPage(), arguments: {'url': code});
    } else {
      // Default case - unrecognized format
      Get.snackbar(
        'QR Code Scanned',
        'Unknown format: $code',
        backgroundColor: primaryColor,
        colorText: whiteColor,
        duration: const Duration(seconds: 3),
      );

      // You could still navigate to a default page
      Get.to(() => TicketsSearchPage(), arguments: {'rawData': code});
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
        title:  AppText('QR Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                if (state != true) {
                  return const Icon(Icons.flash_off, color: Colors.grey);
                }
                return ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, enabled, child) {
                    return Icon(Icons.flash_on, color: secondaryColor);
                  },
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
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
            onDetect: (BarcodeCapture capture) {
              if (!_isScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  setState(() {
                    _isScanned = true;
                  });

                  if (code != null) {
                    _handleQRCode(code);
                  }
                }
              }
            },
          ),
          // Scanner overlay with gradient effect
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.transparent)),
                child: Stack(
                  children: [
                    // This creates the cutout effect
                    ClipPath(clipper: _ScannerOverlayClipper(), child: Container(color: Colors.transparent)),
                  ],
                ),
              ),
            ),
          ),
          // Scan area indicator
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
          // Scanning text
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
          // Scanning animation
          if (!_isScanned) Center(child: SizedBox(width: 250, height: 250, child: _ScanningAnimation())),
        ],
      ),
    );
  }
}

// A simple scanning animation
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

// Clipper for creating scan area cutout
class _ScannerOverlayClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Create a cutout rectangle in the middle
    const double scanAreaSize = 250;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Draw outer rectangle
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw inner rectangle (cutout)
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(left, top, right, bottom), const Radius.circular(12)));

    // Use even-odd fill type to create cutout effect
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
