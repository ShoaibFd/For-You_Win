import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/app_textfield.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/auth/auth_services.dart';
import 'package:for_u_win/pages/auth/create_accout_page.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final AuthServices authServices = AuthServices();
  // Create Account Function
  void login() {
    if (formKey.currentState!.validate()) {
      authServices.login(emailController.text, passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/auth_bg.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80.h),
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 80.h),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: AppText('Shopping & Winning App', fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    AppText('Login to Your Account', fontSize: 16.sp, fontWeight: FontWeight.bold),
                    SizedBox(height: 40.h),
                    // Email Field
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'abc@gmail.com',
                      label: 'Email Address or Mobile Number',
                      suffixIcon: Icons.email_outlined,
                    ),

                    // Password Field
                    AppTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      hint: '######',
                      label: 'Enter Password',
                      suffixIcon: Icons.lock,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {},
                        child: AppText("Forgot Password?", color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 70.h),

                    // Create Account Button
                    PrimaryButton(
                      isLoading: authServices.isLoading,
                      onTap: () {
                        Get.to(() => BottomNavigationBarPage());
                      },
                      title: 'Login',
                    ),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText('Need a 4uwin account?'),
                        TextButton(
                          onPressed: () => Get.to(() => CreateAccountPage()),
                          child: AppText(
                            'Create Account',
                            color: errorColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 200.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
