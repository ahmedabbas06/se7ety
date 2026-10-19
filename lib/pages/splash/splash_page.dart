import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../OnBoarding/onboarding_page.dart';
import '../auth/auth_gate.dart';

class SplashPage extends StatefulWidget {
  final SharedPreferences prefs;
  const SplashPage({super.key, required this.prefs});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    animationController.forward();

    _goToAuth();
  }

  Future<void> _goToAuth() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final onboardingCompleted =
        widget.prefs.getBool('onboardingCompleted') ?? false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            onboardingCompleted ? const AuthGate() : OnBoardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111114),
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: Color(0xFF3A2B25),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Transform.scale(
                      scale: 1.8,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_hospital,
                            size: 50,
                            color: Color(0xFFFF7200),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  'صحيتي',
                  style: TextStyle(
                    color: Color(0xFFFF7200),
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'ابحث عن دكتورك',
                  style: TextStyle(
                    color: Color(0xFFD1B4A9),
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
