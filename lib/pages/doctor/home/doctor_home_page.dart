import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/appointment_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  late final AppointmentProvider appointmentProvider;

  @override
  void initState() {
    super.initState();
    appointmentProvider = AppointmentProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctor = authProvider.userData;
      if (doctor != null && doctor.role == 'doctor') {
        appointmentProvider.getDoctorAppointments(doctor.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppointmentProvider>.value(
      value: appointmentProvider,
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final doctor = authProvider.userData;

          if (doctor == null || doctor.role != 'doctor') {
            return Scaffold(
              body: Center(
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('تعذر تحميل بيانات الطبيب.'),
              ),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FC),
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'لوحة تحكم الدكتور',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  tooltip: 'تسجيل الخروج',
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authProvider.logout();
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DoctorInfoCard(
                      name: doctor.name,
                      speciality: doctor.speciality,
                      email: doctor.email,
                    ),
                    const SizedBox(height: 24),
                    Consumer<AppointmentProvider>(
                      builder: (context, provider, child) {
                        return Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.primary,
                              size: 25,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'حجوزات المرضى',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _CountBadge(
                              count: provider.doctorAppointments.length,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Consumer<AppointmentProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (provider.errorMessage != null) {
                            return _ErrorView(
                              message: provider.errorMessage!,
                              onRetry: () {
                                provider.getDoctorAppointments(doctor.uid);
                              },
                            );
                          }

                          final appointments = provider.doctorAppointments;

                          if (appointments.isEmpty) {
                            return const _EmptyAppointmentsView();
                          }

                          return RefreshIndicator(
                            onRefresh: () {
                              return provider.getDoctorAppointments(doctor.uid);
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: appointments.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 12);
                              },
                              itemBuilder: (context, index) {
                                final appointment = appointments[index];

                                return DoctorAppointmentCard(
                                  appointment: appointment,
                                  onAccept: () {
                                    _changeStatus(
                                      context: context,
                                      provider: provider,
                                      appointment: appointment,
                                      doctorId: doctor.uid,
                                      status: 'accepted',
                                    );
                                  },
                                  onCancel: () {
                                    _confirmCancellation(
                                      context: context,
                                      provider: provider,
                                      appointment: appointment,
                                      doctorId: doctor.uid,
                                    );
                                  },
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _changeStatus({
    required BuildContext context,
    required AppointmentProvider provider,
    required AppointmentModel appointment,
    required String doctorId,
    required String status,
  }) async {
    await provider.updateAppointmentStatus(
      appointmentId: appointment.id,
      newStatus: status,
      doctorId: doctorId,
    );

    if (!context.mounted) return;

    final message = provider.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              (status == 'accepted'
                  ? 'تم تأكيد الحجز بنجاح.'
                  : 'تم تحديث حالة الحجز.'),
        ),
        backgroundColor: message == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _confirmCancellation({
    required BuildContext context,
    required AppointmentProvider provider,
    required AppointmentModel appointment,
    required String doctorId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('إلغاء الحجز'),
          content: Text(
            'هل تريد إلغاء موعد المريض ${appointment.patientName}؟',
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

    if (confirmed != true || !context.mounted) return;

    await _changeStatus(
      context: context,
      provider: provider,
      appointment: appointment,
      doctorId: doctorId,
      status: 'cancelled',
    );
  }
}

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({
    required this.name,
    required this.speciality,
    required this.email,
  });

  final String name;
  final String? speciality;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 29,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أهلاً بيك د. $name',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      speciality?.isNotEmpty == true
                          ? speciality!
                          : 'التخصص غير محدد',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count حجز',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _EmptyAppointmentsView extends StatelessWidget {
  const _EmptyAppointmentsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/no_scheduled.svg',
            height: 150,
          ),
          const SizedBox(height: 18),
          const Text(
            'لا توجد حجوزات حتى الآن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'ستظهر حجوزات المرضى هنا عند تسجيلها.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorAppointmentCard extends StatelessWidget {
  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    required this.onAccept,
    required this.onCancel,
  });

  final AppointmentModel appointment;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = appointment.status;

    final Color statusColor;
    final String statusText;
    final IconData statusIcon;

    switch (status) {
      case 'accepted':
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'مؤكد';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'ملغي';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'مكتمل';
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        statusIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  appointment.patientName.isNotEmpty
                      ? appointment.patientName
                      : 'مريض',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AppointmentInfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'التاريخ: ${appointment.date}',
          ),
          const SizedBox(height: 9),
          _AppointmentInfoRow(
            icon: Icons.access_time,
            text: 'الوقت: ${appointment.time}',
          ),
          if (appointment.patientPhone?.isNotEmpty == true) ...[
            const SizedBox(height: 9),
            _AppointmentInfoRow(
              icon: Icons.phone_outlined,
              text: 'الهاتف: ${appointment.patientPhone}',
            ),
          ],
          if (appointment.location?.isNotEmpty == true) ...[
            const SizedBox(height: 9),
            _AppointmentInfoRow(
              icon: Icons.location_on_outlined,
              text: 'المكان: ${appointment.location}',
            ),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('قبول الحجز'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('إلغاء الحجز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AppointmentInfoRow extends StatelessWidget {
  const _AppointmentInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
