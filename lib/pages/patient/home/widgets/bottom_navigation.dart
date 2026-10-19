import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/appointment_provider.dart';
import '../../../../providers/home_provider.dart';
import '../../../../providers/profile_provider.dart';
import '../../appointments/appointments_page.dart';
import '../../profile/patient_profile_page.dart';
import '../../search/search_page.dart';

class PatientBottomNavigation extends StatelessWidget {
  const PatientBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    HomeProvider? homeProvider;
    try {
      homeProvider = Provider.of<HomeProvider>(context, listen: false);
    } catch (_) {}

    return Container(
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

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<AppointmentProvider>(
                    create: (_) => AppointmentProvider(),
                    child: const AppointmentsPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
          ),

          IconButton(
            onPressed: () {
              Widget searchWidget = const SearchPage();
              if (homeProvider != null) {
                searchWidget = ChangeNotifierProvider.value(
                  value: homeProvider,
                  child: const SearchPage(),
                );
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => searchWidget),
              );
            },
            icon: const Icon(Icons.search),
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
                Icon(Icons.home, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Text(
                  'الرئيسية',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
