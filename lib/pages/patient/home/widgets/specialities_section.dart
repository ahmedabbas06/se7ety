import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';
import 'speciality_card.dart';

class SpecialitiesSection extends StatelessWidget {
  const SpecialitiesSection({super.key});

  IconData getSpecialityIcon(String speciality) {
    final value = speciality.toLowerCase();

    if (value.contains('قلب') || value.contains('cardio')) {
      return Icons.favorite_outline;
    }

    if (value.contains('أطفال') ||
        value.contains('اطفال') ||
        value.contains('pediatric')) {
      return Icons.child_care_outlined;
    }

    if (value.contains('أسنان') ||
        value.contains('اسنان') ||
        value.contains('dent')) {
      return Icons.mood_outlined;
    }

    if (value.contains('عظام') || value.contains('ortho')) {
      return Icons.accessibility_new_outlined;
    }

    if (value.contains('جلدية') || value.contains('derma')) {
      return Icons.spa_outlined;
    }

    if (value.contains('عيون') || value.contains('eye')) {
      return Icons.remove_red_eye_outlined;
    }

    if (value.contains('مخ') || value.contains('neuro')) {
      return Icons.psychology_outlined;
    }

    if (value.contains('نساء') || value.contains('gyn')) {
      return Icons.pregnant_woman_outlined;
    }

    return Icons.medical_services_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final specialities = homeProvider.specialities;

        if (homeProvider.isLoading && specialities.isEmpty) {
          return const SizedBox(
            height: 125,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (specialities.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'لا توجد تخصصات متاحة حاليًا',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        return SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: specialities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final speciality = specialities[index];

              return SpecialityCard(
                title: speciality,
                icon: getSpecialityIcon(speciality),
                isSelected: homeProvider.selectedSpeciality == speciality,
                onTap: () {
                  homeProvider.selectSpeciality(speciality);
                },
              );
            },
          ),
        );
      },
    );
  }
}
