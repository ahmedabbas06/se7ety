import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/appointment_provider.dart';
import 'widgets/booking_button.dart';
import 'widgets/booking_dialog.dart';
import 'widgets/doctor_header.dart';
import 'widgets/doctor_info.dart';

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key, required this.doctor});

  final UserModel doctor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppointmentProvider>(
      create: (_) => AppointmentProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const DoctorHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DoctorInfoSection(doctor: doctor),

                      const SizedBox(height: 25),

                      BookingButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => BookingDialog(doctor: doctor),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
