
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/appointment_provider.dart';
import '../../../../providers/auth_provider.dart';

class BookingsSection extends StatelessWidget {
   const BookingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final patient = authProvider.userData;

    if (patient == null) {
      return  SizedBox.shrink();
    }

    return ChangeNotifierProvider<AppointmentProvider>(
      create: (context) {
        final provider = AppointmentProvider();
        provider.getPatientAppointments(patient.uid);
        return provider;
      },
      child: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Divider(height: 30),
               Text(
                'حجوزاتي',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
               SizedBox(height: 14),

              if (appointmentProvider.isLoading &&
                  appointmentProvider.patientAppointments.isEmpty)
                 Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (appointmentProvider.errorMessage != null &&
                  appointmentProvider.patientAppointments.isEmpty)
                _BookingMessage(
                  icon: Icons.error_outline,
                  message: appointmentProvider.errorMessage!,
                  actionText: 'إعادة المحاولة',
                  onPressed: () {
                    appointmentProvider.getPatientAppointments(
                      patient.uid,
                    );
                  },
                )
              else if (appointmentProvider.patientAppointments.isEmpty)
                   _BookingMessage(
                    icon: Icons.calendar_month_outlined,
                    message: 'لسه معندكش حجوزات',
                  )
                else
                  ...appointmentProvider.patientAppointments
                      .take(3)
                      .map((appointment) {
                    return Container(
                      margin:  EdgeInsets.only(bottom: 12),
                      padding:  EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:  Color(0xFFE5EAF0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  appointment.doctorName,
                                  textAlign: TextAlign.right,
                                  style:  TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                               SizedBox(width: 8),
                               Icon(
                                Icons.medical_services_outlined,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                           SizedBox(height: 8),
                          if (appointment.doctorSpeciality != null &&
                              appointment.doctorSpeciality!.isNotEmpty)
                            Text(
                              appointment.doctorSpeciality!,
                              textAlign: TextAlign.right,
                              style:  TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                           SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                appointment.time,
                                style:  TextStyle(fontSize: 13),
                              ),
                               SizedBox(width: 6),
                               Icon(
                                Icons.access_time,
                                size: 17,
                                color: AppColors.primary,
                              ),
                               SizedBox(width: 14),
                              Text(
                                appointment.date,
                                style:  TextStyle(fontSize: 13),
                              ),
                               SizedBox(width: 6),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                           SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding:  EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  appointment.status,
                                ).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusText(appointment.status),
                                style: TextStyle(
                                  color: _statusColor(
                                    appointment.status,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          );
        },
      ),
    );
  }

  static String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'في انتظار التأكيد';
      case 'accepted':
      case 'confirmed':
        return 'تم تأكيد الحجز';
      case 'cancelled':
        return 'تم إلغاء الحجز';
      case 'completed':
        return 'مكتمل';
      default:
        return 'حالة غير معروفة';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _BookingMessage extends StatelessWidget {
  const _BookingMessage({
    required this.icon,
    required this.message,
    this.actionText,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isCalendarIcon = icon == Icons.calendar_month_outlined;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isCalendarIcon)
            SvgPicture.asset(
              'assets/no_scheduled.svg',
              height: 100,
            )
          else
            Icon(icon, size: 36, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          if (actionText != null && onPressed != null) ...[
             SizedBox(height: 10),
            TextButton(
              onPressed: onPressed,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}
