import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/app_textfield.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/auth/auth_services.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:get/get.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final phoneController = TextEditingController();

  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final AuthServices authServices = AuthServices();

  // Create Account Function
  void createAccount() {
    if (formKey.currentState!.validate()) {
      authServices.createAccount(
        nameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
      );
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
                    SizedBox(height: 50.h),
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 80.h),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: AppText('Shopping & Winning App', fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    AppText('Create Your Free Account', fontSize: 16.sp, fontWeight: FontWeight.bold),
                    SizedBox(height: 40.h),

                    // Name Field
                    AppTextField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      hint: 'Full Name',
                      label: 'Full Name',
                      suffixIcon: Icons.person_2_rounded,
                    ),

                    // Email Field
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'abc@gmail.com',
                      label: 'Email Address',
                      suffixIcon: Icons.email_outlined,
                    ),

                    // Phone Field
                    AppTextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      hint: '0301*****77',
                      label: 'Phone',
                      suffixIcon: Icons.phone_in_talk_outlined,
                    ),

                    // Password Field
                    AppTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      hint: '######',
                      label: 'Password',
                      suffixIcon: Icons.lock,
                    ),

                    SizedBox(height: 40.h),

                    // Create Account Button
                    PrimaryButton(
                      isLoading: authServices.isLoading,
                      onTap: () {
                        Get.to(() => BottomNavigationBarPage());
                      },
                      title: 'Create Account',
                    ),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText('Already have an account?'),
                        TextButton(
                          onPressed: () => Get.to(() => LoginPage()),
                          child: AppText('Login', color: errorColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
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
