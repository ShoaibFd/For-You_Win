// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/auth/create_accout_page.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.delayed(const Duration(seconds: 5), () {
      _scrollHint();
    });
  }

  Future<void> _scrollHint() async {
    await _pageController.animateTo(100, duration: const Duration(milliseconds: 900), curve: Curves.easeOut);
    await Future.delayed(const Duration(milliseconds: 600));

    // Scroll back to start
    await _pageController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingData> onboardingPages = [
      OnboardingData(
        backgroundImage: 'assets/images/welcome_bg.png',
        image: 'assets/images/welcome.png',
        title: 'Welcome to ForYouWin Where Shopping Meets Winning!',
        subtitle: '',
      ),
      OnboardingData(
        backgroundImage: 'assets/images/unlock_bg.png',
        image: 'assets/images/prize.png',
        title: 'Unlock Style & Purpose.',
        subtitle: 'Shop Smart, Win Big,Make a Difference.',
      ),
      OnboardingData(
        backgroundImage: 'assets/images/unlock_bg.png',
        image: 'assets/images/cart.png',
        title: 'Your Shopping, Your Impact.',
        subtitle: 'Every Order Brings YouCloser to Winning',
      ),
      OnboardingData(
        backgroundImage: 'assets/images/unlock_bg.png',
        image: 'assets/images/prize2.png',
        title: 'Experience Shopping Like Never Before.',
        subtitle: 'Exciting Rewards Await Every Purchase!',
      ),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingPages.length,
        itemBuilder: (context, index) {
          final page = onboardingPages[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(page.backgroundImage, fit: BoxFit.cover),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    index == 0 ? Image.asset('assets/images/logo.png', height: 120.h) : const SizedBox.shrink(),
                    Image.asset(page.image, height: 230.h),
                    SizedBox(height: 20.h),
                    AppText(page.title, fontSize: 22.sp, textAlign: TextAlign.center, fontWeight: FontWeight.w600),
                    SizedBox(height: 16.h),
                    AppText(page.subtitle, fontSize: 18.sp, textAlign: TextAlign.center),
                    SizedBox(height: 100.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (indexDots) {
                        return Container(
                          margin: EdgeInsets.only(right: 6.w),
                          height: 12.h,
                          width: index == indexDots ? 24.h : 12.h,
                          decoration: BoxDecoration(
                            color: index == indexDots ? secondaryColor : secondaryColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 40.h),
                    index == 3
                        ? Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const CreateAccountPage());
                            },
                            child: Container(
                              height: 40.h,
                              width: 110.w,
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              child: Center(child: AppText('Get Started', fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OnboardingData {
  final String backgroundImage;
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({required this.backgroundImage, required this.image, required this.title, required this.subtitle});
}

//

// class OnboardingPage extends StatelessWidget {
//   const OnboardingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<OnboardingData> onboardingPages = [
//       OnboardingData(
//         backgroundImage: 'assets/images/welcome_bg.png',
//         image: 'assets/images/welcome.png',
//         title: 'Welcome to ForYouWin Where Shopping Meets Winning! ',
//         subtitle: '',
//       ),
//       OnboardingData(
//         backgroundImage: 'assets/images/unlock_bg.png',
//         image: 'assets/images/prize.png',
//         title: 'Unlock Style & Purpose.',
//         subtitle: 'Shop Smart, Win Big,Make a Difference.',
//       ),
//       OnboardingData(
//         backgroundImage: 'assets/images/unlock_bg.png',
//         image: 'assets/images/cart.png',
//         title: 'Your Shopping, Your Impact.',
//         subtitle: 'Every Order Brings YouCloser to Winning',
//       ),
//       OnboardingData(
//         backgroundImage: 'assets/images/unlock_bg.png',
//         image: 'assets/images/prize2.png',
//         title: 'Experience Shopping Like Never Before.',
//         subtitle: 'Exciting Rewards Await Every Purchase!',
//       ),
//     ];

//     return Scaffold(
//       body: PageView.builder(
//         itemCount: onboardingPages.length,
//         itemBuilder: (context, index) {
//           final page = onboardingPages[index];
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset(page.backgroundImage, fit: BoxFit.cover),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 14.w),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     index == 0 ? Image.asset('assets/images/logo.png', height: 120.h) : SizedBox.shrink(),
//                     Image.asset(page.image, height: 230.h),
//                     SizedBox(height: 20.h),
//                     AppText(page.title, fontSize: 22.sp, textAlign: TextAlign.center, fontWeight: FontWeight.bold),
//                     SizedBox(height: 16.h),
//                     AppText(page.subtitle, fontSize: 16.sp, textAlign: TextAlign.center),
//                     SizedBox(height: 100.h),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(4, (indexDots) {
//                         return Container(
//                           margin: EdgeInsets.only(right: 6.w),
//                           height: 12.h,
//                           width: index == indexDots ? 24.h : 12.h,
//                           decoration: BoxDecoration(
//                             color: index == indexDots ? secondaryColor : secondaryColor.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(30.r),
//                           ),
//                         );
//                       }),
//                     ),
//                     SizedBox(height: 40.h),
//                     index == 3
//                         ? Align(
//                           alignment: Alignment.bottomRight,
//                           child: GestureDetector(
//                             onTap: () {
//                               Get.to(() => CreateAccountPage());
//                             },
//                             child: Container(
//                               height: 40.h,
//                               width: 110.w,
//                               decoration: BoxDecoration(
//                                 color: secondaryColor,
//                                 borderRadius: BorderRadius.circular(30.r),
//                               ),
//                               child: Center(child: AppText('Get Started')),
//                             ),
//                           ),
//                         )
//                         : SizedBox(),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
