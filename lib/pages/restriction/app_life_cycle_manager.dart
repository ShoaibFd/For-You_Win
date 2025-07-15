import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:for_u_win/pages/restriction/restriction_page.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  Timer? _timer;

  factory AppLifecycleManager() {
    return _instance;
  }

  AppLifecycleManager._internal();

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _startTimeCheckTimer();
  }

  void _startTimeCheckTimer() {
    // Cancel any existing timer to avoid duplicates
    _timer?.cancel();
    // Check every 10 seconds if the app is in the restricted time window
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isRestrictedTime()) {
        if (Get.currentRoute != '/RestrictedTimePage') {
          Get.offAll(() => const RestrictedTimePage());
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart the timer when the app resumes
      _startTimeCheckTimer();
      // Check restricted time immediately on resume
      if (_isRestrictedTime()) {
        if (Get.currentRoute != '/RestrictedTimePage') {
          Get.offAll(() => const RestrictedTimePage());
        }
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Cancel the timer when the app is paused or detached
      _timer?.cancel();
    }
  }

  bool _isRestrictedTime() {
    final dubai = tz.getLocation('Asia/Dubai');
    final now = tz.TZDateTime.now(dubai);
    final start = tz.TZDateTime(dubai, now.year, now.month, now.day, 22, 45);
    final end = tz.TZDateTime(dubai, now.year, now.month, now.day, 23, 15);
    return now.isAfter(start) && now.isBefore(end);
  }

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
