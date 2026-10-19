import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import 'doctor_data_card.dart';

class DoctorInfoSection extends StatelessWidget {
  const DoctorInfoSection({super.key, required this.doctor});

  final UserModel doctor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: Color(0xFFE2F0FC),
            shape: BoxShape.circle,
          ),
          child: doctor.image != null && doctor.image!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    doctor.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 65, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.person, size: 65, color: Colors.grey),
        ),

        const SizedBox(height: 15),

        Text(
          doctor.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          doctor.speciality ?? 'غير محدد',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),

        if (doctor.rating != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                doctor.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 25),

        DoctorDataCard(
          title: 'البريد الإلكتروني',
          value: doctor.email,
          icon: Icons.email_outlined,
        ),

        if (doctor.speciality != null && doctor.speciality!.isNotEmpty) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'التخصص',
            value: doctor.speciality!,
            icon: Icons.medical_services_outlined,
          ),
        ],

        if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'نبذة عن الدكتور',
            value: doctor.bio!,
            icon: Icons.info_outline,
          ),
        ],

        if (doctor.startHour != null && doctor.endHour != null) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'مواعيد العمل',
            value: 'من ${doctor.startHour} إلى ${doctor.endHour}',
            icon: Icons.access_time,
          ),
        ],

        if (doctor.address != null && doctor.address!.isNotEmpty) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'العنوان',
            value: doctor.address!,
            icon: Icons.location_on_outlined,
          ),
        ],

        if (doctor.phone1 != null && doctor.phone1!.isNotEmpty) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'رقم الهاتف الأول',
            value: doctor.phone1!,
            icon: Icons.phone_outlined,
          ),
        ],

        if (doctor.phone2 != null && doctor.phone2!.isNotEmpty) ...[
          const SizedBox(height: 12),
          DoctorDataCard(
            title: 'رقم الهاتف الثاني',
            value: doctor.phone2!,
            icon: Icons.phone_android_outlined,
          ),
        ],
      ],
    );
  }
}
