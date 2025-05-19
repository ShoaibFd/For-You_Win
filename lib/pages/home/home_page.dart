import 'package:flutter/material.dart';
import 'package:for_u_win/components/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Center(child: PrimaryButton(title: 'Login')));
  }
}
