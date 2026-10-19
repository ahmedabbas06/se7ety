import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/home_provider.dart';
import 'widgets/bottom_navigation.dart';
import 'widgets/home_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/section_title.dart';
import 'widgets/specialities_section.dart';
import 'widgets/top_doctors_section.dart';
import 'widgets/welcome_section.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (context) => HomeProvider()..getDoctors(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFCFE),
        body: SafeArea(
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WelcomeSection(),
                      const SizedBox(height: 22),
                      const SearchBarWidget(),
                      const SizedBox(height: 28),
                      const SectionTitle(title: 'التخصصات'),
                      const SizedBox(height: 14),
                      const SpecialitiesSection(),
                      const SizedBox(height: 28),
                      const SectionTitle(title: 'الأعلى تقييمًا'),
                      const SizedBox(height: 14),
                      const TopDoctorsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const PatientBottomNavigation(),
      ),
    );
  }
}
