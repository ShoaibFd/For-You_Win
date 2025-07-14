import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class RestrictedTimePage extends StatefulWidget {
  final Widget child;
  const RestrictedTimePage({super.key, required this.child});

  @override
  State<RestrictedTimePage> createState() => _RestrictedTimePageState();
}

class _RestrictedTimePageState extends State<RestrictedTimePage> {
  late tz.TZDateTime _nowDubai;
  late Duration _remainingTime;
  bool _isRestricted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkRestriction();

    // Update every second to show live remaining countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkRestriction();
    });
  }

  void _checkRestriction() {
    final dubai = tz.getLocation('Asia/Dubai');
    _nowDubai = tz.TZDateTime.now(dubai);

    final start = tz.TZDateTime(dubai, _nowDubai.year, _nowDubai.month, _nowDubai.day, 22, 45);
    final end = tz.TZDateTime(dubai, _nowDubai.year, _nowDubai.month, _nowDubai.day, 23, 15);

    final wasRestricted = _isRestricted;

    if (_nowDubai.isAfter(start) && _nowDubai.isBefore(end)) {
      _isRestricted = true;
      _remainingTime = end.difference(_nowDubai);

      // Navigate to restriction screen if not already showing it
      if (wasRestricted == false && Get.currentRoute != '/RestrictedTimePage') {
        Get.offAll(() => const RestrictedTimePage(child: SizedBox()));
      }
    } else {
      _isRestricted = false;
      _remainingTime = Duration.zero;

      // Navigate back to child widget if restriction is lifted
      if (wasRestricted == true && Get.currentRoute == '/RestrictedTimePage') {
        Get.offAll(() => widget.child);
      }
    }

    setState(() {}); // Always update to refresh countdown
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDubaiTime = DateFormat('hh:mm a').format(_nowDubai);

    if (_isRestricted) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock, color: Colors.white, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Ticket purchasing is restricted\nbetween 1:46 PM and 1:50 PM (Dubai Time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 30),
                Text(
                  '⏳ Remaining: ${_formatDuration(_remainingTime)}',
                  style: const TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('🕒 Dubai Time: $formattedDubaiTime', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
