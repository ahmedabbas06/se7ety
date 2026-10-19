import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/appointment_card.dart';
import 'widgets/appointments_header.dart';
import 'widgets/bottom_navigation.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final appointmentProvider = Provider.of<AppointmentProvider>(
          context,
          listen: false,
        );
        appointmentProvider.getPatientAppointments(
          authProvider.currentUser!.uid,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const AppointmentsHeader(),

            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, appointmentProvider, child) {
                  if (appointmentProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (appointmentProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appointmentProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.currentUser != null) {
                                appointmentProvider.getPatientAppointments(
                                  authProvider.currentUser!.uid,
                                );
                              }
                            },
                            child: const Text("إعادة المحاولة"),
                          ),
                        ],
                      ),
                    );
                  }

                  final appointments = appointmentProvider.patientAppointments;

                  if (appointments.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد حجوزات لديك حالياً",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await appointmentProvider.cancelAppointment(
                            appointmentId: appointment.id,
                            patientId: authProvider.currentUser!.uid,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppointmentsBottomNavigation(),
    );
  }
}
