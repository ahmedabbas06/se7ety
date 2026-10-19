import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';
import 'doctor_data_card.dart';

class DoctorInfoSection extends StatelessWidget {
  const DoctorInfoSection({super.key, required this.doctor});

  final UserModel doctor;

  bool hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final hasSpeciality = hasValue(doctor.speciality);
    final hasRating =
        doctor.rating != null && doctor.rating!.isFinite && doctor.rating! >= 0;

    final hasWorkingHours =
        hasValue(doctor.startHour) && hasValue(doctor.endHour);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8EDF3)),
          ),
          child: Column(
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasValue(doctor.image)
                      ? Image.network(
                          doctor.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _DoctorImagePlaceholder(
                              backgroundColor: AppColors.primary,
                            );
                          },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            );
                          },
                        )
                      : _DoctorImagePlaceholder(
                          backgroundColor: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (hasSpeciality) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.speciality!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (hasRating) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 23,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'معلومات الدكتور',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (hasValue(doctor.email)) ...[
          DoctorDataCard(
            title: 'البريد الإلكتروني',
            value: doctor.email,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 10),
        ],
        if (hasSpeciality) ...[
          DoctorDataCard(
            title: 'التخصص',
            value: doctor.speciality!,
            icon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: 10),
        ],
        if (hasValue(doctor.bio)) ...[
          DoctorDataCard(
            title: 'نبذة عن الدكتور',
            value: doctor.bio!,
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 10),
        ],
        if (hasWorkingHours) ...[
          DoctorDataCard(
            title: 'مواعيد العمل',
            value: 'من ${doctor.startHour} إلى ${doctor.endHour}',
            icon: Icons.access_time_outlined,
          ),
          const SizedBox(height: 10),
        ],
        if (hasValue(doctor.address)) ...[
          DoctorDataCard(
            title: 'عنوان العيادة',
            value: doctor.address!,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 10),
        ],
        if (hasValue(doctor.phone1)) ...[
          DoctorDataCard(
            title: 'رقم الهاتف الأول',
            value: doctor.phone1!,
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 10),
        ],
        if (hasValue(doctor.phone2))
          DoctorDataCard(
            title: 'رقم الهاتف الثاني',
            value: doctor.phone2!,
            icon: Icons.phone_android_outlined,
          ),
      ],
    );
  }
}

class _DoctorImagePlaceholder extends StatelessWidget {
  const _DoctorImagePlaceholder({required this.backgroundColor});

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        size: 58,
        color: backgroundColor,
      ),
    );
  }
}
