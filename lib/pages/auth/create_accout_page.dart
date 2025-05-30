import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/app_textfield.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/auth/auth_services.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Controllers!!
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  // Form key!!
  final formKey = GlobalKey<FormState>();
  final AuthServices authServices = AuthServices();

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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter name";
                        }
                        return null;
                      },
                    ),

                    // Email Field
                    AppTextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'abc@gmail.com',
                      label: 'Email Address',
                      suffixIcon: Icons.email_outlined,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter email";
                        }
                        return null;
                      },
                    ),

                    // Phone Field
                    AppTextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      hint: '0301*****77',
                      label: 'Phone',
                      suffixIcon: Icons.phone_in_talk_outlined,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter phone";
                        }
                        return null;
                      },
                    ),

                    // Password Field
                    AppTextField(
                      controller: addressController,
                      keyboardType: TextInputType.visiblePassword,
                      hint: 'Shop-Address',
                      label: 'Address',
                      suffixIcon: Icons.place,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter address";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 40.h),

                    // Create Account Button
                    Consumer<AuthServices>(
                      builder: (context, authServices, _) {
                        return PrimaryButton(
                          isLoading: authServices.isLoading,
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              authServices.createAccount(
                                nameController.text,
                                emailController.text,
                                phoneController.text,
                                addressController.text,
                              );
                            }
                          },
                          title: 'Create Account',
                        );
                      },
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
