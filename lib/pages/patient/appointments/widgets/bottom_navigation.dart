import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/profile_provider.dart';
import '../../profile/patient_profile_page.dart';
import '../../search/search_page.dart';

class AppointmentsBottomNavigation extends StatelessWidget {
  const AppointmentsBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'الملف الشخصي',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<ProfileProvider>(
                      create: (_) => ProfileProvider(),
                      child: const PatientProfilePage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_outline),
            ),
            Container(
              width: 100,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'المواعيد',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'البحث',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: 'الرئيسية',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
