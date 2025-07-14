// import 'package:flutter/material.dart';
// import 'package:for_u_win/components/app_snackbar.dart';
// import 'package:for_u_win/storage/shared_prefs.dart';
// import 'package:get/get.dart';
// import 'package:kiosk_mode/kiosk_mode.dart' as KioskMode show stopKioskMode;

// class ExitPasswordDialog extends StatefulWidget {
//   final VoidCallback onExitConfirmed;
//   final bool allowCancel;

//   const ExitPasswordDialog({super.key, required this.onExitConfirmed, this.allowCancel = true});

//   @override
//   State<ExitPasswordDialog> createState() => _ExitPasswordDialogState();
// }

// class _ExitPasswordDialogState extends State<ExitPasswordDialog> {
//   final TextEditingController _controller = TextEditingController();
//   final SharedPrefs _sharedPrefs = SharedPrefs();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _validatePassword() async {
//     setState(() {
//       _isLoading = true;
//     });

//     final enteredPassword = _controller.text.trim();
//     final storedPassword = await _sharedPrefs.getExitPassword();

//     if (enteredPassword == storedPassword) {
//       await _sharedPrefs.setUnlocked(true);
//       try {
//         await KioskMode.stopKioskMode();
//       } catch (e) {
//         debugPrint('Failed to disable kiosk mode: $e');
//       }
//       widget.onExitConfirmed();
//     } else {
//       AppSnackbar.showErrorSnackbar('Incorrect password. Please try again.');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Enter Password to Exit'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _controller,
//             obscureText: true,
//             decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
//             onSubmitted: (_) => _validatePassword(),
//           ),
//           if (_isLoading) const SizedBox(height: 10, child: LinearProgressIndicator()),
//         ],
//       ),
//       actions: [
//         if (widget.allowCancel) TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//         ElevatedButton(onPressed: _isLoading ? null : _validatePassword, child: const Text('Submit')),
//       ],
//     );
//   }
// }
