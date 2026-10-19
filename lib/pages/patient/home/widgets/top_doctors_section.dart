import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';
import '../../doctors/doctor_details_page.dart';
import 'doctor_card.dart';

class TopDoctorsSection extends StatelessWidget {
  const TopDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.isLoading && homeProvider.doctors.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (homeProvider.errorMessage != null && homeProvider.doctors.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 35,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                Text(
                  homeProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: homeProvider.isLoading
                      ? null
                      : () => homeProvider.getDoctors(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final doctors = homeProvider.topDoctors;

        if (doctors.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/no-search.svg',
                  height: 100,
                ),
                const SizedBox(height: 12),
                const Text(
                  'لا يوجد أطباء متاحون حاليًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          );
        }

        final displayedDoctors = doctors.take(5).toList();

        return Column(
          children: displayedDoctors.map((doctor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DoctorCard(
                doctor: doctor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetailsPage(doctor: doctor),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
