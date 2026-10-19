import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';
import '../../doctors/doctor_details_page.dart';
import 'doctor_card.dart';

class TopDoctorsSection extends StatelessWidget {
  const TopDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    if (homeProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (homeProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                homeProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => homeProvider.getDoctors(),
                child: const Text("إعادة المحاولة"),
              ),
            ],
          ),
        ),
      );
    }

    final doctors = homeProvider.filteredDoctors;

    if (doctors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "لا يوجد أطباء متاحين حالياً",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: doctors.map((doctor) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
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
  }
}
