import 'dart:async';

import 'package:flutter/material.dart';
import 'package:for_u_win/pages/splash/splash_page.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class RestrictedTimePage extends StatefulWidget {
  const RestrictedTimePage({super.key});

  @override
  State<RestrictedTimePage> createState() => _RestrictedTimePageState();
}

class _RestrictedTimePageState extends State<RestrictedTimePage> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final dubai = tz.getLocation('Asia/Dubai');
    final now = tz.TZDateTime.now(dubai);
    final end = tz.TZDateTime(dubai, now.year, now.month, now.day, 23, 15);

    final remaining = end.difference(now);
    if (remaining.isNegative) {
      _timer.cancel();
      Get.offAll(() => const SplashPage());
    } else {
      setState(() {
        _remainingTime = remaining;
      });
    }
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dubai = tz.getLocation('Asia/Dubai');
    final now = tz.TZDateTime.now(dubai);
    final formattedTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, color: Colors.white, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Ticket purchasing is restricted\nbetween 11:20 AM - 11:25 AM (Dubai Time)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Text(
                '⏳ Remaining: ${formatDuration(_remainingTime)}',
                style: const TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('🕒 Dubai Time: $formattedTime', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
