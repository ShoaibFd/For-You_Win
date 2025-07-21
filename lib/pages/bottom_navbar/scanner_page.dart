import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/tickets/click_page.dart';
import 'package:for_u_win/pages/tickets/foryou_page.dart';
import 'package:for_u_win/pages/tickets/info_page.dart';
import 'package:for_u_win/pages/tickets/mega_page.dart';
import 'package:for_u_win/pages/tickets/royal_page.dart';
import 'package:for_u_win/pages/tickets/thrill_page.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  bool _isScanned = false;
  bool _isScannerReady = false;
  bool _hasPermission = false;
  MobileScannerController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      // Check camera permission status
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() {
          _hasPermission = true;
          _controller = MobileScannerController();
        });
        // Delay to ensure controller is ready
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            _isScannerReady = true;
          });
        }
      } else {
        // Request permission if not granted
        final newStatus = await Permission.camera.request();
        if (newStatus.isGranted) {
          setState(() {
            _hasPermission = true;
            _controller = MobileScannerController();
          });
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            setState(() {
              _isScannerReady = true;
            });
          }
        } else {
          setState(() {
            _hasPermission = false;
            _errorMessage = 'Camera permission is required to scan QR codes.';
          });
        }
      }
    } catch (e) {
      log("Error initializing scanner: $e");
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Failed to initialize scanner. Please try again.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _isScanned = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasPermission) {
      setState(() {
        _isScanned = false;
        _isScannerReady = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isScannerReady = true;
          });
        }
      });
    }
  }

  Future<void> _handleQRCode(String code) async {
    log("Scanned code: $code");

    if (_isScanned || !_isScannerReady || !_hasPermission) return;

    setState(() => _isScanned = true);

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: AppLoading()));

    try {
      String? productName;
      String? ticketId;
      String? orderDate;

      // Parse QR code in format: Order:11504|Product:Click-2|Date:11 Jun 2025
      if (code.contains('Product:')) {
        final parts = code.split('|');
        for (var part in parts) {
          if (part.startsWith('Product:')) {
            productName = part.split(':')[1].trim();
          } else if (part.startsWith('Order:')) {
            ticketId = part.split(':')[1].trim();
          } else if (part.startsWith('Date:')) {
            orderDate = part.split(':')[1].trim();
          }
        }
      }

      if (productName != null && productName.isNotEmpty) {
        Get.back(); // Close loading dialog

        await Get.to(
          () => _getPageBasedOnProductName(productName),
          arguments: {
            'ticket_id': ticketId ?? '',
            'has_winners': false,
            'product_name': productName,
            'order_date': orderDate ?? '',
          },
        );

        if (mounted) {
          setState(() {
            _isScanned = false;
            _isScannerReady = false;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _isScannerReady = true;
              });
            }
          });
        }
      } else {
        Get.back();
        AppSnackbar.showInfoSnackbar('Invalid QR code format.');
        _resetScanner();
      }
    } catch (e) {
      Get.back();
      log("Error handling QR code: $e");
      AppSnackbar.showErrorSnackbar('Something went wrong while processing the QR code.');
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanned = false;
      _isScannerReady = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _hasPermission) {
        setState(() {
          _isScannerReady = true;
        });
      }
    });
  }

  Widget _getPageBasedOnProductName(String? productName) {
    log("Getting page for product name: $productName");

    if (productName == null) {
      return const InfoPage();
    }

    switch (productName.toLowerCase()) {
      case 'click-2':
        return const ClickPage();
      case 'thrill-3':
        return const ThrillPage();
      case 'mega-4':
        return const MegaPage();
      case '4uwin-5':
        return const ForYouPage();
      case 'royal-6':
        return const RoyalPage();
      default:
        return const InfoPage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null || !_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage ?? 'Camera permission is required to scan QR codes.',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    setState(() {
                      _hasPermission = true;
                      _errorMessage = null;
                      _controller = MobileScannerController();
                    });
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (mounted) {
                      setState(() {
                        _isScannerReady = true;
                      });
                    }
                  } else {
                    openAppSettings();
                  }
                },
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isScannerReady || _controller == null) {
      return Scaffold(backgroundColor: Colors.black, body: const Center(child: AppLoading()));
    }

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: (capture) {
              if (!_isScanned && _isScannerReady) {
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
                _isScannerReady ? 'Position QR code within the frame' : 'Preparing scanner...',
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_isScannerReady && !_isScanned)
            Center(child: SizedBox(width: 250, height: 250, child: _ScanningAnimation())),
        ],
      ),
    );
  }
}

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
