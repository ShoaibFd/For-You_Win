import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isKioskModeEnabled = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Static credentials
  final String correctUsername = 'foryouwin@gmail.com';
  final String correctPassword = '55555';

  void _toggleKioskMode(bool newValue) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: AppText('Authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                minimumSize: Size(110.w, 44.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(110.w, 44.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              onPressed: () async {
                if (_usernameController.text == correctUsername && _passwordController.text == correctPassword) {
                  bool? val;
                  if (newValue == true) {
                    val = await enableKioskMode();
                  } else {
                    val = await disableKioskMode();
                  }

                  if (val == true) {
                    AppSnackbar.showSuccessSnackbar('kiosk mode stop successfully');
                    Navigator.pop(context, true);
                  } else {
                    AppSnackbar.showErrorSnackbar('Failed to stop kiosk mode');
                  }
                } else {
                  AppSnackbar.showErrorSnackbar('Invalid credentials');
                }
              },
              child: Text('Continue', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        isKioskModeEnabled = newValue;
      });

      // Yahan aap apna kiosk mode activate/deactivate logic call kar sakte ho
      if (isKioskModeEnabled) {
        debugPrint('Kiosk Mode ENABLED');
      } else {
        debugPrint('Kiosk Mode DISABLED');
      }
    }
  }

  Future<bool> disableKioskMode() async {
    try {
      MethodChannel methodChannel = MethodChannel('com.mews.kiosk_mode/kiosk_mode');
      await methodChannel.invokeMethod('stopKioskMode');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to Stop Kiosk Mode:::$e');
      }
    }

    return false;
  }

  Future<bool> enableKioskMode() async {
    try {
      MethodChannel methodChannel = MethodChannel('com.mews.kiosk_mode/kiosk_mode');
      await methodChannel.invokeMethod('startKioskMode');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to Stop Kiosk Mode:::$e');
      }
    }

    return false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiosk Mode Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kiosk Mode', style: TextStyle(fontSize: 18)),
            Switch(activeColor: secondaryColor, value: isKioskModeEnabled, onChanged: _toggleKioskMode),
          ],
        ),
      ),
    );
  }
}
