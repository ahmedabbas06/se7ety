import 'package:flutter/material.dart';
import 'package:se7ety/pages/patient/profile/widgets/bookings_section.dart';
import 'package:se7ety/pages/patient/profile/widgets/bottom_navigation.dart';
import 'package:se7ety/pages/patient/profile/widgets/contact_section.dart';
import 'package:se7ety/pages/patient/profile/widgets/profile_header.dart';
import 'package:se7ety/pages/patient/profile/widgets/profile_info_card.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProfileInfo(),

                    SizedBox(height: 20),

                    ContactSection(),

                    SizedBox(height: 20),

                    BookingsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: ProfileBottomNavigation(),
    );
  }
}
