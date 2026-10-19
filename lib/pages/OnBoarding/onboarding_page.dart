import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../choice/choice_page.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  static const Color backgroundColor = Color(0xFF111114);
  static const Color textColor = Color(0xFFE7E2E1);
  static const Color secondaryTextColor = Color(0xFFD1B4A9);
  static const Color primaryColor = Color(0xFFFF7200);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: backgroundColor,
          pages: [
            PageViewModel(
              title: 'ابحث عن دكتور متخصص',
              body: 'اعثر على الطبيب المناسب لك حسب تخصصه.',
              image: Center(
                child: SvgPicture.asset(
                  'assets/on1.svg',
                  height: 250.h,
                  fit: BoxFit.contain,
                ),
              ),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'سهولة الحجز',
              body: 'احجز موعدك مع الطبيب بسهولة وفي أي وقت.',
              image: Center(
                child: SvgPicture.asset(
                  'assets/on2.svg',
                  height: 250.h,
                  fit: BoxFit.contain,
                ),
              ),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: 'صحتك وخصوصيتك أولاً',
              body: 'تابع مواعيدك واستمتع بتجربة صحية سهلة وآمنة.',
              image: Center(
                child: SvgPicture.asset(
                  'assets/on3.svg',
                  height: 250.h,
                  fit: BoxFit.contain,
                ),
              ),
              decoration: getPageDecoration(),
            ),
          ],
          showSkipButton: true,
          skip: Text(
            'تخطي',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          next: Icon(
            Icons.arrow_forward_rounded,
            color: primaryColor,
            size: 26.r,
          ),
          done: Text(
            'هيا بنا',
            style: TextStyle(
              color: primaryColor,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          onDone: () => onIntroEnd(context),
          onSkip: () => onIntroEnd(context),
          dotsDecorator: DotsDecorator(
            size: Size(8.w, 8.h),
            activeSize: Size(24.w, 8.h),
            activeColor: primaryColor,
            color: const Color(0xFF5B4A43),
            spacing: EdgeInsets.symmetric(horizontal: 4.w),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          globalFooter: SizedBox(height: 8.h),
          curve: Curves.easeInOut,
          animationDuration: 350,
          controlsMargin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          controlsPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          showBackButton: false,
        ),
      ),
    );
  }

  Future<void> onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChoiceScreen()),
    );
  }

  PageDecoration getPageDecoration() {
    return PageDecoration(
      pageColor: backgroundColor,
      imagePadding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: 20.h,
      ),
      titlePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      bodyPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      bodyTextStyle: TextStyle(
        color: secondaryTextColor,
        fontSize: 15.sp,
        height: 1.4,
      ),
      footerPadding: EdgeInsets.zero,
    );
  }
}
