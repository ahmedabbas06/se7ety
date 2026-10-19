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
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          child: Column(
            children: [
              const DoctorHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DoctorInfoSection(doctor: doctor),
                      const SizedBox(height: 24),
                      Builder(
                        builder: (context) {
                          return BookingButton(
                            onPressed: () {
                              final appointmentProvider =
                                  Provider.of<AppointmentProvider>(
                                    context,
                                    listen: false,
                                  );

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (dialogContext) {
                                  return ChangeNotifierProvider<
                                    AppointmentProvider
                                  >.value(
                                    value: appointmentProvider,
                                    child: BookingDialog(doctor: doctor),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'تأكد من بيانات الموعد قبل تأكيد الحجز',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
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
