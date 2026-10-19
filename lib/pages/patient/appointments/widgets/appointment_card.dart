import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/appointment_model.dart';
import 'appointment_info_row.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.onCancel});

  final AppointmentModel appointment;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case "accepted":
        statusColor = Colors.green;
        statusText = "مؤكد";
        break;
      case "cancelled":
        statusColor = Colors.red;
        statusText = "ملغى";
        break;
      default:
        statusColor = Colors.orange;
        statusText = "قيد الانتظار";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F0FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  appointment.doctorName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          AppointmentInfoRow(
            icon: Icons.calendar_today_outlined,
            text: appointment.date,
          ),

          const SizedBox(height: 7),

          AppointmentInfoRow(
            icon: Icons.access_time_outlined,
            text: appointment.time,
          ),

          const SizedBox(height: 7),

          AppointmentInfoRow(
            icon: Icons.person_outline,
            text: 'اسم المريض: ${appointment.patientName}',
          ),

          const SizedBox(height: 7),

          AppointmentInfoRow(
            icon: Icons.location_on_outlined,
            text: appointment.location ?? 'العيادة',
          ),

          if (appointment.status != "cancelled") ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4968),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'إلغاء الحجز',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
