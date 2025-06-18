// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/app_textfield.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/auth/auth_services.dart';
import 'package:for_u_win/pages/auth/create_accout_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Controllers for manual entry in bottom sheet
  final manualEmailController = TextEditingController();
  final manualPasswordController = TextEditingController();
  final manualFormKey = GlobalKey<FormState>();

  final AuthServices authServices = AuthServices();

  // Track if there are saved emails
  bool hasSavedEmails = false;
  List<String> savedEmails = [];

  @override
  void initState() {
    super.initState();
    _checkSavedEmails();
  }

  @override
  void dispose() {
    manualEmailController.dispose();
    manualPasswordController.dispose();
    super.dispose();
  }

  // Check if there are saved emails
  Future<void> _checkSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final emails = prefs.getStringList('login_emails') ?? [];
    setState(() {
      savedEmails = emails;
      hasSavedEmails = emails.isNotEmpty;
    });
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
                          child: AppText(
                            'Buy our tickets & get free referral tickets',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    AppText('Login to Your Account', fontSize: 16.sp, fontWeight: FontWeight.bold),
                    SizedBox(height: 40.h),

                    // Email Field - Show bottom sheet only if there are saved emails
                    hasSavedEmails
                        ? GestureDetector(
                          onTap: () => _showEmailBottomSheet(),
                          child: AbsorbPointer(
                            child: AppTextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              hint: 'abc@gmail.com',
                              label: 'Email Address or Mobile Number',
                              suffixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please enter email";
                                }
                                return null;
                              },
                            ),
                          ),
                        )
                        : AppTextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'abc@gmail.com',
                          label: 'Email Address or Mobile Number',
                          suffixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter email";
                            }
                            return null;
                          },
                        ),

                    // Password Field
                    AppTextField(
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      hint: '######',
                      label: 'Enter Password',
                      suffixIcon: Icons.lock,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {},
                        child: AppText("Forgot Password?", color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 70.h),

                    /// Login Button
                    Consumer<AuthServices>(
                      builder: (context, authServices, _) {
                        return PrimaryButton(
                          isLoading: authServices.isLoading,
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await _saveEmail(emailController.text);
                              authServices.login(emailController.text, passwordController.text);
                            }
                          },
                          title: 'Login',
                        );
                      },
                    ),

                    /// Create Account
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

  /// Save email to SharedPreferences
  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emails = prefs.getStringList('login_emails') ?? [];

    if (!emails.contains(email)) {
      emails.add(email);
      await prefs.setStringList('login_emails', emails);
      // Update the state to reflect saved emails
      setState(() {
        savedEmails = emails;
        hasSavedEmails = true;
      });
    }
  }

  // Show bottom sheet for selecting saved emails or manual entry
  void _showEmailBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emails = prefs.getStringList('login_emails') ?? [];

    if (emails.isEmpty) return;

    // Reset manual entry controllers
    manualEmailController.clear();
    manualPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Enable keyboard avoidance
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              // Add padding to account for keyboard
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (_, controller) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: secondaryColor.withOpacity(0.2),
                        child: _buildBottomSheetContent(controller, emails, setModalState),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  bool _showManualEntry = false;

  Widget _buildBottomSheetContent(ScrollController controller, List<String> emails, StateSetter setModalState) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(2.r)),
          ),
        ),

        if (!_showManualEntry) ...[
          // Saved emails section
          Center(child: AppText('Sign in with', color: whiteColor, fontSize: 16.sp)),
          SizedBox(height: 15.h),

          ...emails.map(
            (email) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
              child: ListTile(
                leading: Icon(Icons.email, color: whiteColor),
                title: AppText(email, color: whiteColor),
                trailing: Icon(Icons.arrow_forward_ios, color: whiteColor, size: 16.sp),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    emailController.text = email;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: 10.h),
          Divider(color: Colors.white60),
          SizedBox(height: 10.h),

          // Manual entry button
          Container(
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
            child: ListTile(
              leading: Icon(Icons.edit, color: whiteColor),
              title: AppText("Enter email manually", color: whiteColor),
              trailing: Icon(Icons.add, color: whiteColor),
              onTap: () {
                setModalState(() {
                  _showManualEntry = true;
                });
              },
            ),
          ),
        ] else ...[
          // Manual entry form
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setModalState(() {
                    _showManualEntry = false;
                  });
                },
                icon: Icon(Icons.arrow_back, color: whiteColor),
              ),
              AppText('Enter New Credentials', color: whiteColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ],
          ),
          SizedBox(height: 20.h),

          Form(
            key: manualFormKey,
            child: Column(
              children: [
                // Manual Email Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextFormField(
                    controller: manualEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: whiteColor),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: whiteColor.withOpacity(0.8)),
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: whiteColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.email, color: whiteColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: whiteColor.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: whiteColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter email";
                      }
                      if (!value.contains('@')) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // Manual Password Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextFormField(
                    controller: manualPasswordController,
                    obscureText: true,
                    style: TextStyle(color: whiteColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: whiteColor.withOpacity(0.8)),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: whiteColor.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.lock, color: whiteColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: whiteColor.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: whiteColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter password";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20.h),

                // Login with manual credentials button
                Consumer<AuthServices>(
                  builder: (context, authServices, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            authServices.isLoading
                                ? null
                                : () async {
                                  if (manualFormKey.currentState!.validate()) {
                                    emailController.text = manualEmailController.text;
                                    passwordController.text = manualPasswordController.text;

                                    await _saveEmail(manualEmailController.text);

                                    Navigator.pop(context);

                                    authServices.login(manualEmailController.text, manualPasswordController.text);
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: whiteColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child:
                            authServices.isLoading
                                ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                                  ),
                                )
                                : AppText('Login', color: whiteColor, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 20.h + MediaQuery.of(context).viewInsets.bottom * 0.1),
      ],
    );
  }
}
