import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final user = authProvider.currentUser;

      if (user != null) {
        Provider.of<AppointmentProvider>(
          context,
          listen: false,
        ).getPatientAppointments(user.uid);
      }
    });
  }

  Future<void> _refreshAppointments() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    if (user == null) return;

    await Provider.of<AppointmentProvider>(
      context,
      listen: false,
    ).getPatientAppointments(user.uid);
  }

  Future<void> _cancelAppointment(
    AppointmentProvider appointmentProvider,
    String appointmentId,
    String patientId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إلغاء الحجز'),
          content: const Text('هل أنت متأكد إنك عايز تلغي الحجز ده؟'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('رجوع'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await appointmentProvider.cancelAppointment(
      appointmentId: appointmentId,
      patientId: patientId,
    );

    if (!mounted) return;

    final message = appointmentProvider.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'تم إلغاء الحجز بنجاح'),
        backgroundColor: message == null ? Colors.green : Colors.red,
      ),
    );
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
              child: Consumer2<AuthProvider, AppointmentProvider>(
                builder: (context, authProvider, appointmentProvider, child) {
                  final user = authProvider.currentUser;

                  if (user == null) {
                    return const Center(
                      child: Text(
                        'سجّل الدخول لعرض مواعيدك',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  if (appointmentProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (appointmentProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 45,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              appointmentProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _refreshAppointments,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final appointments = appointmentProvider.patientAppointments;

                  if (appointments.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshAppointments,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 80),
                          SvgPicture.asset(
                            'assets/no_scheduled.svg',
                            height: 170,
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'لا توجد حجوزات لديك حالياً',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'اسحب لأسفل لتحديث المواعيد',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshAppointments,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: appointments.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];

                        return AppointmentCard(
                          appointment: appointment,
                          onCancel: appointment.status == 'pending'
                              ? () {
                                  _cancelAppointment(
                                    appointmentProvider,
                                    appointment.id,
                                    user.uid,
                                  );
                                }
                              : null,
                        );
                      },
                    ),
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
